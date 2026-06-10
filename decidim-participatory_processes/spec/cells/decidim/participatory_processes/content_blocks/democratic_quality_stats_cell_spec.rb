# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryProcesses::ContentBlocks::DemocraticQualityStatsCell, type: :cell do
  subject { cell(described_class, content_block, context: { resource: }) }

  let(:organization) { create(:organization) }
  let(:resource) { create(:participatory_process, organization:) }
  let(:content_block) { create(:content_block, organization:, manifest_name: :democratic_quality_stats, scope_name: :participatory_process_homepage, scoped_resource_id: resource.id) }
  let(:html) { subject.call }

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

  it "renders the democratic quality stats section" do
    expect(html).to have_css("section#democratic_quality_stats")
  end

  it "renders the quality indicator section title" do
    expect(html).to have_css("h2.home__section-title")
  end

  it "renders the global score indicator section" do
    expect(html).to have_text("Global score")
  end

  it "renders the automatic metrics section title" do
    expect(html).to have_text("Automatic metrics")
  end

  it "renders the automatic metrics indicators section" do
    expect(html).to have_text("Citizen influence")
    expect(html).to have_text("Hybridization")
    expect(html).to have_text("Responsiveness")
    expect(html).to have_text("Traceability")
  end

  it "includes a link to democratic quality indicators page" do
    I18n.with_locale(:en) do
      expect(html).to have_link(href: "/en/pages/democratic-quality-indicators")
    end
  end
end
