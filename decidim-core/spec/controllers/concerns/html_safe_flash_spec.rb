# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe "HtmlSafeFlash", type: :controller do
    let!(:organization) { create :organization }

    controller do
      include Decidim::HtmlSafeFlash

      def safe
        flash[:html_safe] = true
        # rubocop:disable Rails/I18nLocaleTexts
        flash[:notice] = "<p>HTML content</p>"
        # rubocop:enable Rails/I18nLocaleTexts
        render plain: "Hello World"
      end

      def unsafe
        # rubocop:disable Rails/I18nLocaleTexts
        flash[:notice] = "Decidim & Democracy"
        # rubocop:enable Rails/I18nLocaleTexts
        render plain: "Hello World"
      end

      def display
        # rubocop:disable Rails/RenderInline
        render inline: "<%= flash[:notice] %>"
        # rubocop:enable Rails/RenderInline
      end
    end

    before do
      request.env["decidim.current_organization"] = organization
      routes.draw do
        get "safe" => "anonymous#safe"
        get "unsafe" => "anonymous#unsafe"
        get "display" => "anonymous#display"
      end
    end

    it "displays the flash content as safe HTML" do
      get :safe
      get :display

      expect(flash[:notice].html_safe?).to be(true)
      expect(response.body).to eq("<p>HTML content</p>")
    end

    context "when the html_safe key is not set in the flash keys" do
      it "displays the message HTML escaped" do
        get :unsafe
        get :display

        expect(flash[:notice].html_safe?).to be(false)
        expect(response.body).to eq("Decidim &amp; Democracy")
      end
    end
  end
end
