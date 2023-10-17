# frozen_string_literal: true

require "spec_helper"

describe "Datepicker", type: :system do
  let(:organization) { create(:organization) }
  let(:datepicker_content) { "" }
  let(:record) { OpenStruct.new(body: datepicker_content) }
  let(:form) { Decidim::FormBuilder.new(:example, record, template, {}) }

  let(:template_class) do
    Class.new(ActionView::Base) do
      def protect_against_forgery?
        false
      end
    end
  end

  let(:template) { template_class.new(ActionView::LookupContext.new(ActionController::Base.view_paths), {}, []) }

  let(:html_document) do
    datepicker_wrapper = form.datetime_field(:input)
    content_wrapper = <<~HTML
      <div data-content>
        <main class="layout-1col">
          <div class="cols-6">
            <div class="text-center py-12">
              <h1 class="h1 decorator inline-block text-left">Datepicker test</h1>
            </div>
            <div class="page__container">
              <form action="/form_action" method="post">
                #{datepicker_wrapper}
              </form>
            </div>
            <button type="submit" name="commit" class="button button_sm md:button__lg button__secondary">Create</button>
            <input type="text" id="example_input_clipboard">
          </div>
        </main>
      </div>
    HTML

    template.instance_eval do
      js_config = {
        icons_path: asset_pack_path("media/images/remixicon.symbol.svg"),
        messages: {
          editor: I18n.t("editor"),
          selfxssWarning: I18n.t("decidim.security.selfxss_warning"),
          date: I18n.t("date"),
          time: I18n.t("time")
        }
      }

      <<~HTML.strip
        <!doctype html>
        <html lang="en">
        <head>
          <title>Datepicker Test</title>
          #{stylesheet_pack_tag "decidim_core"}
          #{stylesheet_pack_tag "decidim_dev"}
          #{javascript_pack_tag "decidim_core", "decidim_dev", defer: false}
        </head>
        <body>
          #{content_wrapper}
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

  context "when date format dd.mm.yyyy and clock format 24" do
    context "when filling form datetime input with datepicker" do
      it "fills the field correctly" do
        find(".calendar_button").click
        find('span > input[name="year"]').set("1994")
        select("January", from: "month").select_option
        find("td > span", text: "20", match: :first).click
        find(".pick_calendar").click

        find(".clock_button").click
        find(".hourup").click
        find(".minutedown").click
        find(".close_clock").click

        expect(page).to have_field("example_input_time", with: "01:59")
        expect(page).to have_field("example_input_date", with: "20.01.1994")
        expect(page).to have_field("example_input", with: "1994-01-20T01:59", visible: :all)
      end
    end

    context "when choosing date" do
      context "when using picker" do
        context "when opening datepicker" do
          it "shows the datepicker calendar" do
            find(".calendar_button").click
            expect(page).to have_selector("#example_input_date_datepicker")
          end

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

        context "when closing datepicker" do
          it "hides the datepicker calendar" do
            find(".calendar_button").click
            expect(page).to have_selector("#example_input_date_datepicker")
            find(".close_calendar").click
            expect(page).to have_selector("#example_input_date_datepicker", visible: :hidden)
          end
        end

        context "when opening datepicker with an existing date" do
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

      context "when using input field" do
        context "when typing a correct date" do
          it "sets the date on the datepicker calendar" do
            fill_in_datepicker :example_input_date, with: "24.11.2012"
            find(".calendar_button").click
            year = find('span > input[name="year"]')
            month = find('select[name="month"]')
            date = find("td.wc-datepicker__date--selected")
            expect(year.value).to eq("2012")
            expect(month).to have_content("November")
            expect(date).to have_content("24")
          end

          it "only allows typing numbers and separators" do
            fill_in_datepicker :example_input_date, with: "24!\"#.abcloktpes11¤%&.()=2012:"
            expect(page).to have_field("example_input_date", with: "24.11.2012")
          end
        end

        context "when typing correct date with '/' -separator" do
          it "replaces separator with the format's correct separator" do
            fill_in_datepicker :example_input_date, with: "24/11/2012"
            expect(page).to have_field("example_input_date", with: "24/11/2012")
            find("#example_input_time").click
            expect(page).to have_field("example_input_date", with: "24.11.2012")
          end
        end

        context "when pasting a correct format date to date input field" do
          context "when pasting with the correct separator" do
            it "pastes the date to the input field" do
              fill_in :example_input_clipboard, with: "24.11.2012"

              clipboard = find("#example_input_clipboard")
              clipboard.send_keys [:control, "a"]
              clipboard.send_keys [:control, "c"]
              find("#example_input_date").send_keys [:control, "v"]
              expect(page).to have_field("example_input_date", with: "24.11.2012")
            end
          end

          context "when pasting with incorrect separator" do
            it "pastes the date to the input field with the correct separator" do
              fill_in :example_input_clipboard, with: "24/11/2012"

              clipboard = find("#example_input_clipboard")
              clipboard.send_keys [:control, "a"]
              clipboard.send_keys [:control, "c"]
              find("#example_input_date").send_keys [:control, "v"]
              expect(page).to have_field("example_input_date", with: "24.11.2012")

              fill_in :example_input_clipboard, with: "24-11-2012"

              clipboard.send_keys [:control, "a"]
              clipboard.send_keys [:control, "c"]
              find("#example_input_date").send_keys [:control, "v"]
              expect(page).to have_field("example_input_date", with: "24.11.2012")
            end
          end
        end

        context "when pasting an incorrect value to date input field" do
          it "doesn't paste anything" do
            fill_in :example_input_clipboard, with: "99.99.9999"

            clipboard = find("#example_input_clipboard")
            clipboard.send_keys [:control, "a"]
            clipboard.send_keys [:control, "c"]
            find("#example_input_date").send_keys [:control, "v"]
            expect(page).to have_field("example_input_date", with: "")
          end
        end
      end
    end

    context "when choosing time" do
      context "when using picker" do
        context "when opening timepicker" do
          it "shows the timepicker" do
            find(".clock_button").click
            expect(page).to have_selector("#example_input_time_timepicker")
          end

          it "starts from zero" do
            find(".clock_button").click
            hour = find("input.hourpicker")
            minute = find("input.minutepicker")
            expect(hour.value).to eq("00")
            expect(minute.value).to eq("00")
          end
        end

        context "when closing timepicker" do
          it "hides the timepicker" do
            find(".clock_button").click
            expect(page).to have_selector("#example_input_time_timepicker")
            find(".close_clock").click
            expect(page).to have_selector("#example_input_time_timepicker", visible: :hidden)
          end
        end

        context "when decreasing hour from zero" do
          it "turns to 23" do
            find(".clock_button").click
            find(".hourdown").click
            hour = find("input.hourpicker")
            expect(hour.value).to eq("23")
          end
        end

        context "when decreasing minute from zero" do
          it "turns to 59" do
            find(".clock_button").click
            find(".minutedown").click
            minute = find("input.minutepicker")
            expect(minute.value).to eq("59")
          end
        end

        context "when increasing hour from 23" do
          it "turns to zero" do
            find(".clock_button").click
            hour = find("input.hourpicker")
            find(".hourdown").click
            expect(hour.value).to eq("23")
            find(".hourup").click
            expect(hour.value).to eq("00")
          end
        end

        context "when increasing minute from 59" do
          it "turns to zero" do
            find(".clock_button").click
            find(".minutedown").click
            minute = find("input.minutepicker")
            expect(minute.value).to eq("59")
            find(".minuteup").click
            expect(minute.value).to eq("00")
          end
        end

        context "when resetting timepicker" do
          it "sets picker to zero and resets time input" do
            find(".clock_button").click
            find(".hourdown").click
            find(".minuteup").click
            hour = find("input.hourpicker")
            minute = find("input.minutepicker")
            expect(page).to have_field("example_input_time", with: "23:01")
            click_button "Reset"
            expect(hour.value).to eq("00")
            expect(minute.value).to eq("00")
            expect(page).to have_field("example_input_time", with: "")
          end
        end
      end

      context "when using input field" do
        context "when typing value to time input field" do
          it "updates picker's time" do
            fill_in_timepicker :example_input_time, with: "21:15"
            find(".clock_button").click
            hour = find("input.hourpicker")
            minute = find("input.minutepicker")
            expect(hour.value).to eq("21")
            expect(minute.value).to eq("15")
          end

          it "only allows typing numbers and colon" do
            fill_in_timepicker :example_input_time, with: "/.!\"#¤%&()=?abcert21jkl:mn22"
            expect(page).to have_field("example_input_time", with: "21:22")
          end

          it "doesn't update picker's time if not a correct value" do
            fill_in_timepicker :example_input_time, with: "99:99"
            find(".clock_button").click
            hour = find("input.hourpicker")
            minute = find("input.minutepicker")
            expect(hour.value).to eq("00")
            expect(minute.value).to eq("00")
          end
        end
