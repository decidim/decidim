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
                  $(function() {
                    $("body").append('<div id="ajax_request"></div>');
                    $("body").append('<div id="geocoder_suggested"></div>');
                    $("body").append('<div id="geocoder_coordinates"></div>');

                    // Override jQuery AJAX in order to check the request is
                    // sent correctly.
                    $.ajax = function(request) {
                      $("#ajax_request").text(JSON.stringify(request));

                      var response = {};
                      if (request.url === "https://geocoder.ls.hereapi.com/6.2/geocode.json") {
                        response = {
                          response: {
                            view: [
                              {
                                result: [
                                  {
                                    location:{
                                      displayPosition: {
                                        latitude: 1.123,
                                        longitude: 2.234
                                      }
                                    }
                                  }
                                ]
                              }
                            ]
                          }
                        };
                      } else {
                        response = {
                          suggestions: [
                            {
                              label: "first item",
                              address: { street: "first item" },
                              locationId: "location1"
                            },
                            {
                              label: "second item",
                              address: { street: "second item" },
                              locationId: "location2"
                            },
                            {
                              label: "third item",
                              address: { street: "third item" },
                              locationId: "location3"
                            }
                          ]
                        };
                      }

                      // This is a normal suggest call to:
                      // https://autocomplete.geocoder.ls.hereapi.com/6.2/suggest.json
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
                ".tribute-container",
                text: "first item\nsecond item\nthird item"
              )
              expect(page).to have_selector(
                "#ajax_request",
                text: {
                  method: "GET",
                  url: "https://autocomplete.geocoder.ls.hereapi.com/6.2/suggest.json",
                  data: {
                    apiKey: "key1234",
                    query: "item",
                    language: "en"
                  },
                  dataType: "json"
                }.to_json
              )

              find(".tribute-container ul#results li", match: :first).click
              expect(page).to have_selector(
                "#ajax_request",
                text: {
                  method: "GET",
                  url: "https://geocoder.ls.hereapi.com/6.2/geocode.json",
                  data: {
                    apiKey: "key1234",
                    gen: 9,
                    jsonattributes: 1,
                    locationid: "location1"
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
