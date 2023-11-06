# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Map
    module Provider
      module Autocomplete
        describe Here::Builder, type: :system do
          it_behaves_like "a page with geocoding input" do
            let(:options) { { apiKey: "key1234" } }
            let(:html_head) do
              <<~HEAD
                <script type="text/javascript">
                  document.addEventListener("DOMContentLoaded", function() {
                    $("body").append('<div id="ajax_request"></div>');
                    $("body").append('<div id="geocoder_suggested"></div>');
                    $("body").append('<div id="geocoder_coordinates"></div>');

                    // Override jQuery AJAX in order to check the request is
                    // sent correctly.
                    $.ajax = function(request) {
                      $("#ajax_request").text(JSON.stringify(request));

                      var response = {};
                      if (request.url === "https://lookup.search.hereapi.com/v1/lookup") {
                        response = {
                          position: {
                            lat: 1.123,
                            lng: 2.234
                          }
                        };
                      } else {
                        response = {
                          items: [
                            {
                              title: "first item",
                              address: { street: "first item" },
                              id: "location1"
                            },
                            {
                              title: "second item",
                              address: { street: "second item" },
                              id: "location2"
                            },
                            {
                              title: "third item",
                              address: { street: "third item" },
                              id: "location3"
                            }
                          ]
                        };
                      }

                      // This is a normal suggest call to:
                      // https://autocomplete.search.hereapi.com/v1/autocomplete
                      var deferred = $.Deferred().resolve(response);
                      return deferred.promise();
                    };

                    // Bind the geocoding events in order to display the results
                    // on the page for Capybara.
                    var $input = $("#test_address");
                    $input.on("geocoder-suggest-select.decidim", function(ev, selectedItem) {
                      $("#geocoder_suggested").text(JSON.stringify(selectedItem));
                    });
                    $input.on("geocoder-suggest-coordinates.decidim", function(ev, coordinates) {
                      $("#geocoder_coordinates").text(coordinates[0] + "," + coordinates[1]);
                    });
                  });
                </script>
              HEAD
            end

            it "calls the geocoding API correctly" do
              find("#test_address").set("item")
              expect(page).to have_selector(
                ".autoComplete_wrapper",
                text: "first item\nsecond item\nthird item"
              )
              expect(page).to have_selector(
                "#ajax_request",
                text: {
                  method: "GET",
                  url: "https://autocomplete.search.hereapi.com/v1/autocomplete",
                  data: {
                    apiKey: "key1234",
                    q: "item",
                    lang: "en"
                  },
                  dataType: "json"
                }.to_json
              )

              find(".autoComplete_wrapper ul#autoComplete_list_1 li", match: :first).click
              expect(page).to have_selector(
                "#ajax_request",
                text: {
                  method: "GET",
                  url: "https://lookup.search.hereapi.com/v1/lookup",
                  data: {
                    apiKey: "key1234",
                    id: "location1"
                  },
                  dataType: "json"
                }.to_json
              )
              expect(page).to have_selector(
                "#geocoder_suggested",
                text: {
                  key: "first item",
                  value: "first item",
                  locationId: "location1"
                }.to_json
              )
              expect(page).to have_selector(
                "#geocoder_coordinates",
                text: "1.123,2.234"
              )
            end
          end
        end
      end
    end
  end
end
