# frozen_string_literal: true

require "spec_helper"

describe "Initiative signing" do
  let(:organization) { create(:organization, available_authorizations: authorizations) }
  let(:initiative) { create(:initiative, organization:, scoped_type: create(:initiatives_type_scope, type: initiatives_type)) }
  let(:initiatives_type) { create(:initiatives_type, :with_sms_code_validation_and_user_extra_fields_collection, organization:) }
  let(:confirmed_user) { create(:user, :confirmed, organization:) }
  let(:authorizations) { ["sms"] }
  let(:document_number) { "0123345678X" }
  let(:phone_number) { "666666666" }
  let!(:verification_form) { Decidim::Verifications::Sms::MobilePhoneForm.new(mobile_phone_number: phone_number) }
  let(:unique_id) { verification_form.unique_id }
  let(:sms_code) { "012345" }
  let!(:authorization) do
    create(
      :authorization,
      :granted,
      name: "dummy_authorization_handler",
      user: confirmed_user,
      unique_id: document_number,
      metadata: { document_number:, postal_code: "01234", scope_id: initiative.scope.id }
    )
  end

  shared_examples "ends signature with sms code" do
    context "when inserts the wrong code number" do
      let(:form_sms_code) { "000000" }

      it "appears an invalid message" do
        fill_sms_code

        expect(page).to have_content("The code is not correct")
        expect(page).to have_no_button("Sign initiative")
        expect(initiative.reload.supports_count).to be_zero
      end
    end

    context "when inserts the correct code number" do
      let(:form_sms_code) { sms_code }

      it "the vote is created" do
        fill_sms_code

        expect(page).to have_content("Your code is correct")
        click_on "Sign initiative"

        expect(page).to have_content("initiative has been successfully signed")
        click_on "Back to initiative"

        expect(page).to have_content(signature_text(1))
        expect(initiative.reload.supports_count).to eq(1)
      end
    end
  end

  before do
    allow(Decidim::Initiatives)
      .to receive(:do_not_require_authorization)
      .and_return(true)
    switch_to_host(organization.host)
    login_as confirmed_user, scope: :user
    visit decidim_initiatives.initiative_path(initiative)

    allow(Decidim::Verifications::Sms::MobilePhoneForm).to receive(:new).and_return(verification_form)
    allow(verification_form).to receive(:verification_metadata).and_return(verification_code: sms_code)

    expect(page).to have_css(".initiative__aside", text: signature_text(0))

    within ".initiative__aside" do
      expect(page).to have_content(signature_text(0))
      click_on "Sign"
    end

    if has_content?("Verify with Dummy Signature Handler")
      fill_in :dummy_signature_handler_name_and_surname, with: confirmed_user.name
      select "Identification number", from: :dummy_signature_handler_document_type
      fill_in :dummy_signature_handler_document_number, with: document_number
      fill_date 30.years.ago
      fill_in :dummy_signature_handler_postal_code, with: "01234"
      select translated_attribute(initiative.scope.name), from: :dummy_signature_handler_scope_id

      click_on "Validate your data"

      expect(page).to have_no_css("div.alert")
    end
  end

  context "when initiative type personal data collection is disabled" do
    let(:initiatives_type) { create(:initiatives_type, :with_sms_code_validation, organization:) }

    it "The sms step appears" do
      expect(page).to have_content("Mobile phone number")
    end
  end

  context "when the signature workflow validates the phone number looking for an authorization" do
    let(:initiatives_type) { create(:initiatives_type, :with_sms_code_validation, organization:) }

    context "without authorization" do
      it "phone number is invalid" do
        fill_phone_number

        expect(page).to have_content("The phone number is invalid or pending of authorization")
        expect(initiative.reload.supports_count).to be_zero
      end
    end

    context "with valid authorization" do
      before do
        create(:authorization, name: "sms", user: confirmed_user, granted_at: 2.seconds.ago, unique_id:)
      end

      context "and inserts wrong phone number" do
        let(:unique_id) { "wadus" }

        it "appears an invalid message" do
          fill_phone_number

          expect(page).to have_content("The phone number is invalid or pending of authorization")
          expect(initiative.reload.supports_count).to be_zero
        end
      end

      context "and inserts correct phone number" do
        before do
          fill_phone_number
        end

        it "sms code is required" do
          expect(page).to have_content("Your confirmation code")
          expect(page).to have_css("[data-check-code]")
          expect(initiative.reload.supports_count).to be_zero
        end

        include_examples "ends signature with sms code"
      end
    end
  end

  context "when personal data collection is enabled" do
    context "when the user has not signed the initiative yet an signs it" do
      context "when sms authorization is not available for the site" do
        let(:authorizations) { [] }

        it "The vote is created" do
          expect(page).to have_content("initiative has been successfully signed")
          click_on "Back to initiative"

          within ".initiative__aside" do
            expect(page).to have_content(signature_text(1))
            expect(initiative.reload.supports_count).to eq(1)
          end
        end
      end

      it "mobile phone is required" do
        expect(page).to have_content("Enter your number and you will receive a code that you should type")
        expect(page).to have_content("Receive code")
        expect(initiative.reload.supports_count).to be_zero
      end

      context "when the user fills phone number and the workflow does not validate the phone number looking for an authorization" do
        let(:form_sms_code) { sms_code }

        before do
          fill_phone_number
        end

        it "sms code is required" do
          expect(page).to have_content("Your confirmation code")
          expect(page).to have_css("[data-check-code]")
          expect(initiative.reload.supports_count).to be_zero
        end

        include_examples "ends signature with sms code"
      end
    end
  end
end

def fill_phone_number
  fill_in :mobile_phone_mobile_phone_number, with: phone_number
  click_on "Receive code"
end

def fill_sms_code
  within("[data-check-code]") do
    form_sms_code.chars.each_with_index do |digit, idx|
      fill_in "mobile_phone[verification_code][#{idx}]", with: digit
    end
  end
end

def fill_date(date)
  [date.year, date.month, date.day].each_with_index do |value, i|
    within "select[name='dummy_signature_handler[date_of_birth(#{i + 1}i)]']" do
      find("option[value='#{value}']").select_option
    end
  end
end

def signature_text(number)
  return "1 #{initiative.supports_required}\nSignature" if number == 1

  "#{number} #{initiative.supports_required}\nSignatures"
end
