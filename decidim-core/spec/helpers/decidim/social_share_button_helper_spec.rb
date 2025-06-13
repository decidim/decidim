# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe SocialShareButtonHelper do
    let(:args) { { url: "http://example.org" } }
    let(:result) { helper.social_share_button_tag("Hello", **args) }

    describe "render_social_share_buttons" do
      context "when there is not any service" do
        before do
          allow(Decidim.config).to receive(:social_share_services).and_return([])
        end

        it "does not render anything" do
          expect(result).to be_nil
        end
      end

      context "when there is only a service" do
        before do
          allow(Decidim.config).to receive(:social_share_services).and_return(%w(X))
        end

        it "renders the correct HTML" do
          expect(result).to include("Share to X")
          expect(result).to include("https://twitter.com/intent/tweet?url=http%3A%2F%2Fexample.org&amp;text=Hello")
          expect(result).to include(".svg")
        end
      end

      context "when there are multiple services" do
        before do
          allow(Decidim.config).to receive(:social_share_services).and_return(%w(X Facebook WhatsApp))
        end

        it "renders the correct HTML" do
          expect(result).to include("Share to X")
          expect(result).to include("Share to Facebook")
          expect(result).to include("Share to WhatsApp")
          expect(result).to include("https://twitter.com/intent/tweet?url=http%3A%2F%2Fexample.org&amp;text=Hello")
          expect(result).to include("http://www.facebook.com/sharer/sharer.php?u=http%3A%2F%2Fexample.org")
          expect(result).to include("https://api.whatsapp.com/send?text=Hello%0Ahttp%3A%2F%2Fexample.org")
          expect(result).to include(".svg")
        end
      end
    end

    describe "render_social_share_button" do
      context "with email" do
        before do
          allow(Decidim.config).to receive(:social_share_services).and_return(%w(Email))
        end

        it "renders the correct HTML" do
          expect(result).to include("Share to Email")
          expect(result).to include("mailto:?subject=Hello&amp;body=http%3A%2F%2Fexample.org")
          expect(result).to include(".svg")
        end
      end

      context "with X and all optional params" do
        let(:args) { { url: "http://example.org", via: "Decidim" } }

        before do
          allow(Decidim.config).to receive(:social_share_services).and_return(%w(X))
        end

        it "renders the correct HTML" do
          expect(result).to include("Share to X")
          expect(result).to include("https://twitter.com/intent/tweet?url=http%3A%2F%2Fexample.org&amp;text=Hello&amp;via=Decidim")
          expect(result).to include(".svg")
        end
      end
    end
  end
end
