# frozen_string_literal: true

shared_context "with map utility" do
  let(:organization) { create(:organization) }
  let(:locale) { "en" }
  let(:config) { {} }

  let(:utility_class) { described_class }
  let(:utility) { utility_class.new(organization:, config:, locale:) }
end

shared_context "with frontend map builder" do
  subject { described_class.new(template, options) }

  let(:template_class) do
    Class.new(ActionView::Base) do
      include Decidim::LayoutHelper

      def protect_against_forgery?
        false
      end

      def snippets
        @snippets ||= Decidim::Snippets.new
      end
    end
  end
  let(:organization) { create(:organization) }
  let(:template) { template_class.new(ActionView::LookupContext.new(ActionController::Base.view_paths), {}, []) }
  let(:options) { {} }
  let(:js_options) { options.transform_keys { |k| k.to_s.camelize(:lower) }.to_h }

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
    document_inner = html_body
    head_extra = html_head
    template.append_stylesheet_pack_tag("decidim_dev")
    template.instance_eval do
      <<~HTML.strip
        <!doctype html>
        <html lang="en">
        <head>
          <title>Map Test</title>
          #{stylesheet_pack_tag "decidim_core"}
          #{javascript_pack_tag "decidim_core", defer: false}

          #{head_extra}
        </head>
        <body>
          <header>
            <a href="#content">Skip to main content</a>
          </header>
          <main id="content">
            <h1>Map Test</h1>
            <div class="dev__map">
              #{document_inner}
            </div>
          </main>
          <script type="text/javascript">
            // This is just to indicate to Capybara that the page has fully
            // finished loading.
            document.addEventListener("DOMContentLoaded", function() {
              setTimeout(function() {
                window.$("body").append('<div id="ready_indicator">Document ready</div>');
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
    # Create a favicon so it does not fail when trying to fetch it
    favicon = ""
    # Create a temporary route to display the generated HTML in a correct site
    # context.
    final_html = html_document
    Rails.application.routes.draw do
      get "maptiles/:z/:x/:y.png", to: ->(_) { [200, {}, [final_html]] }
      get "test_dynamic_map", to: ->(_) { [200, {}, [final_html]] }
      get "offline", to: ->(_) { [200, {}, [""]] }
      get "/favicon.ico", to: ->(_) { [200, {}, [favicon]] }
    end

    visit "/test_dynamic_map"
  end

  after do
    expect(page).to have_css("#ready_indicator", text: "Document ready")

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
        # Create two separate map elements to make sure generating multiple
        # map elements will not produce any HTML or accessibility validation
        # errors.
        content = builder.map_element(id: "map1") do
          content_tag(:span, "", id: "map1_inner")
        end
        content += builder.map_element(id: "map2") do
          content_tag(:span, "", id: "map2_inner")
        end
        content
      end
    end
  end

  it_behaves_like "accessible page"

  it "displays the maps" do
    expect(page).to have_css("#map1", visible: :all)
    expect(page).to have_css("#map1_inner", visible: :all)
    expect(page).to have_css("#map2", visible: :all)
    expect(page).to have_css("#map2_inner", visible: :all)
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

  let(:html_body) do
    builder = subject
    template.instance_eval do
      builder.geocoding_field(:test, :address)
    end
  end

  it "displays the geocoding field element" do
    config = ERB::Util.html_escape(js_options.to_json)
    expect(html_body).to eq(
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
      find("*[type=submit]").click
    end

    # Check that the latitude and longitude are according to the front-end
    # geocoder as one of the autocompleted addresses were selected. The back-end
    # geocoding should be bypassed in this situation which is why these match
    # what was returned by the front-end geocoding. These values are returned by
    # the dummy test geocoding API defined at
    # `decidim-dev/lib/decidim/dev/test/map_server.rb`. Search for
    # `serve_autocomplete`.
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