# TIME PASTE  TIME PASTE  TIME PASTE  TIME PASTE  TIME PASTE
        context "when pasting a correct format date to date input field" do
          context "when pasting with the correct separator" do
            it "pastes the date to the input field" do
              fill_in :example_input_clipboard, with: "24.11.2012"

              clipboard = find("#example_input_clipboard")
              clipboard.send_keys [:control, "a"]
              clipboard.send_keys [:control, "c"]
              find("#example_input_date").send_keys [:control, "v"]
              expect(page).to have_field("example_input_date", with: "24.11.2012")
            end
          end

          context "when pasting with incorrect separator" do
            it "pastes the date to the input field with the correct separator" do
              fill_in :example_input_clipboard, with: "24/11/2012"

              clipboard = find("#example_input_clipboard")
              clipboard.send_keys [:control, "a"]
              clipboard.send_keys [:control, "c"]
              find("#example_input_date").send_keys [:control, "v"]
              expect(page).to have_field("example_input_date", with: "24.11.2012")

              fill_in :example_input_clipboard, with: "24-11-2012"

              clipboard.send_keys [:control, "a"]
              clipboard.send_keys [:control, "c"]
              find("#example_input_date").send_keys [:control, "v"]
              expect(page).to have_field("example_input_date", with: "24.11.2012")
            end
          end
        end

        context "when pasting an incorrect value to date input field" do
          it "doesn't paste anything" do
            fill_in :example_input_clipboard, with: "99.99.9999"

            clipboard = find("#example_input_clipboard")
            clipboard.send_keys [:control, "a"]
            clipboard.send_keys [:control, "c"]
            find("#example_input_date").send_keys [:control, "v"]
            expect(page).to have_field("example_input_date", with: "")
          end
        end
      end
      # TIME PASTE  TIME PASTE  TIME PASTE  TIME PASTE
    end
  end

  context "when date format mm.dd.yyyy and clock format 12" do
    let(:html_document) do
      datepicker_wrapper = form.datetime_field(:input)
      content_wrapper = <<~HTML
        <div data-content>
          <main class="layout-1col">
            <div class="cols-6">
              <div class="text-center py-12">
                <h1 class="h1 decorator inline-block text-left">Datepicker test</h1>
              </div>
              <div class="page__container">
                <form action="/form_action" method="post">
                  #{datepicker_wrapper}
                </form>
              </div>
              <button type="submit" name="commit" class="button button_sm md:button__lg button__secondary">Create</button>
              <input type="text" id="example_input_clipboard">
            </div>
          </main>
        </div>
      HTML

      template.instance_eval do
        js_config = {
          icons_path: asset_pack_path("media/images/remixicon.symbol.svg"),
          messages: {
            editor: I18n.t("editor"),
            selfxssWarning: I18n.t("decidim.security.selfxss_warning"),
            date: {
              formats: {
                decidim_short: "%m/%d/%Y",
                help: {
                  date_format: "Format: mm.dd.yy"
                }
              }
            },
            time: {
              clock_format: 12,
              formats: {
                help: {
                  time_format: "Format: hh:mm"
                }
              }
            }
          }
        }
        <<~HTML.strip
          <!doctype html>
          <html lang="en">
          <head>
            <title>Datepicker Test</title>
            #{stylesheet_pack_tag "decidim_core"}
            #{stylesheet_pack_tag "decidim_dev"}
            #{javascript_pack_tag "decidim_core", "decidim_dev", defer: false}
          </head>
          <body>
            #{content_wrapper}
            <script>
              Decidim.config.set(#{js_config.to_json});
            </script>
          </body>
          </html>
        HTML
      end
    end

    context "when filling form datetime input with datepicker" do
      it "fills the field correctly" do
        find(".calendar_button").click(x: 10, y: 10)
        find('span > input[name="year"]').set("1994")
        select("January", from: "month").select_option
        find("td > span", text: "20", match: :first).click
        find(".pick_calendar").click

        find(".clock_button").click
        find(".hourup").click
        find(".minutedown").click
        find(".close_clock").click

        expect(page).to have_field("example_input_date", with: "01/20/1994")
        expect(page).to have_field("example_input_time", with: "02:59")
        expect(page).to have_field("example_input", with: "1994-01-20T02:59", visible: :all)
      end

      context "when time is set to AM" do
        it "inputs the correct value" do
          fill_in_datepicker :example_input_date, with: "01/20/1994"
          fill_in_timepicker :example_input_time, with: "02:59"

          radio_am = find("#period_am_example_input")
          expect(radio_am).to be_checked
          expect(page).to have_field("example_input_date", with: "01/20/1994")
          expect(page).to have_field("example_input_time", with: "02:59")
          expect(page).to have_field("example_input", with: "1994-01-20T02:59", visible: :all)
        end
      end

      context "when time is set to PM" do
        it "inputs the correct value" do
          fill_in_datepicker :example_input_date, with: "01/20/1994"
          fill_in_timepicker :example_input_time, with: "02:59"

          radio_pm = find("#period_pm_example_input")
          radio_pm.click
          expect(radio_pm).to be_checked
          expect(page).to have_field("example_input_date", with: "01/20/1994")
          expect(page).to have_field("example_input_time", with: "02:59")
          expect(page).to have_field("example_input", with: "1994-01-20T14:59", visible: :all)
        end
      end
    end

    context "when choosing date" do
      context "when using input field" do
        context "when typing a correct date" do
          it "sets the date on the datepicker calendar" do
            fill_in_datepicker :example_input_date, with: "01/20/1994"
            find(".calendar_button").click(x: 10, y: 10)
            year = find('span > input[name="year"]')
            month = find('select[name="month"]')
            date = find("td.wc-datepicker__date--selected")
            expect(year.value).to eq("1994")
            expect(month).to have_content("January")
            expect(date).to have_content("20")
          end
        end

        context "when typing correct date with '.' -separator" do
          it "replaces separator with the format's correct separator" do
            fill_in_datepicker :example_input_date, with: "24.11.2012"
            expect(page).to have_field("example_input_date", with: "01.20.1994")
            find("#example_input_time").click
            expect(page).to have_field("example_input_date", with: "01/20/1994")
          end
        end

        context "when pasting a correct format date to date input field" do
          context "when pasting with the correct separator" do
            it "pastes the date to the input field" do
              fill_in :example_input_clipboard, with: "24/11/2012"

              clipboard = find("#example_input_clipboard")
              clipboard.send_keys [:control, "a"]
              clipboard.send_keys [:control, "c"]
              find("#example_input_date").send_keys [:control, "v"]
              expect(page).to have_field("example_input_date", with: "24/11/2012")
            end
          end

          context "when pasting with incorrect separator" do
            it "pastes the date to the input field with the correct separator" do
              fill_in :example_input_clipboard, with: "24.11.2012"

              clipboard = find("#example_input_clipboard")
              clipboard.send_keys [:control, "a"]
              clipboard.send_keys [:control, "c"]
              find("#example_input_date").send_keys [:control, "v"]
              expect(page).to have_field("example_input_date", with: "24/11/2012")

              fill_in :example_input_clipboard, with: "24-11-2012"

              clipboard.send_keys [:control, "a"]
              clipboard.send_keys [:control, "c"]
              find("#example_input_date").send_keys [:control, "v"]
              expect(page).to have_field("example_input_date", with: "24/11/2012")
            end
          end
        end
      end
    end

    context "when choosing time" do
      context "when using picker" do
        context "when opening timepicker" do
          it "hour starts from one" do
            find(".clock_button").click
            hour = find("input.hourpicker")
            minute = find("input.minutepicker")
            expect(hour.value).to eq("01")
            expect(minute.value).to eq("00")
          end
        end

        context "when decreasing hour from one" do
          it "turns to 12" do
            find(".clock_button").click
            find(".hourdown").click
            hour = find("input.hourpicker")
            expect(hour.value).to eq("12")
          end
        end

        context "when increasing hour from 12" do
          it "turns to one" do
            find(".clock_button").click
            hour = find("input.hourpicker")
            find(".hourdown").click
            expect(hour.value).to eq("12")
            find(".hourup").click
            expect(hour.value).to eq("01")
          end
        end

        context "when resetting timepicker" do
          it "sets hour to one and minutes to zero and resets time input" do
            find(".clock_button").click
            find(".hourdown").click
            find(".minuteup").click
            hour = find("input.hourpicker")
            minute = find("input.minutepicker")
            expect(page).to have_field("example_input_time", with: "12:01")
            click_button "Reset"
            expect(hour.value).to eq("01")
            expect(minute.value).to eq("00")
            expect(page).to have_field("example_input_time", with: "")
          end
        end
      end

      context "when using input field" do
        context "when typing value to time input field" do
          it "updates picker's time" do
            fill_in_timepicker :example_input_time, with: "05:15"
            find(".clock_button").click
            hour = find("input.hourpicker")
            minute = find("input.minutepicker")
            expect(hour.value).to eq("05")
            expect(minute.value).to eq("15")
          end

          it "doesn't update picker's time if not a correct value" do
            fill_in_timepicker :example_input_time, with: "13:55"
            find(".clock_button").click
            hour = find("input.hourpicker")
            minute = find("input.minutepicker")
            expect(hour.value).to eq("01")
            expect(minute.value).to eq("00")
          end
        end
      end
    end
  end
end
