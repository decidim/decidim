# frozen_string_literal: true

require "spec_helper"

describe "Admin publishes component" do
  include_context "when managing a component as an admin" do
    let!(:resource) { create(:debate, component:) }

    context "when cycling through publication states" do
      let!(:component) { create(:debates_component, participatory_space:) }

      include_examples "cycling through publication states"
    end

    context "when publishing a component" do
      let!(:component) { create(:debates_component, :unpublished, participatory_space:) }

      include_examples "add component resources to search index"
    end

    context "when component is published" do
      let!(:component) { create(:debates_component, :published, participatory_space:) }

      include_examples "removes component resources from search index"
    end
  end
end
