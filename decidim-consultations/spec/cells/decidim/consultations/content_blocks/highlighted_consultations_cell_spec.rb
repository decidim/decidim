# frozen_string_literal: true

require "spec_helper"

describe Decidim::Consultations::ContentBlocks::HighlightedConsultationsCell, type: :cell do
  subject { cell(content_block.cell, content_block).call }

  let(:organization) { create(:organization) }
  let(:content_block) { create :content_block, organization: organization, manifest_name: :highlighted_consultations, scope: :homepage, settings: settings }
  let!(:consultations) { create_list :consultation, 5, :active, organization: organization }
  let(:settings) { {} }

  controller Decidim::PagesController

  before do
    allow(controller).to receive(:current_organization).and_return(organization)
  end

  context "when the content block has no settings" do
    it "shows 4 processes" do
      within "#highlighted-consultation" do
        expect(subject).to have_selector("article.card--process", count: 4)
      end
    end
  end

  context "when the content block has customized the max results setting value" do
    let(:settings) do
      {
        "max_results" => "8"
      }
    end

    it "shows up to 8 consultations" do
      within "#highlighted-consultations" do
        expect(subject).to have_selector("article.card--consultation", count: 5)
      end
    end
  end
end
