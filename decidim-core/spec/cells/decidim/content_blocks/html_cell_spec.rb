# frozen_string_literal: true

require "spec_helper"

describe Decidim::ContentBlocks::HtmlCell, type: :cell do
  subject { cell(content_block.cell, content_block).call }

  let(:organization) { create(:organization) }
  let(:content_block) { create(:content_block, organization:, manifest_name: :html, scope_name: :homepage, settings:) }
  let(:settings) do
    {
      "html_content_en" => html_content
    }
  end

  controller Decidim::PagesController

  context "when the content contains safe HTML" do
    let(:html_content) { "<p>Hello <strong>world</strong></p>" }

    it "renders the allowed HTML tags" do
      expect(subject).to have_css("p")
      expect(subject).to have_css("strong", text: "world")
    end
  end

  context "when the content contains a script tag" do
    let(:html_content) { '<p>Safe content</p><script>alert("xss")</script>' }

    it "strips the script tag" do
      expect(subject).to have_text("Safe content")
      expect(subject.to_s).not_to include("<script>")
    end
  end

  context "when the content contains an event handler attribute" do
    let(:html_content) { '<p onmouseover="alert(1)">Hover me</p>' }

    it "strips the event handler" do
      expect(subject).to have_text("Hover me")
      expect(subject.to_s).not_to include("onmouseover")
    end
  end
end
