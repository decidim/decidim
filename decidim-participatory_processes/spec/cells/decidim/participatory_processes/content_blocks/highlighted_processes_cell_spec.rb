# frozen_string_literal: true

require "spec_helper"

describe Decidim::ParticipatoryProcesses::ContentBlocks::HighlightedProcessesCell, type: :cell do
  subject { cell(content_block.cell, content_block).call }

  let(:organization) { create(:organization) }
  let(:content_block) { create :content_block, organization: organization, manifest_name: :highlighted_processes, scope_name: :homepage, settings: settings }
  let!(:processes) { create_list :participatory_process, 5, organization: organization }
  let(:settings) { {} }

  controller Decidim::PagesController

  before do
    allow(controller).to receive(:current_organization).and_return(organization)
  end

  context "when the content block has no settings" do
    it "shows 4 processes" do
      within "#highlighted-processes" do
        expect(subject).to have_selector(".card--process", count: 4)
      end
    end
  end

  context "when the content block has customized the welcome text setting value" do
    let(:settings) do
      {
        "max_results" => "8"
      }
    end

    it "shows up to 8 processes" do
      within "#highlighted-processes" do
        expect(subject).to have_selector(".card--process", count: 5)
      end
    end
  end
end
