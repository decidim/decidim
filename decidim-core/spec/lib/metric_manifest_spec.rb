# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe MetricManifest do
    subject do
      described_class.new(
        metric_name:,
        manager_class:
      )
    end

    let(:metric_name) do
      :dummy_resources
    end

    let(:manager_class) do
      "DummyResources::DummyResource"
    end

    context "when no metric_name is set" do
      let(:metric_name) { nil }

      it { is_expected.to be_invalid }
    end

    context "when no manager_class is set" do
      let(:manager_class) { nil }

      it { is_expected.to be_invalid }
    end

    describe "when adding settings" do
      let(:attributes) { { name: } }

      it "is valid" do
        setup = proc do |metric_registry|
          metric_registry.metric_name = metric_name
          metric_registry.manager_class = manager_class

          metric_registry.settings do |settings|
            settings.attribute :highlighted, type: :boolean, default: true
            settings.attribute :scopes, type: :array, default: %w(home)
            settings.attribute :weight, type: :integer, default: 1
            settings.attribute :stat_block, type: :string, default: "normal"
          end
        end

        setup.call(subject)

        expect(subject).to be_valid
        expect(subject.settings.attributes).to have_key(:highlighted)
        expect(subject.settings.attributes[:highlighted].default).to be true
        expect(subject.settings.attributes).to have_key(:scopes)
        expect(subject.settings.attributes[:scopes].default).to eq %w(home)
        expect(subject.settings.attributes).to have_key(:weight)
        expect(subject.settings.attributes[:weight].default).to eq 1
        expect(subject.stat_block).to eq "normal"
      end
    end
  end
end
