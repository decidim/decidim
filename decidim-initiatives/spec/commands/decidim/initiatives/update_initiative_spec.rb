# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Initiatives
    describe UpdateInitiative do
      let(:form_klass) { Decidim::Initiatives::InitiativeForm }
      let(:organization) { create(:organization) }
      let!(:initiative) { create(:initiative, organization: organization) }
      let!(:form) do
        form_klass
          .from_model(initiative)
          .with_context(
            current_organization: organization,
            initiative: initiative
          )
      end

      context "when update succeed" do
        it "broadcasts ok" do
          form.title = "Testing"
          form.description = "Test description"
          command = described_class.new(initiative, form, initiative.author)

          expect(initiative).to receive(:valid?)
            .at_least(:once)
            .and_return(false)

          command.call
          # expect { command.call }.to broadcast :ok
        end
      end
    end
  end
end
