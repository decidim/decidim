# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe SettingsChange do
    let(:feature) do
      instance_double(
        Decidim::Feature,
        id: 1,
        manifest_name: "dummy"
      )
    end
    let(:previous_settings) do
      { "allow_something" => false }
    end
    let(:current_settings) do
      { "allow_something" => true }
    end

    describe "publish" do
      it "broadcasts setting changes" do
        expect(ActiveSupport::Notifications)
          .to receive(:publish)
          .with(
            "decidim.settings_change.dummy",
            feature_id: 1,
            previous_settings: { allow_something: false },
            current_settings: { allow_something: true }
          )

        described_class.publish(
          feature,
          previous_settings,
          current_settings
        )
      end
    end

    describe "#subscribe" do
      let(:scope) { "dummy" }
      let(:block) { proc { |_data| "Hello world" } }

      it "subscribes to setting changes" do
        expect(ActiveSupport::Notifications)
          .to receive(:subscribe)
          .with(/^decidim\.settings_change\.dummy/, &block)

        described_class.subscribe(scope, &block)
      end
    end
  end
end
