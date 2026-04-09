# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ContentRenderers::BaseRenderer do
    let(:renderer_class) do
      Class.new(described_class) do
        def render(skip_ancestor_tags: %w(code pre script style), on_missing: "", raise_on_match: false)
          replace_pattern_by_context(content, /TOKEN/, skip_ancestor_tags:, on_missing:) do |_match, context|
            raise ActiveRecord::RecordNotFound if raise_on_match

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
            <code data-reference="TOKEN"><span data-reference="TOKEN">TOKEN</span></code>
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
          expect(rendered.at_css("code span").text).to eq("TOKEN")
          expect(rendered.at_css("code span")["data-reference"]).to eq("TOKEN")
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

      context "when text node contains escaped HTML alongside a token" do
        let(:content) { "<p>&lt;script&gt;alert(1)&lt;/script&gt; TOKEN</p>" }

        it "keeps escaped html as plain text and does not promote it to live markup" do
          rendered = Loofah.fragment(renderer.render)
          p_node = rendered.at_css("p")

          expect(p_node.at_css("script")).to be_nil
          expect(p_node.text).to include("<script>alert(1)</script>")
          expect(p_node.at_css("strong").text).to eq("TEXT")
        end
      end

      context "when replacement raises RecordNotFound" do
        let(:content) { "<p>TOKEN</p>" }

        it "uses static on_missing fallback" do
          expect(renderer.render(raise_on_match: true, on_missing: "MISSING")).to eq("<p>MISSING</p>")
        end

        it "uses callable on_missing fallback" do
          on_missing = ->(match, _context) { "missing:#{match.downcase}" }

          expect(renderer.render(raise_on_match: true, on_missing:)).to eq("<p>missing:token</p>")
        end
      end
    end
  end
end
