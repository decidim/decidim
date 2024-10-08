# frozen_string_literal: true

require "spec_helper"

describe "Follow meetings" do
  let(:manifest_name) { "meetings" }

  let!(:followable) do
    create(:meeting, :published, component:)
  end

  let(:followable_path) { resource_locator(followable).path }

  before do
    stub_geocoding_coordinates([followable.latitude, followable.longitude])
  end

  include_examples "followable content for users with a component"
end
