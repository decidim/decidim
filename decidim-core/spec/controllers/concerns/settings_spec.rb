# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ActionController::Base, type: :controller do
    let(:component) { create(:component) }
    let(:participatory_process) { component.participatory_space }

    before do
      allow(controller).to receive(:current_component).and_return(component)
    end

    controller do
      include Decidim::Settings
    end

    matcher :be_equivalent_to do |expected|
      match do |actual|
        actual.attributes == expected.attributes
      end
    end

    describe "#component_settings" do
      it "returns the current component's configuration" do
        expect(controller.component_settings)
          .to be_equivalent_to(component.settings)
      end
    end

    describe "current_settings" do
      context "when no step is active" do
        it "returns the default step settings" do
          expect(controller.current_settings)
            .to be_equivalent_to(component.default_step_settings)
        end
      end

      context "when there's an active step" do
        let!(:step) do
          create(:participatory_process_step,
                 participatory_process:,
                 active: true)
        end

        it "returns the settings for the active step" do
          expect(controller.current_settings)
            .to be_equivalent_to(component.step_settings[step.id.to_s])
        end
      end
    end
  end
end
