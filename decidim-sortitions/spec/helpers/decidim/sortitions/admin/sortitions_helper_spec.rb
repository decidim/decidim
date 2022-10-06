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

        describe "sortition_category" do
          let(:sortition) { double(category:) }

          context "when category is null" do
            let(:category) { nil }

            it "Returns all categories" do
              expect(helper.sortition_category(sortition)).to eq("All categories")
            end
          end

          context "when category is not null" do
            let(:category) { double(name: { "en" => "Category name" }) }

            it "Returns the category name" do
              expect(helper.sortition_category(sortition)).to eq("Category name")
            end
          end
        end
      end
    end
  end
end
