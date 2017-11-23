# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ResourceManifest do
    subject do
      described_class.new(
        feature_manifest: feature_manifest,
        name: name,
        route_name: route_name,
        model_class_name: model_class
      )
    end

    let(:feature_manifest) do
      FeatureManifest.new(name: "dummy")
    end

    let(:name) { :dummy }
    let(:route_name) { :dummy }
    let(:model_class) { "DummyResources::DummyResource" }

    context "when no name is set" do
      let(:name) { nil }

      it "builds it" do
        expect(subject.name).to eq(:dummy_resources)
      end
    end

    context "when no route_name is set" do
      let(:route_name) { nil }

      it "builds it" do
        expect(subject.route_name).to eq("dummy_resource")
      end
    end

    context "without a feature manifest" do
      let(:feature_manifest) { nil }

      it { is_expected.to be_invalid }
    end

    context "without a model_class" do
      let(:model_class) { nil }

      it { is_expected.to be_invalid }
    end

    context "without a route_name" do
      let(:route_name) { "" }

      it { is_expected.to be_invalid }
    end
  end
end
