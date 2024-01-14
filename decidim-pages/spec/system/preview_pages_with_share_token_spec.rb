# frozen_string_literal: true

require "spec_helper"

describe "Preview pages with share token" do
  let(:manifest_name) { "pages" }

  let(:body) do
    {
      "en" => "<p>Content</p>",
      "ca" => "<p>Contingut</p>",
      "es" => "<p>Contenido</p>"
    }
  end

  let!(:page_component) { create(:page, component:, body:) }

  include_context "with a component"
  it_behaves_like "preview component with share_token"
end
