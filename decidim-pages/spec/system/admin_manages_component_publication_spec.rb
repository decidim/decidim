# frozen_string_literal: true

require "spec_helper"

describe "Admin manages component publication" do
  let!(:resource) { create(:page, component:) }

  # Note: other components also handle search index updates (additions/removals) when publishing or
  # unpublishing. This component is excluded from general search, so those operations are not implemented here.
  include_context "when managing a component as an admin" do
    context "when cycling through publication states" do
      let!(:component) { create(:page_component, participatory_space:) }

      include_examples "cycling through publication states"
    end
  end
end
