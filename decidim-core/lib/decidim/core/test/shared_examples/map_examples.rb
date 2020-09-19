# frozen_string_literal: true

shared_context "with map utility" do
  let(:organization) { create(:organization) }
  let(:locale) { "en" }
  let(:config) { {} }

  let(:utility_class) { described_class }
  let(:utility) { utility_class.new(organization: organization, config: config, locale: locale) }
end

shared_context "with frontend map builder" do
  subject { described_class.new(template, options) }

  let(:template_class) do
    Class.new(ActionView::Base) do
      def protect_against_forgery?
        false
      end

      def snippets
        @snippets ||= Decidim::Snippets.new
      end
    end
  end
  let(:organization) { create(:organization) }
  let(:template) { template_class.new }
  let(:options) { {} }
  let(:js_options) { options.map { |k, v| [k.to_s.camelize(:lower), v] }.to_h }

  before do
    allow(template).to receive(:current_organization).and_return(organization)
  end
end

shared_context "with dynamic map builder" do
  include_context "with frontend map builder"

  let(:options) do
    {
      tile_layer: {
        url: "https://tiles.example.org",
        options: {
          foo: "bar",
          attribution: "Test Attribution"
        }
      }
    }
  end
end

shared_context "with map autocomplete builder" do
  include_context "with frontend map builder"

  let(:options) { { url: "https://photon.example.org/api/" } }
end

shared_context "with frontend map elements" do
  let(:html_head) { "" }
  let(:html_document) do
    builder = subject
    document_inner = html_body
    head_extra = html_head
    template.instance_eval do
      <<~HTML.strip
        <!doctype html>
        <html lang="en">
        <head>
          <title>Map Test</title>
          #{stylesheet_link_tag "application"}
          #{javascript_include_tag "application"}
          #{builder.stylesheet_snippets}
          #{builder.javascript_snippets}
          #{head_extra}
        </head>
        <body>
          #{document_inner}
          <script type="text/javascript">
            // This is just to indicate to Capybara that the page has fully
            // finished loading.
            $(document).ready(function() {
              setTimeout(function() {
                $("body").append('<div id="ready_indicator">Document ready</div>');
              }, 1000);
            });
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
      get "test_dynamic_map", to: ->(_) { [200, {}, [final_html]] }
    end

    visit "/test_dynamic_map"
  end

  after do
    expect(page).to have_selector("#ready_indicator", text: "Document ready")

    expect_no_js_errors

    # Reset the routes back to original
    Rails.application.reload_routes!
  end
end

shared_examples "a page with dynamic map" do
  include_context "with dynamic map builder"

  include_context "with frontend map elements" do
    let(:html_body) do
      builder = subject
      template.instance_eval do
        builder.map_element(id: "map", class: "google-map") do
          content_tag(:span, "", id: "map_inner")
        end
      end
    end
  end

  it "displays the map" do
    expect(page).to have_selector("#map.google-map", visible: :all)
    expect(page).to have_selector("#map_inner", visible: :all)
  end
end

shared_examples "a page with geocoding input" do
  include_context "with map autocomplete builder"

  include_context "with frontend map elements" do
    let(:html_body) do
      builder = subject
      template.instance_eval do
        builder.geocoding_field(:test, :address)
      end
    end
  end

  it "displays the geocoding field element" do
    config = ERB::Util.html_escape(js_options.to_json)
    expect(subject.geocoding_field(:test, :address)).to eq(
      %(<input autocomplete="off" data-decidim-geocoding="#{config}" type="text" name="test[address]" id="test_address" />)
    )
  end
end

# Use this shared example to test that the front-end geocoded address field is
# working correctly. Fill in the other fields in the view in the before block so
# that the saving will proceed successfully.
shared_examples "a record with front-end geocoding address field" do |geocoded_model, view_options|
  let(:geocoded_record) { nil }
  let(:geocoded_address_value) { "Street2" }
  let(:geocoded_address_coordinates) { [3.345, 4.456] }

  it "calls the front-end geocoder when an address is written", :slow do
    within view_options[:within_selector] do
      fill_in_geocoding view_options[:address_field], with: geocoded_address_value
      find(".tribute-container ul#results li", match: :first).click
      find("*[type=submit]").click
    end

    # Check that the latitude and longitude are according to the front-end
    # geocoder as one of the autocompleted addresses were selected. The back-end
    # geocoding should be bypassed in this situation which is why these match
    # what was returned by the front-end geocoding. These values are returned by
    # the dummy test geocoding API defined at
    # `decidim-dev/lib/decidim/dev/test/rspec_support/geocoder.rb`. Search for
    # `:serves_geocoding_autocomplete`.
    expect(page).to have_content("successfully")
    final = if geocoded_record
              geocoded_model.find(geocoded_record.id)
            else
              geocoded_model.last
            end
    expect(final.latitude).to eq(geocoded_address_coordinates[0])
    expect(final.longitude).to eq(geocoded_address_coordinates[1])
  end
end
