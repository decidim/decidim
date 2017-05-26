# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ActionController::Base, type: :controller do
    let(:feature) { create(:feature) }
    let(:participatory_process) { feature.participatory_process }

    before do
      allow(controller).to receive(:current_feature).and_return(feature)

      allow(controller).to receive(:current_participatory_process)
        .and_return(participatory_process)
    end

    controller do
      include Decidim::FeatureSettings
    end

    describe "#feature_settings" do
      it "returns the current feature's configuration" do
        expect(controller.feature_settings).to eq(feature.settings)
      end
    end

    describe "current_settings" do
      context "when no step is active" do
        it "returns nil" do
          expect(controller.current_settings).to eq(nil)
        end
      end

      context "when there's an active step" do
        let!(:step) do
          create(:participatory_process_step,
                 participatory_process: participatory_process,
                 active: true)
        end

        it "returns the settings for the active step" do
          expect(controller.current_settings)
            .to eq(feature.step_settings[step.id.to_s])
        end
      end
    end
  end
end
