# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe SocialShareButtonHelper do
    let(:args) { { url: "http://example.org" } }
    let(:result) { helper.social_share_button_tag("Hello", **args) }

    describe "social_share_button_tag" do
      it "renders the class" do
        expect(result).to include("social-share-button")
      end
    end

    describe "render_social_share_buttons" do
      context "when there isn't any service" do
        before do
          allow(Decidim.config).to receive(:social_share_services).and_return([])
        end

        it "doesn't render anything" do
          expect(result).to be_nil
        end
      end

      context "when there's only a service" do
        before do
          allow(Decidim.config).to receive(:social_share_services).and_return(%w(Twitter))
        end

        it "renders the correct HTML" do
          expect(result).to include("Share to Twitter")
          expect(result).to include("https://twitter.com/intent/tweet?url=http%3A%2F%2Fexample.org&amp;text=Hello")
          expect(result).to include(".svg")
        end
      end

      context "when there are multiple services" do
        before do
          allow(Decidim.config).to receive(:social_share_services).and_return(%w(Twitter Facebook WhatsApp))
        end

        it "renders the correct HTML" do
          expect(result).to include("Share to Twitter")
          expect(result).to include("Share to Facebook")
          expect(result).to include("Share to WhatsApp")
          expect(result).to include("https://twitter.com/intent/tweet?url=http%3A%2F%2Fexample.org&amp;text=Hello")
          expect(result).to include("http://www.facebook.com/sharer/sharer.php?u=http%3A%2F%2Fexample.org")
          expect(result).to include("https://api.whatsapp.com/send?text=Hello%0Ahttp%3A%2F%2Fexample.org")
          expect(result).to include(".svg")
        end
      end
    end
  end
end
