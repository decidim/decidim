# frozen_string_literal: true

require "spec_helper"
require "decidim/initiatives/test/initiatives_signatures_test_helpers"

describe "Initiative signing with ephemeral workflows" do
  let(:organization) { create(:organization, available_authorizations: authorizations) }
  let(:scoped_type) { create(:initiatives_type_scope, supports_required: 4, type: initiatives_type) }
  let(:initiative) { create(:initiative, organization:, scoped_type:) }
  let(:initiatives_type) do
    create(
      :initiatives_type,
      :online_signature_enabled,
      organization:,
      document_number_authorization_handler: "dummy_signature_handler"
    )
  end
  let(:authorizations) { %w(dummy_authorization_handler sms) }
  let(:workflow_attributes) { base_workflow_attributes.merge(extra_workflow_attributes) }
  let(:base_workflow_attributes) { { ephemeral: true } }
  let(:extra_workflow_attributes) { {} }
  let(:test_handler) { Decidim::Initiatives::SignatureWorkflowManifest.new(**workflow_attributes) }
  let(:document_number) { "012345678X" }
  let!(:personal_data) do
    {
      name_and_surname: "Dan Dan",
      document_type: "identification_number",
      document_number:,
      gender: DummySignatureHandler::AVAILABLE_GENDERS.last,
      date_of_birth: 30.years.ago.to_date,
      postal_code: "01234"
    }
  end
  let(:promote_authorization_validation_errors) { false }

  shared_examples "preventing ephemeral session creation" do
    it "the user is not allowed to sign and no session is created" do
      expect do
        expect do
          within ".initiative__aside" do
            click_on "Sign"
          end

          expect(page).to have_no_content "Already signed"
          expect(page).to have_content "Please log in"
        end.not_to change(Decidim::InitiativesVote, :count)
      end.not_to change(Decidim::User, :count)
    end
  end

  before do
    allow(Decidim::Initiatives::Signatures)
      .to receive(:find_workflow_manifest)
      .with("dummy_signature_handler")
      .and_return(test_handler)
    switch_to_host(organization.host)
    visit decidim_initiatives.initiative_path(initiative)
  end

  context "when the workflow only enables the ephemeral feature" do
    it_behaves_like "preventing ephemeral session creation"
  end

  context "when the workflow only contains SMS step without personal data collection" do
    let(:extra_workflow_attributes) do
      {
        sms_verification: true,
        sms_mobile_phone_validator: "DummySmsMobilePhoneValidator",
        sms_mobile_phone_form: "DummySmsMobilePhoneForm"
      }
    end

    it_behaves_like "preventing ephemeral session creation"
  end

  context "when the workflow collects personal data" do
    let(:base_workflow_attributes) do
      {
        ephemeral: true,
        form: "DummySignatureHandler"
      }
    end

    context "and no authorization handler form is defined" do
      it_behaves_like "preventing ephemeral session creation"
    end

    context "and an authorization handler form is defined with save_authorizations disabled" do
      let(:extra_workflow_attributes) do
        {
          authorization_handler_form: "DummyAuthorizationHandler",
          save_authorizations: false
        }
      end

      it_behaves_like "preventing ephemeral session creation"
    end

    context "and an authorization handler form is defined" do
      let(:extra_workflow_attributes) { { authorization_handler_form: "DummyAuthorizationHandler" } }

      shared_examples "creating ephemeral session" do
        it "an ephemeral session is created and the user is redirected to fill personal data" do
          expect do
            within ".initiative__aside" do
              click_on "Sign"
            end

            expect(page).to have_content "Verify with Dummy Signature Handler"
            expect(page).to have_css("form.new_dummy_signature_handler")
          end.to change(Decidim::User.ephemeral, :count).by(1)
        end
      end

      shared_examples "creating an authorization" do
        it "displays a mandatory tos acceptance item" do
          expect(page).to have_content("By verifying your identity you accept the terms of service.")

          expect do
            expect do
              fill_personal_data(personal_data)
              click_on "Validate your data"

              within "#card__tos" do
                expect(page).to have_content "must be accepted"
              end
            end.not_to change(Decidim::InitiativesVote, :count)
          end.not_to change(Decidim::Authorization, :count)
        end

        context "when the user fills its personal accepting tos and submits the form" do
          before do
            fill_personal_data(personal_data)
            accept_tos_agreement
          end

          it "an authorization is created" do
            user = Decidim::User.ephemeral.last
            expect do
              click_on "Validate your data"
            end.to change(Decidim::Authorization.where(user:, name: "dummy_authorization_handler"), :count).by(1)
          end
        end
      end

      it_behaves_like "creating ephemeral session"
      it_behaves_like "creating an authorization" do
        before do
          within ".initiative__aside" do
            click_on "Sign"
          end
        end
      end

      context "when filling user personal data and accepting tos" do
        before do
          within ".initiative__aside" do
            click_on "Sign"
          end

          fill_personal_data(personal_data)
          accept_tos_agreement
        end

        let(:user) { Decidim::User.ephemeral.last }

        it "creates a vote on submit" do
          expect do
            click_on "Validate your data"

            expect(page).to have_content "You have signed the initiative"
          end.to change(Decidim::InitiativesVote.where(author: user), :count).by(1)
        end

        context "when the workflow includes SMS step" do
          class DummySmsMobilePhoneForm < Decidim::Verifications::Sms::MobilePhoneForm
            def generated_code
              "010203"
            end
          end

          let(:extra_workflow_attributes) do
            {
              authorization_handler_form: "DummyAuthorizationHandler",
              sms_verification: true,
              sms_mobile_phone_validator: "DummySmsMobilePhoneValidator",
              sms_mobile_phone_form: "DummySmsMobilePhoneForm"
            }
          end
          let(:phone_number) { "111222333" }

          before do
            click_on "Validate your data"
          end

          it "the user is redirected to the phone number step" do
            expect(page).to have_content "Please enter your phone number. You will then receive an SMS with a validation code."
          end

          it "the SMS step can be completed and the vote created" do
            user = Decidim::User.ephemeral.last

            fill_phone_number(phone_number)

            click_on "Receive code"
            expect(page).to have_content "Your confirmation code"
            fill_sms_code("010203")
            expect(page).to have_content "Your code is correct"

            expect do
              click_on "Sign initiative"

              expect(page).to have_content "You have signed the initiative"
            end.to change(Decidim::InitiativesVote.where(author: user), :count).by(1)
          end
        end
      end
    end

    context "with already existing authorizations" do
      let(:extra_workflow_attributes) { { authorization_handler_form: "DummyAuthorizationHandler" } }
      let(:regular_user_document_number) { "111222333X" }
      let(:regular_user_personal_data) do
        {
          name_and_surname: "Wang Wang",
          document_type: "identification_number",
          document_number: regular_user_document_number,
          gender: DummySignatureHandler::AVAILABLE_GENDERS.last,
          date_of_birth: 30.years.ago.to_date,
          postal_code: "01234"
        }
      end
      let!(:regular_user) { create(:user, :confirmed, name: regular_user_personal_data[:name_and_surname], organization:) }
      let(:ephemeral_user) { create(:user, :ephemeral, :confirmed, organization:) }
      let(:other_initiative) { create(:initiative, organization:, scoped_type:) }
      let!(:signature) { create(:initiative_user_vote, initiative: other_initiative, author: ephemeral_user) }

      context "and ephemeral sessions" do
        let!(:regular_authorization) do
          create(
            :authorization,
            :granted,
            name: "dummy_authorization_handler",
            user: regular_user,
            unique_id: regular_user_document_number,
            metadata: regular_user_personal_data.slice(:document_number, :postal_code)
          )
        end
        let!(:ephemeral_user_authorization) do
          create(
            :authorization,
            :granted,
            name: "dummy_authorization_handler",
            user: ephemeral_user,
            unique_id: document_number,
            metadata: personal_data.slice(:document_number, :postal_code)
          )
        end

        before do
          within ".initiative__aside" do
            click_on "Sign"
          end
        end

        it "an ephemeral user is unable to sign the initiative with the regular user authorization data" do
          fill_personal_data(regular_user_personal_data)
          accept_tos_agreement

          expect do
            expect do
              click_on "Validate your data"

              expect(page).to have_content "Some of the personal data provided to verify your identity is not valid."
            end.not_to change(Decidim::Authorization, :count)
          end.not_to change(Decidim::InitiativesVote, :count)
        end

        it "an ephemeral user is able to recover the session using the same authorization data" do
          fill_personal_data(personal_data)
          accept_tos_agreement

          expect do
            expect do
              click_on "Validate your data"

              expect(page).to have_content "You have signed the initiative"
            end.not_to change(Decidim::Authorization, :count)
          end.to change(Decidim::InitiativesVote.where(author: ephemeral_user), :count).by(1)
        end
      end

      context "and regular users sessions" do
        let!(:ephemeral_user_authorization) do
          create(
            :authorization,
            :granted,
            name: "dummy_authorization_handler",
            user: ephemeral_user,
            unique_id: document_number,
            metadata: personal_data.slice(:document_number, :postal_code)
          )
        end

        before do
          login_as regular_user, scope: :user
          visit decidim_initiatives.initiative_path(initiative)
          within ".initiative__aside" do
            click_on "Sign"
          end
        end

        it "a regular user using the authorization data of an ephemeral user gets the ephemeral user activities transferred" do
          fill_personal_data(personal_data)

          expect do
            expect do
              click_on "Validate your data"

              expect(page).to have_content "You have signed the initiative"
              expect(page).to have_content "We have recovered the following participation data based on your authorization"
              expect(page).to have_content "Initiatives vote: 1"
            end.not_to change(Decidim::Authorization, :count)
          end.to change(Decidim::InitiativesVote.where(author: regular_user), :count).by(2)
        end
      end
    end
  end

  def fill_personal_data(data)
    fill_in :dummy_signature_handler_name_and_surname, with: data[:name_and_surname]
    select I18n.t(data[:document_type], scope: "decidim.verifications.id_documents"), from: :dummy_signature_handler_document_type
    fill_in :dummy_signature_handler_document_number, with: data[:document_number]
    fill_signature_date data[:date_of_birth]
    select I18n.t(data[:gender], scope: "decidim.initiatives.initiative_signatures.dummy_signature.form.fields.gender.options"), from: :dummy_signature_handler_gender
    fill_in :dummy_signature_handler_postal_code, with: data[:postal_code]
    select translated_attribute(initiative.scope.name), from: :dummy_signature_handler_scope_id
  end

  def accept_tos_agreement
    within "#card__tos" do
      check "you accept the terms of service"
    end
  end

  def fill_phone_number(number)
    fill_in :dummy_sms_mobile_phone_mobile_phone_number, with: number
  end

  def fill_sms_code(code)
    code.chars.each_with_index do |digit, i|
      page.find("input[data-verification-code='#{i}']").fill_in(with: digit)
    end
  end
end
