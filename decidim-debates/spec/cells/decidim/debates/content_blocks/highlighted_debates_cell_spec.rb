# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::ContentBlocks::HighlightedDebatesCell, type: :cell do
  subject { cell("decidim/debates/content_blocks/highlighted_debates", content_block).call }

  controller Decidim::Debates::DebatesController

  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, organization:) }
  let(:component) { create(:debates_component, participatory_space:) }
  let(:manifest_name) { :highlighted_debates }
  let(:scope_name) { :participatory_process_homepage }
  let(:content_block) { create(:content_block, organization:, manifest_name:, scope_name:, scoped_resource_id: participatory_space.id) }

  context "with 1 open debate" do
    let!(:debate) { create(:debate, title: { en: "Debate title" }, component:) }

    it "renders the open debate" do
      expect(subject).to have_content("Debate title")
      expect(subject).to have_css(".card__grid", count: 1)
    end
  end

  context "with 4 debates (3 open, 1 closed)" do
    let!(:debate_old) { create(:debate, title: { en: "Old Debate" }, component:, created_at: 1.year.ago, updated_at: 1.year.ago, closed_at: nil) }
    let!(:debate1) { create(:debate, title: { en: "Recent Debate 1" }, component:, created_at: 3.days.ago, updated_at: 3.days.ago) }
    let!(:debate2) { create(:debate, title: { en: "Recent Debate 2" }, component:, created_at: 2.days.ago, updated_at: 2.days.ago) }
    let!(:debate3) { create(:debate, title: { en: "Recent Debate 3" }, component:, created_at: 1.day.ago, updated_at: 1.day.ago) }
    let!(:debate_closed) { create(:debate, title: { en: "Closed Debate" }, component:, closed_at: 1.day.ago) }

    it "renders only 3 most recent open debates" do
      expect(subject).to have_no_content("Closed Debate")

      expect(subject).to have_no_content("Old Debate")

      expect(subject).to have_css(".card__grid", count: 3)
      expect(subject).to have_content("Recent Debate 1")
      expect(subject).to have_content("Recent Debate 2")
      expect(subject).to have_content("Recent Debate 3")
    end
  end

  context "with no debates" do
    it "renders nothing" do
      expect(subject).to have_no_content("Debate title")
      expect(subject).to have_no_css(".card__grid", count: 1)
    end
  end
end
