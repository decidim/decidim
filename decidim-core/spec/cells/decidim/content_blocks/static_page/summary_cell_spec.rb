# frozen_string_literal: true

require "spec_helper"

describe Decidim::ContentBlocks::StaticPage::SummaryCell, type: :cell do
  subject { cell(content_block.cell, content_block).call }

  let(:organization) { create(:organization) }
  let(:static_page) { create(:static_page, organization:) }
  let(:content_block) { create(:content_block, organization:, manifest_name: :summary, scope_name: :static_page, scoped_resource_id: static_page.id, settings:) }
  let(:settings) do
    {
      "summary_en" => html_content
    }
  end

  controller Decidim::PagesController

  context "when the content contains safe HTML" do
    let(:html_content) { "<p>Summary with <a href='/about'>link</a></p>" }

    it "renders the allowed HTML tags" do
      expect(subject).to have_css("p")
      expect(subject).to have_link("link", href: "/about")
    end
  end

  context "when the content contains a script tag" do
    let(:html_content) { "<p>Summary</p><script>document.cookie</script>" }

    it "strips the script tag" do
      expect(subject).to have_text("Summary")
      expect(subject.to_s).not_to include("<script>")
    end
  end

  context "when the content contains an event handler attribute" do
    let(:html_content) { '<img src="x" onerror="alert(1)">' }

    it "strips the event handler" do
      expect(subject.to_s).not_to include("onerror")
    end
  end
end
