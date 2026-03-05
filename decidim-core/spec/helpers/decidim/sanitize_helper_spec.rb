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

      context "when decidim_transform_image_urls is invoked" do
        let(:host) { "example.org" }

        let(:user_input) do
          %{(<p>Hello, %{name}</p>
          <a href="https://meta.decidim.org">Link</a>
          <img src="/rails/active_storage/blobs/redirect/12345.JPG" alt="image" />
          <a href="https://meta.decidim.org/">Link</a>
          <img src="/rails/active_storage/blobs/redirect/56789.JPG" alt="second image" />)}
        end

        subject { helper.send(:decidim_transform_image_urls, user_input, host) }

        it "transforms image URLs with the host" do
          root_url = Decidim::EngineRouter.new("decidim", {}).root_url(host:)[0..-2]
          expect(subject).to include(%(<img src="#{root_url}/rails/active_storage/blobs/redirect/12345.JPG"))
          expect(subject).to include(%(<img src="#{root_url}/rails/active_storage/blobs/redirect/56789.JPG"))
        end

        context "when a relative src matches the suffix of an absolute URL" do
          let(:user_input) do
            %(<img src="/image.jpg" alt="relative" /><img src="https://example.com/image.jpg" alt="absolute" />)
          end

          it "transforms only the relative URL" do
            root_url = Decidim::EngineRouter.new("decidim", {}).root_url(host:)[0..-2]

            expect(subject).to include(%(<img src="#{root_url}/image.jpg" alt="relative" />))
            expect(subject).to include(%(<img src="https://example.com/image.jpg" alt="absolute" />))
          end
        end

        context "when src uses data/protocol-relative/cid URLs" do
          let(:user_input) do
            %(<img src="data:image/png;base64,AAAA" alt="data" />
<img src="//cdn.example.org/image.jpg" alt="protocol-relative" />
<img src="cid:logo@example.org" alt="cid" />)
          end

          it "keeps them unchanged" do
            expect(subject).to include(%(src="data:image/png;base64,AAAA"))
            expect(subject).to include(%(src="//cdn.example.org/image.jpg"))
            expect(subject).to include(%(src="cid:logo@example.org"))
          end
        end

        context "when src attribute is single-quoted" do
          let(:user_input) { "<img src='/image.jpg' alt='relative' />" }

          it "transforms the URL preserving single quotes" do
            root_url = Decidim::EngineRouter.new("decidim", {}).root_url(host:).chomp("/")
            expect(subject).to include(%(<img src='#{root_url}/image.jpg' alt='relative' />))
          end
        end

        context "when host is not present" do
          subject { helper.send(:decidim_transform_image_urls, user_input, nil) }

          it "returns the full content" do
            expect(subject).to eq user_input
          end
        end
      end
    end
  end
end
