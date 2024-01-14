# frozen_string_literal: true

require "spec_helper"

describe Decidim::Conferences::ContentBlocks::HighlightedConferencesCell, type: :cell do
  subject { cell(content_block.cell, content_block).call }

  let(:organization) { create(:organization) }
  let(:content_block) { create(:content_block, organization:, manifest_name: :highlighted_conferences, scope_name: :homepage, settings:) }
  let!(:conferences) { create_list(:conference, 8, :published, organization:) }
  let(:settings) { {} }

  controller Decidim::PagesController

  before do
    allow(controller).to receive(:current_organization).and_return(organization)
  end

  context "when the content block has no settings" do
    it "shows 6 conferences" do
      expect(subject).to have_css("a.card__grid", count: 6)
    end
  end

  context "when the content block has customized the max results setting value" do
    let(:settings) do
      {
        "max_results" => "8"
      }
    end

    it "shows up to 8 conferences" do
      expect(subject).to have_css("a.card__grid", count: 8)
    end
  end
end
