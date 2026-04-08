# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ContentRenderers::BaseRenderer do
    let(:renderer_class) do
      Class.new(described_class) do
        def render(skip_ancestor_tags: %w(code pre script style))
          replace_pattern_by_context(content, /TOKEN/, skip_ancestor_tags:) do |_match, context|
            context.attribute? ? "ATTR" : "<strong>TEXT</strong>"
          end
        end
      end
    end

    let(:renderer) { renderer_class.new(content) }

    describe "#replace_pattern_by_context" do
      context "with default skip_ancestor_tags" do
        let(:content) do
          <<~HTML.squish
            <p>TOKEN</p>
            <a href="TOKEN">link</a>
            <code data-reference="TOKEN">TOKEN</code>
            <pre>TOKEN</pre>
            <script>var token = "TOKEN";</script>
            <style>.sample{content:"TOKEN";}</style>
          HTML
        end

        it "replaces in text and attributes outside skipped tags" do
          rendered = Loofah.fragment(renderer.render)

          expect(rendered.at_css("p > strong").text).to eq("TEXT")
          expect(rendered.at_css("a")["href"]).to eq("ATTR")
        end

        it "does not replace inside skipped ancestor tags" do
          rendered = Loofah.fragment(renderer.render)

          expect(rendered.at_css("code").text).to eq("TOKEN")
          expect(rendered.at_css("code")["data-reference"]).to eq("TOKEN")
          expect(rendered.at_css("pre").text).to eq("TOKEN")
          expect(rendered.at_css("script").text).to include("TOKEN")
          expect(rendered.at_css("style").text).to include("TOKEN")
        end
      end

      context "with custom skip_ancestor_tags" do
        let(:content) do
          <<~HTML.squish
            <blockquote>TOKEN</blockquote>
            <code>TOKEN</code>
          HTML
        end

        it "respects the custom skipped tag list" do
          rendered = Loofah.fragment(renderer.render(skip_ancestor_tags: %w(blockquote)))

          expect(rendered.at_css("blockquote").text).to eq("TOKEN")
          expect(rendered.at_css("code > strong").text).to eq("TEXT")
        end
      end
    end
  end
end
