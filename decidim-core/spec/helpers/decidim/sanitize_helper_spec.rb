# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe SanitizeHelper, type: :helper do
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
    end
  end
end
