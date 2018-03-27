# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Sortitions
    describe SortitionSearch do
      let(:component) { create(:component, manifest_name: "sortitions") }
      let(:participatory_process) { component.participatory_space }
      let(:category) { create(:category, participatory_space: participatory_process) }
      let(:sortition) { create(:sortition, component: component) }
      let!(:categorization) do
        Decidim::Categorization.create!(decidim_category_id: category.id, categorizable: sortition)
      end

      describe "results" do
        subject do
          described_class.new(
            component: component,
            search_text: search_text,
            category_id: category_id,
            state: state
          ).results
        end

        let(:search_text) { nil }
        let(:category_id) { nil }
        let(:state) { "active" }

        it "only includes sortitions from the given component" do
          other_sortition = create(:sortition)

          expect(subject).to include(sortition)
          expect(subject).not_to include(other_sortition)
        end

        describe "search_text filter" do
          let(:search_text) { "dog" }

          it "returns the sortitions containing the search in the title or the aditional info or or witnesses" do
            create_list(:sortition, 3, component: component)
            create(:sortition, title: { en: "A dog" }, component: component)
            create(:sortition, additional_info: { en: "There is a dog in the office" }, component: component)
            create(:sortition, witnesses: { en: "My dog was there" }, component: component)

            expect(subject.size).to eq(3)
          end
        end

        describe "category_id filter" do
          let(:category_id) { category.id }

          it "Returns sortitions with the given category" do
            create_list(:sortition, 3, component: component)

            expect(subject.size).to eq(1)
          end
        end

        describe "state filter" do
          context "when Cancelled" do
            let(:state) { "cancelled" }

            it "Returns sortitions with the given state" do
              create_list(:sortition, 3, :cancelled, component: component)
              expect(subject.size).to eq(3)
            end
          end

          context "when Active" do
            let(:state) { "active" }

            it "Returns sortitions with the given state" do
              create_list(:sortition, 3, :cancelled, component: component)
              expect(subject.size).to eq(1)
            end
          end

          context "when all" do
            let(:state) { "all" }

            it "Returns sortitions whatever its state is" do
              create_list(:sortition, 3, :cancelled, component: component)
              expect(subject.size).to eq(4)
            end
          end
        end
      end
    end
  end
end
