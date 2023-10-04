# frozen_string_literal: true

require "spec_helper"

describe "Datepicker", type: :system do
  let!(:organization) { create(:organization) }

  let(:template_class) do
    Class.new(ActionView::Base) do
      def protect_against_forgery?
        false
      end
    end
  end

  let(:template) { template_class.new(ActionView::LookupContext.new(ActionController::Base.view_paths), {}, []) }
  let(:javascript) { template.javascript_pack_tag("redesigned_decidim_core", defer: false) }

  let(:html_document) do
    js = javascript
    template.instance_eval do
      <<~HTML.strip
        <!doctype html>
        <html lang="en">
        <head>
          <title>Datepicker Test</title>
          #{stylesheet_pack_tag "redesigned_decidim_core", media: "all"}
          #{stylesheet_pack_tag "decidim_dev"}
        </head>
        <body>
          <input type="datetime-local" id="example_input">
          <button type="submit" name="commit" class="button button_sm md:button__lg button__secondary">Create</button>
          #{js}
        </body>
        </html>
      HTML
    end
  end

  before do
    final_html = html_document

    Rails.application.routes.draw do
      mount Decidim::Core::Engine => "/"
      get "test_datepicker", to: ->(_) { [200, {}, [final_html]] }
    end

    switch_to_host(organization.host)

    visit "/test_datepicker"
  end

  after do
    expect_no_js_errors

    # Reset the routes back to original
    Rails.application.reload_routes!
  end

  context "when using pickers" do
    it "fills input fields correctly" do
      find(".calendar_button").click
      find('span > input[name="year"]').set("1994")
      select("January", from: "month").select_option
      find("td > span", text: "20", match: :first).click
      find(".pick_calendar").click

      find(".clock_button").click
      find(".hourup").click
      find(".minutedown").click
      find(".close_clock").click

      click_button "Create"
      expect(page).to have_field("example_input_time", with: "01:59")
      expect(page).to have_field("example_input_date", with: "20/01/1994")
      expect(page).to have_field("example_input", with: "1994-01-20T01:59", disabled: true)
    end
  end
end
