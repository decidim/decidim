# frozen_string_literal: true

require "spec_helper"

describe AxeMatchers do
  let(:organization) { create(:organization) }

  let(:html_document) do
    <<~HTML.strip
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <title>Matcher Test</title>
      </head>
      <body>
        <div>
          <p>Plain HTML page</p>
        </div>
      </body>
      </html>
    HTML
  end

  before do
    # Create a temporary route to display the generated HTML in a correct site
    # context.
    final_html = html_document
    Rails.application.routes.draw do
      get "accessibility_matchers", to: ->(_) { [200, {}, [final_html]] }
    end

    switch_to_host(organization.host)
    visit "/accessibility_matchers"
  end

  after do
    # Reset the routes back to original
    Rails.application.reload_routes!
  end

  describe AxeMatchers::BeAxeClean do
    let(:matcher) { described_class.new }

    describe "#matches?" do
      subject { matcher.matches?(page) }

      it { is_expected.to be(false) }
    end

    describe "#failure_message" do
      subject do
        matcher.matches?(page)
        matcher.failure_message
      end

      let(:simplified_html) { html_document.sub(/<!DOCTYPE html>/, "").gsub(/\n\s*/, "") }
      let(:axe_version) { AxeMatchers.axe_mainline_version }

      it "formats the message correctly" do
        message = <<~MSG

          Found 3 accessibility violations:

          1) landmark-one-main: Document should have one main landmark (moderate)
              https://dequeuniversity.com/rules/axe/#{axe_version}/landmark-one-main?application=axeAPI
              The following 1 node violate this rule:

                  Selector: html
                  HTML: #{simplified_html}
                  Fix all of the following:
                  - Document does not have a main landmark


          2) page-has-heading-one: Page should contain a level-one heading (moderate)
              https://dequeuniversity.com/rules/axe/#{axe_version}/page-has-heading-one?application=axeAPI
              The following 1 node violate this rule:

                  Selector: html
                  HTML: #{simplified_html}
                  Fix all of the following:
                  - Page must have a level-one heading


          3) region: All page content should be contained by landmarks (moderate)
              https://dequeuniversity.com/rules/axe/#{axe_version}/region?application=axeAPI
              The following 1 node violate this rule:

                  Selector: div
                  HTML: <div><p>Plain HTML page</p></div>
                  Fix any of the following:
                  - Some page content is not contained by landmarks


        MSG

        expect(subject).to eq(message)
      end
    end
  end
end
