# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Sortitions
    module Admin
      describe SortitionsHelper do
        describe "components_options" do
          let(:components) { [double(id: 1, name: { "en" => "Component name" })] }

          it "Returns a list of selectable components" do
            expect(helper.components_options(components)).to include(["Component name", 1])
          end
        end

        describe "sortition_taxonomies" do
          let(:sortition) { double(taxonomies:) }

          context "when taxonomy is null" do
            let(:taxonomies) { [] }

            it "Returns all taxonomies" do
              expect(helper.sortition_taxonomies(sortition)).to eq("All taxonomies")
            end
          end

          context "when taxonomy is not null" do
            let(:taxonomies) { [double(name: { "en" => "Taxonomy name" })] }

            it "Returns the taxonomy name" do
              expect(helper.sortition_taxonomies(sortition)).to eq("Taxonomy name")
            end
          end
        end
      end
    end
  end
end
