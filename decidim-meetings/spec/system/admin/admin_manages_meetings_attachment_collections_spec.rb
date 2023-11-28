# frozen_string_literal: true

require "spec_helper"

describe "Admin manages meetings attachment collections" do
  let(:manifest_name) { "meetings" }
  let!(:meeting) { create(:meeting, scope:, component: current_component) }

  before do
    # Make static map requests not to fail with HTTP 500 (causes JS error)
    stub_request(:get, Regexp.new(Decidim.maps.fetch(:static).fetch(:url))).to_return(body: "")
  end

  include_context "when managing a component as an admin"

  it_behaves_like "manage meetings attachment collections"
end
