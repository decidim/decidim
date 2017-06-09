# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ResourceLocatorPresenter, type: :helper do
    let(:feature) { create(:feature) }
    let(:resource) { create(:dummy_resource, feature: feature) }

    describe "#url" do
      subject { described_class.new(resource).url }

      let(:expected_resource_url) do
        helper.decidim_dummy.dummy_resource_url(
          participatory_process_id: feature.participatory_process.id,
          feature_id: feature.id,
          id: resource.id,
          host: feature.organization.host
        )
      end

      it { is_expected.to eq(expected_resource_url) }
    end

    describe "#path" do
      subject { described_class.new(resource).path }

      let(:expected_resource_path) do
        helper.decidim_dummy.dummy_resource_path(
          participatory_process_id: feature.participatory_process.id,
          feature_id: feature.id, id: resource.id
        )
      end

      it { is_expected.to eq(expected_resource_path) }
    end
  end
end
