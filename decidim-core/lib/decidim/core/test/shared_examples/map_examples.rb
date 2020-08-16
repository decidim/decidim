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

  # include_context "with frontend map elements" do
  #   let(:html_body) do
  #     template.form_for :test, url: "/test" do |form|
  #       form.geocoding_field(:address)
  #     end
  #   end
  # end

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
      %(<input data-decidim-geocoding="#{config}" type="text" name="test[address]" id="test_address" />)
    )
  end
end
