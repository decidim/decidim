# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryProcesses::ContentBlocks::DemocraticQualityStatsCell, type: :cell do
  subject { cell(described_class, content_block, context: { resource: }) }

  let(:organization) { create(:organization) }
  let(:resource) { create(:participatory_process, organization:) }
  let(:content_block) { create(:content_block, organization:, manifest_name: :democratic_quality_stats, scope_name: :participatory_process_homepage, scoped_resource_id: resource.id) }

  controller Decidim::ParticipatoryProcesses::ParticipatoryProcessesController

  before do
    allow(controller).to receive(:current_organization).and_return(organization)
  end

  describe "#info_url" do
    it "generates the correct page path with locale" do
      I18n.with_locale(:en) do
        expect(subject.send(:info_url)).to eq("/en/pages/democratic-quality-indicators")
      end
    end

    it "uses the current locale" do
      I18n.with_locale(:es) do
        expect(subject.send(:info_url)).to eq("/es/pages/democratic-quality-indicators")
      end
    end
  end
end
