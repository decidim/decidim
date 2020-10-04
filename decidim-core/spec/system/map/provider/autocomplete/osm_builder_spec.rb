# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Map
    module Provider
      module Autocomplete
        describe Osm::Builder, type: :system do
          it_behaves_like "a page with geocoding input" do
            let(:options) { { url: "https://photon.example.org/api/" } }
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

                      var deferred = $.Deferred().resolve({
                        features: [
                          {
                            properties: {
                              name: "Park",
                              street: "Street1",
                              housenumber: "1",
                              postcode: "123456",
                              city: "City1",
                              state: "State1",
                              country: "Country1"
                            },
                            geometry: {
                              coordinates: [1.123, 2.234]
                            }
                          },
                          {
                            properties: {
                              street: "Street2",
                              postcode: "654321",
                              city: "City2",
                              country: "Country2"
                            },
                            geometry: {
                              coordinates: [3.345, 4.456]
                            }
                          },
                          {
                            properties: {
                              street: "Street3",
                              housenumber: "3",
                              postcode: "142536",
                              city: "City3",
                              country: "Country3"
                            },
                            geometry: {
                              coordinates: [5.567, 6.678]
                            }
                          }
                        ]
                      });
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
              find("#test_address").set("city")
              expect(page).to have_selector(
                ".tribute-container",
                text: [
                  "Park, Street1 1, 123456, City1, State1, Country1",
                  "Street2, 654321, City2, Country2",
                  "Street3 3, 142536, City3, Country3"
                ].join("\n")
              )
              expect(page).to have_selector(
                "#ajax_request",
                text: {
                  method: "GET",
                  url: "https://photon.example.org/api/",
                  data: {
                    q: "city",
                    lang: "en"
                  },
                  dataType: "json"
                }.to_json
              )

              find(".tribute-container ul#results li", match: :first).click
              expect(page).to have_selector(
                "#geocoder_suggested",
                text: {
                  key: "Park, Street1 1, 123456, City1, State1, Country1",
                  value: "Park, Street1 1, 123456, City1, State1, Country1",
                  coordinates: [1.123, 2.234]
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
