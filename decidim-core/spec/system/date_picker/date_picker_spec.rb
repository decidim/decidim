# frozen_string_literal: true

require "spec_helper"

describe "Datepicker", type: :system do
  let(:organization) { create(:organization) }

  let(:template_class) do
    Class.new(ActionView::Base) do
      def protect_against_forgery?
        false
      end
    end
  end

  let(:template) { template_class.new(ActionView::LookupContext.new(ActionController::Base.view_paths), {}, []) }

  let(:html_document) do
    template.instance_eval do
      js_config = { icons_path: asset_pack_path("media/images/icons.svg") }

      <<~HTML.strip
        <!doctype html>
        <html lang="en">
        <head>
          <title>Datepicker Test</title>
          #{stylesheet_pack_tag "redesigned_decidim_core"}
          #{stylesheet_pack_tag "decidim_dev"}
          #{javascript_pack_tag "redesigned_decidim_core", "decidim_dev", defer: false}
        </head>
        <body>
          <div>
            <input type="datetime-local" id="example_input">
            <button type="submit" name="commit" class="button button_sm md:button__lg button__secondary">Create</button>
          </div>
          <script>
            Decidim.config.set(#{js_config.to_json});
          </script>
        </body>
        </html>
      HTML
    end
  end

  before do
    final_html = html_document
    Rails.application.routes.draw do
      get "test_datepicker", to: ->(_) { [200, {}, [final_html]] }
    end

    switch_to_host(organization.host)
    visit "/test_datepicker"
  end

  after do
    # Reset the routes back to original
    Rails.application.reload_routes!
  end

  context "when using date picker" do
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
      expect(page).to have_field("example_input", with: "1994-01-20T01:59", visible: :all)
    end

    context "when opening datepicker for the first time" do
      it "has disabled select button" do
        find(".calendar_button").click
        expect(page).to have_button("Select", disabled: true)
      end

      context "when choosing a date" do
        it "enables the select button" do
          find(".calendar_button").click
          find("td > span", text: "20", match: :first).click
          expect(page).to have_button("Select", disabled: false)
        end
      end
    end

    context "when opening datepicker after having picked a date before" do
      it "has the previously picked date selected" do
        find(".calendar_button").click
        find('span > input[name="year"]').set("1994")
        select("January", from: "month").select_option
        find("td > span", text: "20", match: :first).click
        find(".pick_calendar").click
        find(".calendar_button").click
        element = find("td.wc-datepicker__date--selected")
        expect(element).to have_content("20")
        expect(page).to have_button("Select", disabled: true)
      end
    end

    context "when changing month" do
      it "disables select button even if date was picked" do
        find(".calendar_button").click
        find("td > span", text: "20", match: :first).click
        expect(page).to have_button("Select", disabled: false)
        select("January", from: "month").select_option
        expect(page).to have_button("Select", disabled: true)
      end
    end
  end

  context "when using timepicker" do
    context "when opening timepicker for the first time" do
      it "starts from zero" do
        find(".clock_button").click
        hour = find("input.hourpicker]")
        minute = find("input.minutepicker")
        expect(hour.value).to be("00")
        expect(minute.value).to be("00")
      end
    end

    context "when decreasing hour from zero" do
      it "turns to 23" do
        find(".clock_button").click
        find(".hourdown").click
        hour = find("input.hourpicker")
        expect(hour.value).to be("23")
      end
    end

    context "when decreasing minute from zero" do
      it "turns to 59" do
        find(".clock_button").click
        find(".minutedown").click
        minute = find("input.minutepicker")
        expect(minute.value).to be("59")
      end
    end

    context "when increasing hour from 23" do
      it "turns to zero" do
        find(".clock_button").click
        find(".hourdown").click
        find(".hourup").click
        hour = find("input.hourpicker")
        expect(hour.value).to be("00")
      end
    end

    context "when increasing minute from 59" do
      it "turns to zero" do
        find(".clock_button").click
        find(".minutedown").click
        find(".minuteup").click
        minute = find("input.minutepicker")
        expect(minute.value).to be("00")
      end
    end

    context "when resetting timepicker" do
      it "sets picker to zero and resets time input" do
        find(".clock_button").click
        find(".hourdown").click
        find(".minuteup").click
        click_button "Reset"
        hour = find("input.hourpicker")
        minute = find("input.minutepicker")
        time = find("input.timepicker")
        expect(hour).to be("00")
        expect(minute).to be("00")
        expect(time).to be("")
      end
    end

    context "when typing a time on timepicker" do
      it "sets picker to that time" do
        fill_in_timepicker :example_input_time, with: "21:15"
        find(".clock_button")
        hour = find("input.hourpicker")
        minute = find("input.minutepicker")
        expect(hour.value).to be("21")
        expect(minute.value).to be("15")
      end
    end
  end
end
