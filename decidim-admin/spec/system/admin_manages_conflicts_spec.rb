# frozen_string_literal: true

require "spec_helper"

describe "Admin manages conflicts" do
  let(:organization) { create(:organization) }

  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let!(:other_user) { create(:user, :admin, :confirmed, organization:, email: "other_user@example.org") }

  let!(:conflictive_user) { create(:user, :admin, :confirmed, organization:, email: "conflictive@example.org") }
  let!(:managed_user) { create(:user, managed: true, organization:, email: "managed@example.org") }

  let!(:conflict) { create(:conflict, current_user: conflictive_user, managed_user:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.root_path
    click_on "Participants"
    click_on "Verification conflicts"
    click_on "Transfer"
  end

  context "when resolving a conflict" do
    context "when no mail is passed" do
      before do
        click_on "Transfer"
      end

      it "the transfer cannot be sent" do
        expect(page).to have_content("There is an error")
      end
    end

    context "when a mail is passed" do
      let(:email) { "new_user@example.org" }

      before do
        fill_in "Email", with: email
        click_on "Transfer"
      end

      context "when the email is not in use by any other user" do
        it "the transfer is successful" do
          expect(page).to have_content("The current transfer has been successfully completed.")
        end

        it "the email of the managed user is replaced with the email passed by the form" do
          expect(managed_user.reload.email).to eq("new_user@example.org")
        end
      end

      context "when the email is the email of the conflictive user" do
        let(:email) { "conflictive@example.org" }

        it "the transfer is successful" do
          expect(page).to have_content("The current transfer has been successfully completed.")
        end

        it "the email of the managed user is replaced with the email of the conflictive one" do
          expect(managed_user.reload.email).to eq("conflictive@example.org")
        end
      end

      context "when the email is the email of the managed user" do
        let(:email) { "managed@example.org" }

        it "the transfer is successful" do
          expect(page).to have_content("The current transfer has been successfully completed.")
        end

        it "the managed user keeps its email" do
          expect(managed_user.reload.email).to eq("managed@example.org")
        end
      end

      context "when the email is the email of an already existing user" do
        let(:email) { "other_user@example.org" }

        it "the transfer fails" do
          expect(page).to have_no_content("The current transfer has been successfully completed.")
          expect(page).to have_content("There was a problem transferring the current participant to managed participant")
        end
      end
    end
  end
end
