# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    module Admin
      describe CreateInitiativeType do
        let(:form_klass) { InitiativeTypeForm }

        describe "successful creation" do
          it_behaves_like "create an initiative type", true
        end

        describe "Validation failure" do
          let(:organization) { create(:organization) }
          let(:user) { create(:user, organization:) }
          let!(:initiative_type) do
            build(:initiatives_type, banner_image: nil, organization:)
          end
          let(:form) do
            form_klass
              .from_model(initiative_type)
              .with_context(current_organization: organization, current_user: user)
          end
          let(:command) { described_class.new(form) }

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
