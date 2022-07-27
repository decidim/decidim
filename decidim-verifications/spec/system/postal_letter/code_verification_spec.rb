# frozen_string_literal: true

require "spec_helper"

describe "Postal letter code verification", type: :system do
  let(:organization) do
    create(:organization, available_authorizations: ["postal_letter"])
  end

  let(:user) { create(:user, :confirmed, organization:) }
  let(:admin) { create(:user, :admin, :confirmed, organization:) }

  let!(:authorization) do
    create(
      :authorization,
      :pending,
      name: "postal_letter",
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
    click_link "Code by postal letter"
  end

  context "when code requested but letter not sent" do
    let(:prior_verification_metadata) do
      { pending_verification_code: "111111", address: "C/ Percebe" }
    end

    it "shows an informative message to the user" do
      expect(page)
        .to have_content("We'll be sending a letter to your address with your verification code soon")
    end
  end

  context "when code requested and letter sent" do
    let(:prior_verification_metadata) do
      {
        verification_code: "111111",
        address: "C/ Percebe",
        letter_sent_at: 1.day.ago
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
        click_button "Confirm"
      end

      context "when code is incorrect" do
        let(:attempted_verification_code) do
          verification_code.gsub(/\d+/) { |num| num.to_i.next }
        end

        it "shows an error message" do
          expect(page).to have_content("Your verification code doesn't match ours. Please double-check the letter we sent to you")
        end
      end

      context "when verification code is correct" do
        let(:attempted_verification_code) { verification_code }

        it "shows a success message" do
          expect(page).to have_content("Congratulations. You've been successfully verified")
        end
      end
    end
  end
end
