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
          let!(:initiative_type) { create(:initiatives_type, organization: organization) }
          let(:form) do
            form_klass
              .from_model(initiative_type)
              .with_context(current_organization: organization)
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
