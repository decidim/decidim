# frozen_string_literal: true

require "spec_helper"

describe "Data consent scripts", type: :system do
  let(:orga) { create(:organization) }

  let(:template_class) do
    Class.new(ActionView::Base) do
      def protect_against_forgery?
        false
      end
    end
  end
  let(:template) { template_class.new(ActionView::LookupContext.new(ActionController::Base.view_paths), {}, []) }
  let(:modal) { Decidim::ViewModel.cell("decidim/data_consent", orga).call.to_s }

  let(:html_document) do
    cookie_modal = modal
    document_inner = html_body
    template.instance_eval do
      js_config = { icons_path: asset_pack_path("media/images/icons.svg") }

      <<~HTML.strip
        <!doctype html>
        <html lang="en">
        <head>
          <title>Accessibility Test</title>
          #{stylesheet_pack_tag "decidim_core"}
          #{javascript_pack_tag "decidim_core", defer: false}
          #{stylesheet_pack_tag "decidim_dev"}
          #{javascript_pack_tag "decidim_dev", defer: false}
        </head>
        <!-- Add some line breaks so that the "WAI WCAG" notification doesnt block screenshots -->
        <br><br><br><br><br>
        <body>
          #{cookie_modal}
          #{document_inner}
          <div class="footer">
            <a href="#" class="button" data-open="cc-modal">
              Cookie settings
            </a>
          </div>
          <script>
          Decidim.config.set(#{js_config.to_json});
          </script>
        </body>
        </html>
      HTML
    end
  end
  let(:html_body) { "" }

  before do
    # Create a temporary route to display the generated HTML in a correct site
    # context.
    final_html = html_document
    Rails.application.routes.draw do
      get "cookie_scripts", to: ->(_) { [200, {}, [final_html]] }
    end

    switch_to_host(orga.host)
    visit "/cookie_scripts"
  end

  after do
    # Reset the routes back to original
    Rails.application.reload_routes!
  end

  context "when managing cookies" do
    context "with content that has disabled javascript" do
      let(:html_body) do
        <<~HTML.strip
          <div id="test_root">
            <p>Hello cookies</p>
            <script type="text/plain" data-consent="essential">
              document.querySelector("#test_root").append(' #{essential_cookies_accepted} ');
            </script>
            <script type="text/plain" data-consent="preferences">
              document.querySelector("#test_root").append(' #{preferences_cookies_accepted} ');
            </script>
            <script type="text/plain" data-consent="analytics">
              document.querySelector("#test_root").append(' #{analytics_cookies_accepted} ');
            </script>
            <script type="text/plain" data-consent="marketing">
              document.querySelector("#test_root").append(' #{marketing_cookies_accepted} ');
            </script>
          </div>
        HTML
      end
      let(:essential_cookies_accepted) { "essential cookies accepted" }
      let(:preferences_cookies_accepted) { "preferences cookies accepted" }
      let(:analytics_cookies_accepted) { "analytics cookies accepted" }
      let(:marketing_cookies_accepted) { "marketing cookies accepted" }

      it "doesnt run scripts" do
        expect(page).to have_content("Hello cookies")
        expect(page).not_to have_content("cookies accepted")
      end

      context "when accept all cookies" do
        before { select_cookies(true) }

        it "runs scripts" do
          expect(page).to have_content(essential_cookies_accepted)
          expect(page).to have_content(preferences_cookies_accepted)
          expect(page).to have_content(analytics_cookies_accepted)
          expect(page).to have_content(marketing_cookies_accepted)
        end
      end

      context "when essential cookies only" do
        before { select_cookies(false) }

        it "runs scripts" do
          expect(page).to have_content(essential_cookies_accepted)
          expect(page).not_to have_content(preferences_cookies_accepted)
          expect(page).not_to have_content(analytics_cookies_accepted)
          expect(page).not_to have_content(marketing_cookies_accepted)
        end
      end

      context "when analytics cookies accepted" do
        before { select_cookies(%w(analytics)) }

        it "runs analytics scripts" do
          expect(page).to have_content(essential_cookies_accepted)
          expect(page).not_to have_content(preferences_cookies_accepted)
          expect(page).to have_content(analytics_cookies_accepted)
          expect(page).not_to have_content(marketing_cookies_accepted)
        end
      end
    end
  end
end
