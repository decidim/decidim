# frozen_string_literal: true

require "spec_helper"

describe Decidim::Conferences::ContentBlocks::HighlightedConferencesCell, type: :cell do
  subject { cell(content_block.cell, content_block).call }

  let(:organization) { create(:organization) }
  let(:content_block) { create :content_block, organization:, manifest_name: :highlighted_conferences, scope_name: :homepage, settings: }
  let!(:conferences) { create_list :conference, 5, :published, organization: }
  let(:settings) { {} }

  let(:highlighted_conferences) { subject.find("#highlighted-conferences") }

  controller Decidim::PagesController

  before do
    allow(controller).to receive(:current_organization).and_return(organization)
  end

  # Conferences don't have a max_results settings number selector yet, we might want this back when they do
  # context "when the content block has no settings" do
  #   it "shows 4 processes" do
  #     expect(highlighted_conferences).to have_selector("a.card--conference", count: 4)
  #   end
  # end

  context "when the content block has customized the max results setting value" do
    # note that settings is doing nothing here, just left it for when conferences block is improved
    let(:settings) do
      {
        "max_results" => "8"
      }
    end

    it "shows up to 8 conferences" do
      expect(highlighted_conferences).to have_selector("a.card--conference", count: 5)
    end
  end
end
