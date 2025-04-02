# frozen_string_literal: true

require "spec_helper"
require "decidim/initiatives/test/initiatives_signatures_test_helpers"

describe "Initiative signing with workflows" do
  let(:organization) { create(:organization, available_authorizations: authorizations) }
  let(:initiative) do
    create(
      :initiative,
      organization:,
      scoped_type: create(
        :initiatives_type_scope,
        supports_required: 4,
        type: initiatives_type
      )
    )
  end
  let(:initiatives_type) do
    create(:initiatives_type, :online_signature_enabled, organization:, document_number_authorization_handler: "dummy_signature_handler")
  end
  let(:confirmed_user) { create(:user, :confirmed, organization:) }
  let(:authorizations) { %w(dummy_authorization_handler another_dummy_authorization_handler) }
  let(:workflow_attributes) do
    {
      form: "DummySignatureHandler",
      authorization_handler_form: "DummyAuthorizationHandler",
      action_authorizer: "DummySignatureHandler::DummySignatureActionAuthorizer",
      sms_verification: true,
      sms_mobile_phone_validator: "DummySmsMobilePhoneValidator",
      sms_mobile_phone_form: "DummySmsMobilePhoneForm"
    }
  end
  let(:test_handler) do
    Decidim::Initiatives::SignatureWorkflowManifest.new(**workflow_attributes)
  end
  let(:document_number) { "012345678X" }
  let!(:personal_data) do
    {
      name_and_surname: confirmed_user.name,
      document_type: "identification_number",
      document_number:,
      gender: DummySignatureHandler::AVAILABLE_GENDERS.last,
      date_of_birth: 30.years.ago.to_date,
      postal_code: "01234"
    }
  end
  let(:promote_authorization_validation_errors) { false }

  before do
    allow(Decidim::Initiatives::Signatures)
      .to receive(:find_workflow_manifest)
      .with("dummy_signature_handler")
      .and_return(test_handler)
    switch_to_host(organization.host)
    login_as confirmed_user, scope: :user
    visit decidim_initiatives.initiative_path(initiative)
  end

  context "when the workflow is blank" do
    let(:workflow_attributes) { {} }

    it "votes directly without additional steps" do
      expect do
        within ".initiative__aside" do
          click_on "Sign"
        end

        expect(page).to have_content "Already signed"
      end.to change(Decidim::InitiativesVote, :count).by(1)
    end

    context "and the vote is created" do
      before do
        within ".initiative__aside" do
          click_on "Sign"
        end

        expect(page).to have_content "Already signed"
      end

      it "the vote does not have metadata" do
        vote = Decidim::InitiativesVote.last

        expect(vote.decrypted_metadata).to be_blank
      end
    end
  end

  context "when the workflow includes a form which collects personal data" do
    let(:workflow_attributes) do
      {
        form: "DummySignatureHandler"
      }
    end

    shared_examples "sending valid personal data" do
      it "the vote is created after submitting the data" do
        expect do
          click_on "Validate your data"

          expect(page).to have_content "You have signed the initiative"
        end.to change(Decidim::InitiativesVote, :count).by(1)
      end

      it "the vote created stores the provided data in metadata" do
        click_on "Validate your data"
        expect(page).to have_content "You have signed the initiative"

        vote = Decidim::InitiativesVote.last

        expect(vote.decrypted_metadata).to eq(personal_data)
      end
    end

    before do
      within ".initiative__aside" do
        click_on "Sign"
      end
    end

    it "a form collecting personal data is shown" do
      expect(page).to have_content "Verify with Dummy Signature Handler"
      expect(page).to have_css("form.new_dummy_signature_handler")
    end

    context "and after filling the personal data" do
      before do
        fill_personal_data
      end

      it_behaves_like "sending valid personal data"

      context "with invalid authorization handler data" do
        let(:document_number) { "111111111Z" }

        it_behaves_like "sending valid personal data"
      end

      it "no authorization is created or required" do
        expect do
          click_on "Validate your data"

          expect(page).to have_content "You have signed the initiative"
        end.not_to change(Decidim::Authorization, :count)
      end
    end

    context "and includes an authorization handler" do
      let(:workflow_attributes) do
        {
          form: "DummySignatureHandler",
          authorization_handler_form: "DummyAuthorizationHandler",
          promote_authorization_validation_errors:
        }
      end

      shared_examples "sending authorization handler invalid personal data" do
        let(:document_number) { "111111111Z" }

        it "a global invalid data message is shown and no vote or authorization are created" do
          expect do
            expect do
              click_on "Validate your data"

              expect(page).to have_content "Some of the personal data provided to verify your identity is not valid."

              expect(page).to have_no_css("form.new_dummy_signature_handler div", text: "is invalid")
              expect(page).to have_no_css("div.field_with_errors")
            end.not_to change(Decidim::InitiativesVote, :count)
          end.not_to change(Decidim::Authorization, :count)
        end

        context "when workflow promotes authorization validation errors" do
          let(:promote_authorization_validation_errors) { true }

          it "an extra invalid data message is shown next to the failing field and no vote or authorization are created" do
            expect do
              expect do
                click_on "Validate your data"

                expect(page).to have_content "Some of the personal data provided to verify your identity is not valid."

                expect(page).to have_css("form.new_dummy_signature_handler div", text: "is invalid")
                within("div.field_with_errors") do
                  expect(page).to have_field("dummy_signature_handler[document_number]")
                end
              end.not_to change(Decidim::InitiativesVote, :count)
            end.not_to change(Decidim::Authorization, :count)
          end
        end
      end

      shared_examples "creating authorization with metadata from personal data" do
        it "an authorization is created with unique_id and metadata for the user" do
          expect do
            click_on "Validate your data"

            expect(page).to have_content "You have signed the initiative"
          end.to change(Decidim::Authorization, :count).by(1)

          authorization = Decidim::Authorization.last
          expect(authorization.user).to eq(confirmed_user)
          expect(authorization.unique_id).to eq(personal_data[:document_number])
          expect(authorization.metadata["postal_code"]).to eq(personal_data[:postal_code])
          expect(authorization.metadata["document_number"]).to eq(personal_data[:document_number])
        end
      end

      it "a form collecting personal data is shown" do
        expect(page).to have_content "Verify with Dummy Signature Handler"
        expect(page).to have_css("form.new_dummy_signature_handler")
      end

      context "and after filling the personal data" do
        before do
          fill_personal_data
        end

        it_behaves_like "sending valid personal data"
        it_behaves_like "sending authorization handler invalid personal data"
        it_behaves_like "creating authorization with metadata from personal data"
      end

      context "when save authorizations is set to false in the workflow" do
        let(:workflow_attributes) do
          {
            form: "DummySignatureHandler",
            authorization_handler_form: "DummyAuthorizationHandler",
            save_authorizations: false,
            promote_authorization_validation_errors:
          }
        end

        before do
          fill_personal_data
        end

        it_behaves_like "sending valid personal data"
        it_behaves_like "sending authorization handler invalid personal data"

        it "no authorization is created for the user" do
          expect do
            click_on "Validate your data"

            expect(page).to have_content "You have signed the initiative"
          end.not_to change(Decidim::Authorization, :count)
        end
      end

      context "and an action authorizer is set" do
        let(:workflow_attributes) do
          {
            form: "DummySignatureHandler",
            authorization_handler_form: "DummyAuthorizationHandler",
            action_authorizer: Decidim::Initiatives::DefaultSignatureAuthorizer,
            promote_authorization_validation_errors:
          }
        end

        shared_examples "verifying authorization status" do
          let(:authorizer) do
            double
          end
          let(:status) { [:ok, {}] }

          before do
            allow(Decidim::Initiatives::DefaultSignatureAuthorizer).to receive(:new).and_return(authorizer)
            allow(authorizer).to receive(:authorize).and_return(status)

            click_on "Validate your data"
          end

          context "when the authorization status is :ok" do
            it "checks the authorization status and creates the vote" do
              expect(page).to have_content "You have signed the initiative"
              expect(Decidim::InitiativesVote.where(author: confirmed_user)).to be_present
            end
          end

          context "when the authorization status is not :ok" do
            let(:status) { [:unauthorized, {}] }

            it "the vote is not allowed" do
              expect(page).to have_content "The data provided to proceed with the action is not compatible with your existing authorizations or you have to create a granted authorization."
              expect(Decidim::InitiativesVote.where(author: confirmed_user)).to be_blank
            end
          end
        end

        before do
          fill_personal_data
        end

        it_behaves_like "sending valid personal data"
        it_behaves_like "sending authorization handler invalid personal data"
        it_behaves_like "creating authorization with metadata from personal data"
        it_behaves_like "verifying authorization status"

        context "when an existing authorization is present" do
          before do
            create(
              :authorization,
              :granted,
              name: "dummy_authorization_handler",
              user: confirmed_user,
              unique_id: "012345678X",
              metadata: { document_number: "012345678X" }
            )

            fill_personal_data
          end

          it "the vote is created but no authorization is created" do
            expect do
              click_on "Validate your data"

              expect(page).to have_content "You have signed the initiative"
            end.not_to change(Decidim::Authorization, :count)

            expect(Decidim::InitiativesVote.where(author: confirmed_user)).to be_present
          end

          it_behaves_like "sending valid personal data"
          it_behaves_like "sending authorization handler invalid personal data"

          context "and the user provides new valid personal data to create an authorization" do
            let(:document_number) { "333333333X" }

            it "the authorization unique id and metadata is updated if the user sends valid personal data" do
              expect do
                click_on "Validate your data"

                expect(page).to have_content "You have signed the initiative"
              end.not_to change(Decidim::Authorization, :count)

              authorization = Decidim::Authorization.where(user: confirmed_user).last

              expect(authorization.unique_id).to eq("333333333X")
              expect(authorization.metadata["postal_code"]).to eq(personal_data[:postal_code])
              expect(authorization.metadata["document_number"]).to eq("333333333X")
            end
          end
        end

        context "and save authorizations is set to false" do
          let(:workflow_attributes) do
            {
              form: "DummySignatureHandler",
              authorization_handler_form: "DummyAuthorizationHandler",
              action_authorizer: Decidim::Initiatives::DefaultSignatureAuthorizer,
              save_authorizations: false,
              promote_authorization_validation_errors:
            }
          end

          context "when no authorizations are present" do
            before do
              fill_personal_data
            end

            it "no authorization or vote is created" do
              expect do
                click_on "Validate your data"

                expect(page).to have_content "The data provided to proceed with the action is not compatible with your existing authorizations or you have to create a granted authorization."
              end.not_to change(Decidim::InitiativesVote, :count)

              expect(Decidim::Authorization.where(user: confirmed_user)).to be_blank
            end
          end

          context "when an existing authorization is present" do
            before do
              create(
                :authorization,
                :granted,
                name: "dummy_authorization_handler",
                user: confirmed_user,
                unique_id: "012345678X",
                metadata: { document_number: "012345678X", postal_code: "01234" }
              )

              fill_personal_data
            end

            it "the vote is created but no authorization is created" do
              expect do
                click_on "Validate your data"

                expect(page).to have_content "You have signed the initiative"
              end.not_to change(Decidim::Authorization, :count)

              expect(Decidim::InitiativesVote.where(author: confirmed_user)).to be_present
            end

            it_behaves_like "sending valid personal data"
            it_behaves_like "sending authorization handler invalid personal data"
          end
        end
      end
    end
  end

  context "when the workflow contains SMS steps" do
    class DummySmsMobilePhoneForm < Decidim::Verifications::Sms::MobilePhoneForm
      def generated_code
        "010203"
      end
    end

    let(:phone_number) { "111222333" }

    before do
      within ".initiative__aside" do
        click_on "Sign"
      end
    end

    context "and sms authorization is not available in the organization" do
      context "and collects personal data" do
        it "after filling personal data the vote is created with no SMS validation" do
          fill_personal_data
          click_on "Validate your data"

          expect(page).to have_content "You have signed the initiative"
        end
      end

      context "and does not collect personal data" do
        let(:workflow_attributes) do
          {
            sms_verification: true,
            sms_mobile_phone_validator: "DummySmsMobilePhoneValidator",
            sms_mobile_phone_form: "DummySmsMobilePhoneForm"
          }
        end

        it "votes directly without additional steps" do
          expect(page).to have_content "You have signed the initiative"
        end
      end
    end

    context "and sms authorization is available in the organization" do
      let(:authorizations) { %w(dummy_authorization_handler another_dummy_authorization_handler sms) }

      context "and collects personal data" do
        it "after filling personal data the user is redirected to the phone number step" do
          fill_personal_data
          click_on "Validate your data"

          expect(page).to have_content "Please enter your phone number. You will then receive an SMS with a validation code."
        end
      end

      context "and does not collect personal data" do
        let(:workflow_attributes) do
          {
            sms_verification: true,
            sms_mobile_phone_validator: "DummySmsMobilePhoneValidator",
            sms_mobile_phone_form: "DummySmsMobilePhoneForm"
          }
        end

        it "sends the user to the phone number step" do
          expect(page).to have_content "Please enter your phone number. You will then receive an SMS with a validation code."
        end
      end

      context "when mobile phone validator does not require a previous authorization" do
        let(:workflow_attributes) do
          {
            sms_verification: true,
            sms_mobile_phone_validator: "DummySmsMobilePhoneValidator",
            sms_mobile_phone_form: "DummySmsMobilePhoneForm"
          }
        end

        it "the SMS step can be completed" do
          fill_phone_number(phone_number)

          click_on "Receive code"
          expect(page).to have_content "Your confirmation code"
          fill_sms_code("010203")
          expect(page).to have_content "Your code is correct"
          click_on "Sign initiative"

          expect(page).to have_content "You have signed the initiative"
        end
      end

      context "when mobile phone validator does not requires a previous authorization" do
        let(:workflow_attributes) do
          {
            sms_verification: true,
            sms_mobile_phone_form: "DummySmsMobilePhoneForm"
          }
        end

        context "and no authorization is present" do
          it "an invalid phone number message appears and the signature cannot be completed" do
            fill_phone_number(phone_number)

            click_on "Receive code"
            expect(page).to have_no_content "Your confirmation code"
            expect(page).to have_content "The phone number is invalid or pending of authorization. Please, check your authorizations."
          end
        end

        context "and there is an SMS authorization for the user" do
          let!(:verification_form) { Decidim::Verifications::Sms::MobilePhoneForm.new(mobile_phone_number: phone_number) }
          let(:sms_authorization_unique_id) { verification_form.unique_id }

          before do
            create(:authorization, name: "sms", user: confirmed_user, granted_at: 2.seconds.ago, unique_id: sms_authorization_unique_id)
          end

          context "and the user uses the same phone number" do
            it "the SMS step can be completed" do
              fill_phone_number(phone_number)

              click_on "Receive code"
              expect(page).to have_content "Your confirmation code"
              fill_sms_code("010203")
              expect(page).to have_content "Your code is correct"
              click_on "Sign initiative"

              expect(page).to have_content "You have signed the initiative"
            end
          end

          context "and the user uses a wrong phone number" do
            it "an invalid phone number message appears and the signature cannot be completed" do
              fill_phone_number("000000000")

              click_on "Receive code"
              expect(page).to have_no_content "Your confirmation code"
              expect(page).to have_content "The phone number is invalid or pending of authorization. Please, check your authorizations."
            end
          end
        end
      end
    end
  end

  def fill_personal_data
    fill_in :dummy_signature_handler_name_and_surname, with: personal_data[:name_and_surname]
    select I18n.t(personal_data[:document_type], scope: "decidim.verifications.id_documents"), from: :dummy_signature_handler_document_type
    fill_in :dummy_signature_handler_document_number, with: personal_data[:document_number]
    fill_signature_date personal_data[:date_of_birth]
    select I18n.t(personal_data[:gender], scope: "decidim.initiatives.initiative_signatures.dummy_signature.form.fields.gender.options"), from: :dummy_signature_handler_gender
    fill_in :dummy_signature_handler_postal_code, with: personal_data[:postal_code]
    select translated_attribute(initiative.scope.name), from: :dummy_signature_handler_scope_id
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
