# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    module Admin
      describe UpdateInitiativeType do
        let(:form_klass) { InitiativeTypeForm }

        context "when valid data" do
          it_behaves_like "update an initiative type", true
        end

        context "when validation error" do
          let(:organization) { create(:organization) }
          let!(:initiative_type) { create(:initiatives_type, organization: organization, banner_image: banner_image) }
          let(:banner_image) { upload_test_file(Decidim::Dev.test_file("city2.jpeg", "image/jpeg")) }
          let(:user) { create :user, :admin, :confirmed, organization: organization }

          let(:params) do
            {
              title: initiative_type.title,
              description: initiative_type.description,
              signature_type: initiative_type.signature_type,
              attachments_enabled: initiative_type.attachments_enabled,
              undo_online_signatures_enabled: initiative_type.undo_online_signatures_enabled,
              custom_signature_end_date_enabled: initiative_type.custom_signature_end_date_enabled,
              area_enabled: initiative_type.area_enabled,
              promoting_committee_enabled: initiative_type.promoting_committee_enabled,
              minimum_committee_members: initiative_type.minimum_committee_members,
              collect_user_extra_fields: initiative_type.collect_user_extra_fields,
              extra_fields_legal_information: initiative_type.extra_fields_legal_information,
              validate_sms_code_on_votes: initiative_type.validate_sms_code_on_votes,
              document_number_authorization_handler: initiative_type.document_number_authorization_handler,
              child_scope_threshold_enabled: initiative_type.child_scope_threshold_enabled,
              only_global_scope_enabled: initiative_type.only_global_scope_enabled
            }.merge(
              banner_image: initiative_type.banner_image.blob
            )
          end

          let(:context) do
            {
              current_organization: organization,
              current_user: user
            }
          end

          let(:form) do
            Admin::InitiativeTypeForm.from_params(params).with_context(context)
          end

          let(:command) { described_class.new(initiative_type, form) }

          it "broadcasts invalid" do
            expect(initiative_type).to receive(:valid?)
              .at_least(:once)
              .and_return(false)
            expect { command.call }.to broadcast :invalid
          end
        end
      end
    end
  end
end
