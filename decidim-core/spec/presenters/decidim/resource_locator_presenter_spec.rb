# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ResourceLocatorPresenter, type: :helper do
    let(:organization) { create(:organization, host: "1.lvh.me") }

    let(:participatory_process) do
      create(:participatory_process, id: 1, organization: organization)
    end

    let(:feature) do
      create(:feature, id: 1, participatory_process: participatory_process)
    end

    let(:resource) do
      create(:dummy_resource, id: 1, feature: feature)
    end

    describe "#url" do
      subject { described_class.new(resource).url }

      it { is_expected.to eq("http://1.lvh.me/processes/1/f/1/dummy_resources/1") }
    end

    describe "#path" do
      subject { described_class.new(resource).path }

      it { is_expected.to eq("/processes/1/f/1/dummy_resources/1") }
    end
  end
end
