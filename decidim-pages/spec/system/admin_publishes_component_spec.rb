# frozen_string_literal: true

require "spec_helper"

describe "Admin publishes component" do
  let!(:resource) { create(:page, component:) }

  include_context "when managing a component as an admin" do
    context "when cycling through publication states" do
      let!(:component) { create(:page_component, participatory_space:) }

      include_examples "cycling through publication states"
    end
  end
end
