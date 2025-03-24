# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe SanitizeHelper do
    describe "#decidim_sanitize" do
      let(:user_input) { "<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>" }

      context "when option strip_tags is invoked" do
        it "strips the tags from the target string" do
          expect(helper.decidim_sanitize(user_input, strip_tags: true)).not_to include("<p>")
          expect(helper.decidim_sanitize(user_input, strip_tags: true)).not_to include("</p>")
          expect(helper.decidim_sanitize_newsletter(user_input, strip_tags: true)).not_to include("<p>")
          expect(helper.decidim_sanitize_newsletter(user_input, strip_tags: true)).not_to include("</p>")
        end

        context "when there is no tags in user_input" do
          let(:user_input) { "Lorem ipsum dolor sit amet, consectetur adipiscing elit." }

          it "does not strip the target string" do
            expect(helper.decidim_sanitize(user_input, strip_tags: true)).to eq(user_input)
            expect(helper.decidim_sanitize_newsletter(user_input, strip_tags: true)).to eq(user_input)
          end
        end

        context "when strip_tags is false" do
          let(:user_input) { "Lorem ipsum dolor sit amet, consectetur adipiscing elit." }

          it "does not strip the target string" do
            expect(helper.decidim_sanitize(user_input, strip_tags: false)).to eq(user_input)
            expect(helper.decidim_sanitize_newsletter(user_input, strip_tags: false)).to eq(user_input)
          end
        end
      end

      context "when option strip_tag is not invoked" do
        it "does not strip the target string" do
          expect(helper.decidim_sanitize(user_input)).to include("<p>")
          expect(helper.decidim_sanitize(user_input)).to include("</p>")
          expect(helper.decidim_sanitize(user_input)).to eq(user_input)
          expect(helper.decidim_sanitize_newsletter(user_input)).to include("<p>")
          expect(helper.decidim_sanitize_newsletter(user_input)).to include("</p>")
          expect(helper.decidim_sanitize_newsletter(user_input)).to eq(user_input)
        end
      end

      context "when url_escape is invoked" do
        it "escapes javascript: in the URL" do
          expect(helper.decidim_url_escape("javascript:alert('hello')")).to eq("alert(&#39;hello&#39;)")
        end

        it "escapes javascript: prepended by a line break in the URL" do
          expect(helper.decidim_url_escape("\njavascript:alert('hello')")).to eq("alert(&#39;hello&#39;)")
        end

        it "escapes javascript: prepended by an empty space in the URL" do
          expect(helper.decidim_url_escape(" javascript:alert('hello')")).to eq("alert(&#39;hello&#39;)")
        end
      end

      context "when sanitize_text is invoked with dangerous strings" do
        it "escapes script tags" do
          expect(helper.decidim_sanitize("<script>alert('hello')</script>", strip_tags: false)).not_to include("<script>")
        end

        it "removes event handlers from HTML attributes" do
          expect(helper.decidim_sanitize("<img src=\"#\" onerror=\"alert('XSS')\">", strip_tags: false)).not_to include("onerror")
        end

        it "removes nested event handlers in HTML" do
          expect(helper.decidim_sanitize("<a href=\"#\"><img src=\"x\" onerror=\"alert('XSS')\"></a>", strip_tags: false)).not_to include("onerror")
        end

        it "removes dangerous CSS in style attributes" do
          expect(helper.decidim_sanitize("<div style=\"background-image: url(javascript:alert('XSS'))\">", strip_tags: false)).not_to include("javascript:")
        end

        it "escapes special characters like &lt; and &gt;" do
          expect(helper.decidim_sanitize("&lt;script&gt;alert('XSS')&lt;/script&gt;", strip_tags: false)).not_to include("<script>")
        end

        it "removes javascript URIs from links" do
          expect(helper.decidim_sanitize("<a href=\"javascript:alert('XSS')\">click me</a>", strip_tags: false)).not_to include("javascript:")
        end

        it "removes event handlers from attributes" do
          expect(helper.decidim_sanitize("<div id=\"XSS\" onmouseover=\"alert('XSS')\">", strip_tags: false)).not_to include("onmouseover")
        end

        it "sanitizes hex-encoded scripts" do
          expect(helper.decidim_sanitize("&#x3C;script&#x3E;alert('XSS')&#x3C;/script&#x3E;", strip_tags: false)).not_to include("<script>")
        end

        it "sanitizes URL-encoded scripts" do
          expect(helper.decidim_sanitize("%3Cscript%3Ealert('XSS')%3C%2Fscript%3E", strip_tags: false)).not_to include("<script>")
        end

        it "removes script inside HTML comments" do
          expect(helper.decidim_sanitize("<!--<script>alert('XSS')</script>-->", strip_tags: false)).not_to include("<script>")
        end

        it "removes base64-encoded scripts" do
          expect(helper.decidim_sanitize('<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUA..." onerror="alert(\'XSS\')">', strip_tags: false)).not_to include("onerror")
        end
      end
    end
  end
end
