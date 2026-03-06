# frozen_string_literal: true

require "spec_helper"

describe "Admin manages component publication" do
  include_context "when managing a component as an admin" do
    context "when there are no children" do
      let!(:resource) { create(:result, component:) }

      context "when cycling through publication states" do
        let!(:component) { create(:accountability_component, participatory_space:) }

        include_examples "cycling through publication states"
      end

      context "when component is unpublished, and admin publishes" do
        let!(:component) { create(:accountability_component, :unpublished, participatory_space:) }

        include_examples "add component resources to search index"
      end

      context "when component is published, and admin unpublishes" do
        let!(:component) { create(:accountability_component, :published, participatory_space:) }

        include_examples "removes component resources from search index"
      end
    end

    context "when there are children" do
      let!(:resource) { create(:result, component:) }
      let!(:children) { create(:result, component:, parent: resource) }

      context "when cycling through publication states" do
        let!(:component) { create(:accountability_component, participatory_space:) }

        include_examples "cycling through publication states"
      end

      context "when component is unpublished, and admin publishes" do
        let!(:component) { create(:accountability_component, :unpublished, participatory_space:) }

        include_examples "add component resources to search index"
      end

      context "when component is published, and admin unpublishes" do
        let!(:component) { create(:accountability_component, :published, participatory_space:) }

        include_examples "removes component resources from search index"
      end
    end
  end
end
