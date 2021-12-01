# frozen_string_literal: true

require "spec_helper"

describe "Autocomplete multiselect", type: :system do
  subject { described_class }

  before do
    final_html = html_document
    Rails.application.routes.draw do
      mount Decidim::Core::Engine => "/"
      get "test_multiselect", to: ->(_) { [200, {}, [final_html]] }
    end
  end

  after do
    Rails.application.reload_routes!
  end

  let(:html_head) { "" }
  let(:html_document) do
    head_extra = html_head
    template.instance_eval do
      <<~HTML.strip
        <!doctype html>
        <html lang="en">
        <head>
          <title>Autocomplete multiselect Test</title>
          #{stylesheet_pack_tag "decidim_core"}
          #{javascript_pack_tag "decidim_core"}
          #{head_extra}
        </head>
        <body>
          <h1>Hello world<h1>
          <input class="test-multiselect">
        </body>
        </html>
      HTML
    end
  end
  let(:template_class) do
    Class.new(ActionView::Base) do
    end
  end
  let(:template) { template_class.new }

  describe "select multiple items" do
    it "shows multiselect" do
      visit "/test_multiselect"
      expect(page).to have_selector(".autoComplete_wrapper")
    end
  end
end
