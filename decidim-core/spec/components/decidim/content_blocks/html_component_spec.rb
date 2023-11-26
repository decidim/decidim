# frozen_string_literal: true

require "spec_helper"

describe Decidim::ContentBlocks::HtmlComponent, type: :component do
  subject { described_class.new(content_block) }

  let(:organization) { create(:organization) }
  let(:content_block) { create(:content_block, organization:, manifest_name: :html, scope_name: :homepage, settings:) }

  controller Decidim::PagesController

  context "when the content block has customized the welcome text setting value" do
    let(:settings) do
      {
        "html_content_en" => '<p class="text-center">This is my welcome text</p> <h2>Test</h2>'
      }
    end

    it "shows the custom welcome text" do
      content = render_inline(subject).to_s

      expect(content).to include('<p class="text-center">This is my welcome text</p>')
      expect(content).to include('<h2>Test</h2>')
    end
  end
end
