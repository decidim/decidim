# frozen_string_literal: true

require "spec_helper"

describe Decidim::ContentBlocks::SubHeroCell, type: :cell do
  subject { cell(content_block.cell, content_block).call }

  let(:organization) { create(:organization, description: description) }
  let(:content_block) { create :content_block, organization: organization, manifest_name: :sub_hero, scope_name: :homepage }

  controller Decidim::PagesController

  context "when description is not filled" do
    let(:description) { {} }

    it "displays nothing" do
      expect(subject).to have_no_css(".subhero")
    end
  end

  context "when description is filled" do
    let(:description) do
      {
        "en" => "<h2><strong>Bold titled text</strong></h2>"
      }
    end

    it "shows the custom welcome text with formating" do
      expect(subject).to have_css(".subhero")
      expect(subject.find("h2 strong")).to have_text("Bold titled text")
    end
  end
end
