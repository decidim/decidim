# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe IconHelper do
    describe "#feature_icon" do
      let(:feature) do
        double(manifest: double(icon: icon))
      end

      let(:icon) { "a/fake/icon.svg" }

      describe "when the feature has no icon" do
        let(:icon) { nil }

        it "returns a fallback" do
          result = helper.feature_icon(feature)
          expect(result).to include("question-mark")
        end
      end

      describe "when the feature has no icon" do
        it "returns a fallback" do
          result = helper.feature_icon(feature)
          expect(result).to include("a/fake/icon.svg")
        end
      end
    end
  end
end
