# frozen_string_literal: true

require "spec_helper"

describe "sms code verification" do
  let(:organization) do
    create(:organization, available_authorizations: ["sms"])
  end

  let(:user) { create(:user, :confirmed, organization:) }

  let!(:authorization) do
    create(
      :authorization,
      :pending,
      name: "sms",
      user:,
      verification_metadata: prior_verification_metadata
    )
  end

  let(:verification_metadata) do
    Decidim::Authorization.first.verification_metadata
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_verifications.authorizations_path
    click_on "Code by SMS"
  end

  context "when code requested" do
    let(:prior_verification_metadata) do
      {
        verification_code: "111111",
        code_sent_at: 1.day.ago
      }
    end

    it "shows a form to the user to fill in the verification code" do
      expect(page).to have_content("Introduce the verification code you received")
    end

    context "and user verifies the code" do
      let(:verification_code) do
        verification_metadata["verification_code"]
      end

      before do
        fill_in "Verification code", with: attempted_verification_code
        click_on "Confirm"
      end

      context "when code is incorrect" do
        let(:attempted_verification_code) do
          verification_code.gsub(/\d+/) { |num| num.to_i.next }
        end

        it "shows an error message" do
          expect(page).to have_content("Your verification code does not match ours. Please double-check the SMS we sent you.")
        end
      end

      context "when verification code is correct" do
        let(:attempted_verification_code) { verification_code }

        it "shows a success message" do
          expect(page).to have_content("Congratulations. You have been successfully verified.")
        end
      end
    end

    context "when resetting the code" do
      it "deletes the verification and asks the user again" do
        accept_confirm { click_on "Reset verification code" }

        expect(page).to have_content("Verification code successfully reset. Please re-enter your phone number.")

        expect(Decidim::Authorization.count).to eq(0)
      end
    end
  end
end
