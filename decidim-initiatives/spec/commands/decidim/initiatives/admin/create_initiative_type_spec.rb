# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    module Admin
      describe CreateInitiativeType do
        let(:form_klass) { InitiativeTypeForm }

        describe "successfull creation" do
          it_behaves_like "create an initiative type", true
        end

        describe "Validation failure" do
          let(:organization) { create(:organization) }
          let(:user) { create(:user, organization: organization) }
          let!(:initiative_type) do
            build(:initiatives_type, organization: organization)
          end
          let(:form) do
            form_klass
              .from_model(initiative_type)
              .with_context(current_organization: organization)
          end

          let(:errors) do
            ActiveModel::Errors.new(initiative_type)
                               .tap { |e| e.add(:banner_image, "upload error") }
          end
          let(:command) { described_class.new(form, user) }

          it "broadcasts invalid" do
            expect(InitiativesType).to receive(:new).at_least(:once).and_return(initiative_type)
            expect(initiative_type).to receive(:persisted?)
              .at_least(:once)
              .and_return(false)

            expect { command.call }.to broadcast :invalid
          end
        end
      end
    end
  end
end
