# frozen_string_literal: true

require "spec_helper"

describe Decidim::Initiatives::ContentBlocks::HighlightedInitiativesCell, type: :cell do
  subject { cell(content_block.cell, content_block).call }

  let(:organization) { create(:organization) }
  let(:content_block) { create(:content_block, organization:, manifest_name: :highlighted_initiatives, scope_name: :homepage, settings:) }
  let!(:initiatives) { create_list(:initiative, 5, organization:) }
  let!(:most_recent_initiative) { create(:initiative, published_at: 1.day.from_now, organization:) }
  let(:settings) { {} }

  controller Decidim::PagesController

  before do
    allow(controller).to receive(:current_organization).and_return(organization)
  end

  context "when the content block has no settings" do
    it "shows 4 initiatives" do
      expect(subject).to have_selector("a.card__grid", count: 4)
    end

    it "shows up initiatives ordered by default" do
      expect(subject).not_to eq(most_recent_initiative)
    end
  end

  context "when the content block has customized the max results setting value" do
    let(:settings) do
      {
        "max_results" => "8"
      }
    end

    it "shows up to 8 initiatives" do
      expect(subject).to have_selector("a.card__grid", count: 6)
    end
  end

  context "when the content block has customized the sorting order" do
    context "when sorting by most_recent" do
      let(:settings) do
        {
          "order" => "most_recent"
        }
      end

      it "shows up initiatives ordered by published_at" do
        expect(subject.to_s.index("initiative_#{most_recent_initiative.id}")).to be < subject.to_s.index("initiative_#{initiatives[4].id}")
        expect(subject.to_s.index("initiative_#{most_recent_initiative.id}")).to be < subject.to_s.index("initiative_#{initiatives[3].id}")
        expect(subject.to_s.index("initiative_#{most_recent_initiative.id}")).to be < subject.to_s.index("initiative_#{initiatives[2].id}")
      end
    end

    context "when sorting by default (least recent)" do
      let(:settings) do
        {
          "order" => "default"
        }
      end

      it "shows up initiatives ordered by published_at" do
        expect(subject).not_to eq(most_recent_initiative)
      end
    end
  end
end
