# frozen_string_literal: true

require "spec_helper"

describe Decidim::Consultations::ContentBlocks::HighlightedConsultationsCell, type: :cell do
  subject { cell(content_block.cell, content_block).call }

  let(:organization) { create(:organization) }
  let(:content_block) { create :content_block, organization:, manifest_name: :highlighted_consultations, scope_name: :homepage, settings: }
  let!(:consultations) { create_list :consultation, 5, :active, organization: }
  let(:settings) { {} }

  let(:highlighted_consultations) { subject.find("#highlighted-consultations") }

  controller Decidim::PagesController

  before do
    allow(controller).to receive(:current_organization).and_return(organization)
  end

  context "when the content block has no settings" do
    it "shows 4 processes" do
      expect(highlighted_consultations).to have_selector("a.card--consultation", count: 4)
    end
  end

  context "when the content block has customized the max results setting value" do
    let(:settings) do
      {
        "max_results" => "8"
      }
    end

    it "shows up to 8 consultations" do
      expect(highlighted_consultations).to have_selector("a.card--consultation", count: 5)
    end
  end
end
