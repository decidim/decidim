# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    module Admin
      describe UpdateInitiative do
        let(:form_klass) { Decidim::Initiatives::Admin::InitiativeForm }

        context "when valid data" do
          it_behaves_like "update an initiative"
        end

        context "when validation failure" do
          let(:organization) { create(:organization) }
          let!(:initiative) { create(:initiative, organization: organization) }
          let!(:form) do
            form_klass
              .from_model(initiative)
              .with_context(current_organization: organization, initiative: initiative)
          end

          let(:command) { described_class.new(initiative, form, initiative.author) }

          it "broadcasts invalid" do
            expect(initiative).to receive(:valid?)
              .at_least(:once)
              .and_return(false)
            expect { command.call }.to broadcast :invalid
          end
        end
      end
    end
  end
end
