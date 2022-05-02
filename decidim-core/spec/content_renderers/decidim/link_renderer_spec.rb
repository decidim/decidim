# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ContentRenderers::LinkRenderer do
    let(:renderer) { described_class.new(content) }
    let(:urls) do
      %w(
        http://example.com/SystemTestHtmlScreenshotsurl
        https://example.com/url
        http://localhost:3000/some/url
        http://example.com/引き割り.html
        http://example.com/%E5%BC%95%E3%81%8D%E5%89%B2%E3%82%8A.html
        https://ëxämplö.com
        http://www.example.technology/about/
        http://en.wikipedia.org/wiki/Sprite_(computer_graphics)
      )
    end

    describe "#render" do
      context "when content is hello world" do
        let(:content) { "Hello world!" }

        it "renders hello world" do
          expect(renderer.render).to eq(content)
        end
      end

      describe "options" do
        let(:options) { { domain: "meta.decidim.org", target: "_blank" } }
        let(:url) { "https://meta.decidim.org" }
        let(:content) { "foo #{url} bar" }

        it "does not include target" do
          expect(renderer.render(options)).to eq("foo <a href=\"#{url}\" rel=\"nofollow noopener noreferrer ugc\">#{url}</a> bar")
        end
      end

      describe "just a link" do
        it "renders link tag" do
          urls.each do |url|
            rendered = described_class.new(url).render
            expect(rendered).to eq("<a href=\"#{url}\" target=\"_blank\" rel=\"nofollow noopener noreferrer ugc\">#{url}</a>")
          end
        end
      end

      describe "text before link" do
        it "renders text and link tag" do
          urls.each do |url|
            text = ::Faker::Lorem.sentence
            rendered = described_class.new("#{text} #{url}").render
            expect(rendered).to eq("#{text} <a href=\"#{url}\" target=\"_blank\" rel=\"nofollow noopener noreferrer ugc\">#{url}</a>")
          end
        end
      end

      describe "single punctuation after link" do
        let(:punctuations) { %w(, . ; - ] [ } { ( )) }

        it "renders punctuation after the link" do
          urls.each do |url|
            punctuations.each do |punctuation|
              rendered = described_class.new("#{url}#{punctuation}").render
              expect(rendered).to eq("<a href=\"#{url}\" target=\"_blank\" rel=\"nofollow noopener noreferrer ugc\">#{url}</a>#{punctuation}")
            end
          end
        end
      end

      describe "text after link" do
        it "renders link tag and text" do
          urls.each do |url|
            text = ::Faker::Lorem.sentence
            rendered = described_class.new("#{url} #{text}").render
            expect(rendered).to eq("<a href=\"#{url}\" target=\"_blank\" rel=\"nofollow noopener noreferrer ugc\">#{url}</a> #{text}")
          end
        end
      end

      describe "link between texts" do
        it "renders link tag and text" do
          urls.each do |url|
            before_text = ::Faker::Lorem.paragraph
            after_text = ::Faker::Lorem.sentence
            rendered = described_class.new("#{before_text} #{url} #{after_text}").render
            expect(rendered).to eq("#{before_text} <a href=\"#{url}\" target=\"_blank\" rel=\"nofollow noopener noreferrer ugc\">#{url}</a> #{after_text}")
          end
        end
      end

      describe "link is not seperated with spaces" do
        it "doesnt render a tag" do
          urls.each do |url|
            before_text = ::Faker::Lorem.sentence
            after_text = ::Faker::Lorem.paragraph
            rendered = described_class.new("#{before_text}#{url}#{after_text}").render
            expect(rendered).to eq("#{before_text}<a href=\"#{url + after_text.split.first}\" target=\"_blank\" rel=\"nofollow noopener noreferrer ugc\">#{url + after_text.split.first}</a> #{after_text.split.drop(1).join(" ")}")
          end
        end
      end
    end
  end
end
