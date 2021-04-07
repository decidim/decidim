# frozen_string_literal: true

require "spec_helper"

describe "Accessibility tool", type: :system do
  let(:organization) { create(:organization) }

  let(:template_class) do
    Class.new(ActionView::Base) do
      def protect_against_forgery?
        false
      end
    end
  end
  let(:template) { template_class.new }

  let(:html_document) do
    document_inner = html_body
    template.instance_eval do
      js_config = { icons_path: image_path("decidim/icons.svg") }

      <<~HTML.strip
        <!doctype html>
        <html lang="en">
        <head>
          <title>Accessibility Test</title>
          #{stylesheet_link_tag "application"}
          #{javascript_include_tag "application"}
          #{stylesheet_link_tag "decidim/dev"}
          #{javascript_include_tag "decidim/dev"}
        </head>
        <body>
          #{document_inner}

          <script>
          Decidim.config.set(#{js_config.to_json});
          </script>
        </body>
        </html>
      HTML
    end
  end
  let(:html_body) do
    <<~HTML.strip
      <p>This page is not <span id="color_contrast" style="color:#fff;">accessible</span></p>
    HTML
  end

  before do
    # Create a temporary route to display the generated HTML in a correct site
    # context.
    final_html = html_document
    Rails.application.routes.draw do
      get "accessibility_tool", to: ->(_) { [200, {}, [final_html]] }
    end

    switch_to_host(organization.host)
    visit "/accessibility_tool"
  end

  after do
    # Reset the routes back to original
    Rails.application.reload_routes!
  end

  RSpec::Matchers.define :have_accessibility_violation do |violation_id|
    match do |container|
      expect(container).to have_selector(
        ".decidim-accessibility-report-item[data-accessibility-violation='#{violation_id}']"
      )
    end

    failure_message do
      "expected to find accessibility violation #{violation_id} within the container"
    end
  end

  it "runs the accessibility tool and reports violations" do
    expect(page).to have_selector(".decidim-accessibility-badge")
    within ".decidim-accessibility-badge .decidim-accessibility-info" do
      expect(page).to have_content("4")
    end
    expect(page).not_to have_selector(".decidim-accessibility-report")

    find(".decidim-accessibility-badge").click
    expect(page).to have_selector(".decidim-accessibility-report")

    within ".decidim-accessibility-report" do
      expect(page).to have_css(".decidim-accessibility-report-item", count: 4)
      expect(page).to have_accessibility_violation("color-contrast")
      expect(page).to have_accessibility_violation("landmark-one-main")
      expect(page).to have_accessibility_violation("page-has-heading-one")
      expect(page).to have_accessibility_violation("region")

      within ".decidim-accessibility-report-item[data-accessibility-violation='color-contrast']" do
        expect(page).to have_content("Nodes:\n#color_contrast")
      end
    end
  end

  context "with accessible content" do
    let(:html_body) do
      <<~HTML.strip
        <header>
          <a href="#content">Skip to main content</a>
        </header>
        <main id="content">
          <h1>Accessible page</h1>
          <p>This page is very accessible</p>
        </main>
      HTML
    end

    it "runs the accessibility tool and reports violations" do
      expect(page).to have_selector(".decidim-accessibility-badge")
      within ".decidim-accessibility-badge .decidim-accessibility-info" do
        expect(page).to have_selector(".icon--check")
      end
      expect(page).not_to have_selector(".decidim-accessibility-report")

      find(".decidim-accessibility-badge").click
      expect(page).to have_selector(".decidim-accessibility-report")

      within ".decidim-accessibility-report" do
        expect(page).to have_content("No accessibility violations found")
      end
    end
  end
end
