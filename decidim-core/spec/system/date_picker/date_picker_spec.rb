# frozen_string_literal: true

require "spec_helper"

describe "Datepicker" do
  let(:organization) { create(:organization) }
  let(:datepicker_content) { "" }
  let(:record) { OpenStruct.new(body: datepicker_content) }
  let(:form) { Decidim::FormBuilder.new(:example, record, template, {}) }
  let(:datetime_field) { form.datetime_field(:input) }

  let(:template_class) do
    Class.new(ActionView::Base) do
      def protect_against_forgery?
        false
      end
    end
  end

  let(:template) { template_class.new(ActionView::LookupContext.new(ActionController::Base.view_paths), {}, []) }

  let(:html_document) do
    datepicker_wrapper = datetime_field
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
        find(".datepicker__calendar-button").click
        find('span > input[name="year"]').set("1994")
        find(".wc-datepicker__next-month-button").click
        month = find('select[name="month"]').value
        formatted_month = format("%02d", month)

        find("td > span", text: "20", match: :first).click
        find(".datepicker__pick-calendar").click

        find(".datepicker__clock-button").click
        find(".datepicker__hour-up").click
        find(".datepicker__minute-down").click
        find(".datepicker__select-clock").click

        expect(page).to have_field("example_input_time", with: "01:59")
        expect(page).to have_field("example_input_date", with: "20/#{formatted_month}/1994")
        expect(page).to have_field("example_input", with: "1994-#{formatted_month}-20T01:59", visible: :all)
      end
    end

    context "when filling date and leaving time field empty" do
      it "fills a default time" do
        fill_in_datepicker :example_input_date, with: "12/12/2021"
        expect(page).to have_field("example_input", with: "2021-12-12T00:00", visible: :all)
      end

      context "when input field's default time set to a specific time" do
        let(:datetime_field) { form.datetime_field(:input, default_time: "23:59") }

        it "fills the time field with the default time" do
          fill_in_datepicker :example_input_date, with: "12/12/2021"
          expect(page).to have_field("example_input", with: "2021-12-12T23:59", visible: :all)
        end
      end
    end

    context "when input fields' help texts are hidden" do
      let(:datetime_field) { form.datetime_field(:input, hide_help: true) }

      it "hides the help texts" do
        expect(page).to have_no_content("Format: dd/mm/yy")
      end
    end

    context "when choosing date" do
      context "when using picker" do
        context "when opening datepicker" do
          it "shows the datepicker calendar" do
            find(".datepicker__calendar-button").click
            expect(page).to have_css("#example_input_date_datepicker")
          end

          it "has disabled select button" do
            find(".datepicker__calendar-button").click
            expect(page).to have_button("Select", disabled: true)
          end

          context "when choosing a date" do
            it "enables the select button" do
              find(".datepicker__calendar-button").click
              yesterday = Date.yesterday.strftime("%-d")
              find("td > span", text: yesterday, match: :first).click
              expect(page).to have_button("Select", disabled: false)
            end
          end
        end

        context "when closing datepicker" do
          it "hides the datepicker calendar" do
            find(".datepicker__calendar-button").click
            expect(page).to have_css("#example_input_date_datepicker")
            find(".datepicker__close-calendar").click
            expect(page).to have_css("#example_input_date_datepicker", visible: :hidden)
          end
        end

        context "when opening datepicker with an existing date" do
          it "has the previously picked date selected" do
            find(".datepicker__calendar-button").click
            find('span > input[name="year"]').set("1994")
            find(".wc-datepicker__next-month-button").click
            find("td > span", text: "20", match: :first).click
            find(".datepicker__pick-calendar").click
            find(".datepicker__calendar-button").click
            element = find("td.wc-datepicker__date--selected")
            expect(element).to have_content("20")
            expect(page).to have_button("Select", disabled: false)
          end
        end
      end

      context "when using input field" do
        context "when typing a correct date" do
          it "sets the date on the datepicker calendar" do
            fill_in_datepicker :example_input_date, with: "24/11/2012"
            find(".datepicker__calendar-button").click
            year = find('span > input[name="year"]')
            month = find('select[name="month"]')
            date = find("td.wc-datepicker__date--selected")
            expect(year.value).to eq("2012")
            expect(month).to have_content("November")
            expect(date).to have_content("24")
          end

          it "only allows typing numbers and separators" do
            fill_in_datepicker :example_input_date, with: "24!\"#/abcloktpes11¤%&/()=2012:"
            expect(page).to have_field("example_input_date", with: "24/11/2012")
          end
        end

        context "when typing correct date with incorrect separator" do
          it "replaces separator with the format's correct separator" do
            fill_in_datepicker :example_input_date, with: "24.11.2012"
            expect(page).to have_field("example_input_date", with: "24/11/2012")
          end
        end

        context "when pasting" do
          context "when pasting a correct format date to date input field" do
            context "when pasting with the correct separator" do
              it "pastes the date to the input field" do
                fill_in :example_input_clipboard, with: "24/11/2012"

                clipboard = find_by_id("example_input_clipboard")
                clipboard.send_keys [:control, "a"]
                clipboard.send_keys [:control, "c"]
                find_by_id("example_input_date").send_keys [:control, "v"]
                expect(page).to have_field("example_input_date", with: "24/11/2012")
              end
            end

            context "when pasting with incorrect separator" do
              it "pastes the date to the input field with the correct separator" do
                fill_in :example_input_clipboard, with: "24.11.2012"

                clipboard = find_by_id("example_input_clipboard")
                clipboard.send_keys [:control, "a"]
                clipboard.send_keys [:control, "c"]
                find_by_id("example_input_date").send_keys [:control, "v"]
                expect(page).to have_field("example_input_date", with: "24/11/2012")

                fill_in :example_input_clipboard, with: "24-11-2012"

                clipboard.send_keys [:control, "a"]
                clipboard.send_keys [:control, "c"]
                find_by_id("example_input_date").send_keys [:control, "v"]
                expect(page).to have_field("example_input_date", with: "24/11/2012")
              end
            end
          end

          context "when pasting an incorrect value to date input field" do
            it "does not paste anything" do
              fill_in :example_input_clipboard, with: "example_value"

              clipboard = find_by_id("example_input_clipboard")
              clipboard.send_keys [:control, "a"]
              clipboard.send_keys [:control, "c"]
              find_by_id("example_input_date").send_keys [:control, "v"]
              expect(page).to have_field("example_input_date", with: "")
            end
          end
        end
      end
    end

    context "when choosing time" do
      context "when using picker" do
        context "when opening timepicker" do
          it "shows the timepicker" do
            find(".datepicker__clock-button").click
            expect(page).to have_css("#example_input_time_timepicker")
          end

          it "starts from zero" do
            find(".datepicker__clock-button").click
            hour = find("input.datepicker__hour-picker")
            minute = find("input.datepicker__minute-picker")
            expect(hour.value).to eq("00")
            expect(minute.value).to eq("00")
          end
        end

        context "when closing timepicker" do
          it "hides the timepicker" do
            find(".datepicker__clock-button").click
            expect(page).to have_css("#example_input_time_timepicker")
            find(".datepicker__close-clock").click
            expect(page).to have_css("#example_input_time_timepicker", visible: :hidden)
          end
        end

        context "when decreasing hour from zero" do
          it "turns to 23" do
            find(".datepicker__clock-button").click
            find(".datepicker__hour-down").click
            hour = find("input.datepicker__hour-picker")
            expect(hour.value).to eq("23")
          end
        end

        context "when decreasing minute from zero" do
          it "turns to 59" do
            find(".datepicker__clock-button").click
            find(".datepicker__minute-down").click
            minute = find("input.datepicker__minute-picker")
            expect(minute.value).to eq("59")
          end
        end

        context "when increasing hour from 23" do
          it "turns to zero" do
            find(".datepicker__clock-button").click
            hour = find("input.datepicker__hour-picker")
            find(".datepicker__hour-down").click
            expect(hour.value).to eq("23")
            find(".datepicker__hour-up").click
            expect(hour.value).to eq("00")
          end
        end

        context "when increasing minute from 59" do
          it "turns to zero" do
            find(".datepicker__clock-button").click
            find(".datepicker__minute-down").click
            minute = find("input.datepicker__minute-picker")
            expect(minute.value).to eq("59")
            find(".datepicker__minute-up").click
            expect(minute.value).to eq("00")
          end
        end

        context "when resetting timepicker" do
          it "sets picker to zero and resets time input" do
            find(".datepicker__clock-button").click
            find(".datepicker__hour-down").click
            find(".datepicker__minute-up").click
            hour = find("input.datepicker__hour-picker")
            minute = find("input.datepicker__minute-picker")
            click_on "Select"
            expect(page).to have_field("example_input_time", with: "23:01")
            find(".datepicker__clock-button").click
            click_on "Reset"
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
            find(".datepicker__clock-button").click
            hour = find("input.datepicker__hour-picker")
            minute = find("input.datepicker__minute-picker")
            expect(hour.value).to eq("21")
            expect(minute.value).to eq("15")
          end

          it "only allows typing numbers and colon" do
            fill_in_timepicker :example_input_time, with: "/.!\"#¤%&()=?abcert21jkl:mn22"
            expect(page).to have_field("example_input_time", with: "21:22")
          end

          it "does not update picker's time if not a correct value" do
            fill_in_timepicker :example_input_time, with: "99:99"
            find(".datepicker__clock-button").click
            hour = find("input.datepicker__hour-picker")
            minute = find("input.datepicker__minute-picker")
            expect(hour.value).to eq("00")
            expect(minute.value).to eq("00")
          end
        end

        context "when pasting" do
          context "when pasting a correct time to time input field" do
            it "pastes the time to the input field" do
              fill_in :example_input_clipboard, with: "15:15"

              clipboard = find_by_id("example_input_clipboard")
              clipboard.send_keys [:control, "a"]
              clipboard.send_keys [:control, "c"]
              find_by_id("example_input_time").send_keys [:control, "v"]
              expect(page).to have_field("example_input_time", with: "15:15")
            end
          end

          context "when pasting a correct time to time input field with incorrect separator" do
            it "changes to correct separator" do
              fill_in :example_input_clipboard, with: "15.15"

              clipboard = find_by_id("example_input_clipboard")
              clipboard.send_keys [:control, "a"]
              clipboard.send_keys [:control, "c"]
              find_by_id("example_input_time").send_keys [:control, "v"]
              expect(page).to have_field("example_input_time", with: "15:15")
            end
          end

          context "when pasting a time without a leading zero in the hour" do
            it "adds the leading zero" do
              fill_in :example_input_clipboard, with: "2:15"

              clipboard = find_by_id("example_input_clipboard")
              clipboard.send_keys [:control, "a"]
              clipboard.send_keys [:control, "c"]
              find_by_id("example_input_time").send_keys [:control, "v"]
              expect(page).to have_field("example_input_time", with: "02:15")
            end
          end

          context "when pasting an incorrect value to time input field" do
            it "does not paste anything" do
              fill_in :example_input_clipboard, with: "99:99"

              clipboard = find_by_id("example_input_clipboard")
              clipboard.send_keys [:control, "a"]
              clipboard.send_keys [:control, "c"]
              find_by_id("example_input_time").send_keys [:control, "v"]
              expect(page).to have_field("example_input_time", with: "")
            end
          end
        end
      end
    end
  end

  context "when date format mm/dd/yyyy and clock format 12" do
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
                help: {
                  date_format: "Format: mm.dd.yyyy"
                },
                order: "m-d-y",
                separator: "/"
              },
              buttons: {
                close: "Close",
                select: "Select"
              }
            },
            time: {
              clock_format: 12,
              formats: {
                help: {
                  time_format: "Format: hh:mm"
                }
              },
              buttons: {
                close: "Close",
                select: "Select",
                reset: "Reset"
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
        find(".datepicker__calendar-button").click(x: 5, y: 10)
        find('span > input[name="year"]').set("1994")
        find(".wc-datepicker__next-month-button").click
        month = find('select[name="month"]').value
        formatted_month = format("%02d", month)

        find("td > span", text: "20", match: :first).click
        find(".datepicker__pick-calendar").click

        find(".datepicker__clock-button").click
        find(".datepicker__hour-up").click
        find(".datepicker__minute-down").click
        find(".datepicker__select-clock").click
        expect(page).to have_field("example_input_date", with: "#{formatted_month}/20/1994")
        expect(page).to have_field("example_input_time", with: "02:59")
        expect(page).to have_field("example_input", with: "1994-#{formatted_month}-20T02:59", visible: :all)
      end

      context "when time is set to AM" do
        it "inputs the correct value" do
          fill_in_datepicker :example_input_date, with: "01/20/1994"
          fill_in_timepicker :example_input_time, with: "02:59"

          radio_am = find_by_id("period_am_example_input")
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

          radio_pm = find_by_id("period_pm_example_input")
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
            find(".datepicker__calendar-button").click(x: 5, y: 10)
            year = find('span > input[name="year"]')
            month = find('select[name="month"]')
            date = find("td.wc-datepicker__date--selected")
            expect(year.value).to eq("1994")
            expect(month).to have_content("January")
            expect(date).to have_content("20")
          end
        end

        context "when typing correct date with incorrect separator" do
          it "replaces separator with the format's correct separator" do
            fill_in_datepicker :example_input_date, with: "01.20.1994"
            expect(page).to have_field("example_input_date", with: "01/20/1994")
          end
        end

        context "when pasting a correct format date to date input field" do
          context "when pasting with the correct separator" do
            it "pastes the date to the input field" do
              fill_in :example_input_clipboard, with: "24/11/2012"

              clipboard = find_by_id("example_input_clipboard")
              clipboard.send_keys [:control, "a"]
              clipboard.send_keys [:control, "c"]
              find_by_id("example_input_date").send_keys [:control, "v"]
              expect(page).to have_field("example_input_date", with: "24/11/2012")
            end
          end

          context "when pasting with incorrect separator" do
            it "pastes the date to the input field with the correct separator" do
              fill_in :example_input_clipboard, with: "24.11.2012"

              clipboard = find_by_id("example_input_clipboard")
              clipboard.send_keys [:control, "a"]
              clipboard.send_keys [:control, "c"]
              find_by_id("example_input_date").send_keys [:control, "v"]
              expect(page).to have_field("example_input_date", with: "24/11/2012")

              fill_in :example_input_clipboard, with: "24-11-2012"

              clipboard.send_keys [:control, "a"]
              clipboard.send_keys [:control, "c"]
              find_by_id("example_input_date").send_keys [:control, "v"]
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
            find(".datepicker__clock-button").click
            hour = find("input.datepicker__hour-picker")
            minute = find("input.datepicker__minute-picker")
            expect(hour.value).to eq("01")
            expect(minute.value).to eq("00")
          end
        end

        context "when decreasing hour from one" do
          it "turns to 12" do
            find(".datepicker__clock-button").click
            find(".datepicker__hour-down").click
            hour = find("input.datepicker__hour-picker")
            expect(hour.value).to eq("12")
          end
        end

        context "when increasing hour from 12" do
          it "turns to one" do
            find(".datepicker__clock-button").click
            hour = find("input.datepicker__hour-picker")
            find(".datepicker__hour-down").click
            expect(hour.value).to eq("12")
            find(".datepicker__hour-up").click
            expect(hour.value).to eq("01")
          end
        end

        context "when resetting timepicker" do
          it "sets hour to one and minutes to zero and resets time input" do
            find(".datepicker__clock-button").click
            find(".datepicker__hour-down").click
            find(".datepicker__minute-up").click
            hour = find("input.datepicker__hour-picker")
            minute = find("input.datepicker__minute-picker")
            click_on "Select"
            expect(page).to have_field("example_input_time", with: "12:01")
            find(".datepicker__clock-button").click
            click_on "Reset"
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
            find(".datepicker__clock-button").click
            hour = find("input.datepicker__hour-picker")
            minute = find("input.datepicker__minute-picker")
            expect(hour.value).to eq("05")
            expect(minute.value).to eq("15")
          end

          it "does not update picker's time if not a correct value" do
            fill_in_timepicker :example_input_time, with: "13:55"
            find(".datepicker__clock-button").click
            hour = find("input.datepicker__hour-picker")
            minute = find("input.datepicker__minute-picker")
            expect(hour.value).to eq("01")
            expect(minute.value).to eq("00")
          end
        end
      end
    end
  end

  context "when date format yyyy.mm.dd" do
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
                help: {
                  date_format: "Format: yyyy/mm/dd"
                },
                order: "y-m-d",
                separator: "/"
              },
              buttons: {
                close: "Close",
                select: "Select"
              }
            },
            time: {
              clock_format: 24,
              formats: {
                help: {
                  time_format: "Format: hh:mm"
                }
              },
              buttons: {
                close: "Close",
                select: "Select",
                reset: "Reset"
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
        find(".datepicker__calendar-button").click(x: 5, y: 10)
        find('span > input[name="year"]').set("1994")
        find(".wc-datepicker__next-month-button").click
        month = find('select[name="month"]').value
        formatted_month = format("%02d", month)

        find("td > span", text: "20", match: :first).click
        find(".datepicker__pick-calendar").click

        find(".datepicker__clock-button").click
        find(".datepicker__hour-up").click
        find(".datepicker__minute-down").click
        find(".datepicker__select-clock").click

        expect(page).to have_field("example_input_date", with: "1994/#{formatted_month}/20")
        expect(page).to have_field("example_input_time", with: "01:59")
        expect(page).to have_field("example_input", with: "1994-#{formatted_month}-20T01:59", visible: :all)
      end
    end

    context "when choosing date" do
      context "when using input field" do
        context "when typing a correct date" do
          it "sets the date on the datepicker calendar" do
            fill_in_datepicker :example_input_date, with: "1994/01/20"
            find(".datepicker__calendar-button").click(x: 5, y: 10)
            year = find('span > input[name="year"]')
            month = find('select[name="month"]')
            date = find("td.wc-datepicker__date--selected")
            expect(year.value).to eq("1994")
            expect(month).to have_content("January")
            expect(date).to have_content("20")
          end
        end

        context "when typing correct date with incorrect separator" do
          it "replaces separator with the format's correct separator" do
            fill_in_datepicker :example_input_date, with: "1994.01.20"
            expect(page).to have_field("example_input_date", with: "1994/01/20")
          end
        end

        context "when pasting a correct format date to date input field" do
          context "when pasting with the correct separator" do
            it "pastes the date to the input field" do
              fill_in :example_input_clipboard, with: "2012/24/11"

              clipboard = find_by_id("example_input_clipboard")
              clipboard.send_keys [:control, "a"]
              clipboard.send_keys [:control, "c"]
              find_by_id("example_input_date").send_keys [:control, "v"]
              expect(page).to have_field("example_input_date", with: "2012/24/11")
            end
          end

          context "when pasting with incorrect separator" do
            it "pastes the date to the input field with the correct separator" do
              fill_in :example_input_clipboard, with: "2012.24.11"

              clipboard = find_by_id("example_input_clipboard")
              clipboard.send_keys [:control, "a"]
              clipboard.send_keys [:control, "c"]
              find_by_id("example_input_date").send_keys [:control, "v"]
              expect(page).to have_field("example_input_date", with: "2012/24/11")

              fill_in :example_input_clipboard, with: "2012-24-11"

              clipboard.send_keys [:control, "a"]
              clipboard.send_keys [:control, "c"]
              find_by_id("example_input_date").send_keys [:control, "v"]
              expect(page).to have_field("example_input_date", with: "2012/24/11")
            end
          end
        end
      end
    end
  end
end
