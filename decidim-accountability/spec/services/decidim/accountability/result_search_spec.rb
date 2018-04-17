# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability
  describe ResultSearch do
    subject { described_class.new(params) }

    let(:current_component) { create :accountability_component }
    let(:scope1) { create :scope, organization: current_component.organization }
    let(:scope2) { create :scope, organization: current_component.organization }
    let(:scope3) { create :scope, organization: current_component.organization }
    let(:participatory_space) { current_component.participatory_space }
    let(:parent_category) { create :category, participatory_space: participatory_space }
    let(:subcategory) { create :subcategory, parent: parent_category }
    let!(:result1) do
      create(
        :result,
        component: current_component,
        category: parent_category,
        scope: scope1,
        parent: nil
      )
    end
    let!(:result2) do
      create(
        :result,
        component: current_component,
        category: subcategory,
        scope: scope2,
        parent: result1
      )
    end
    let!(:result3) do
      create(
        :result,
        component: current_component,
        category: parent_category,
        scope: scope3,
        parent: result2
      )
    end
    let(:external_result) { create :result }
    let(:component_id) { current_component.id }
    let(:organization_id) { current_component.organization.id }
    let(:default_params) do
      { component: current_component, deep_search: true }
    end
    let(:params) { default_params }

    describe "base query" do
      context "when no component is passed" do
        let(:default_params) { { component: nil } }

        it "raises an error" do
          expect { subject.results }.to raise_error(StandardError, "Missing component")
        end
      end
    end

    describe "filters" do
      describe "component_id" do
        it "only returns results from the given component" do
          external_result = create(:result)

          expect(subject.results).not_to include(external_result)
        end
      end

      describe "scope_id" do
        context "when a single id is being sent" do
          let(:params) { default_params.merge(scope_id: scope1.id) }

          it "filters results by scope" do
            expect(subject.results).to eq [result1]
          end
        end

        context "when multiple ids are sent" do
          let(:params) { default_params.merge(scope_id: [scope2.id, scope1.id]) }

          it "filters results by scope" do
            expect(subject.results).to match_array [result1, result2]
          end
        end

        context "when `global` is being sent" do
          let!(:resource_without_scope) { create(:result, component: current_component, scope: nil) }
          let(:params) { default_params.merge(scope_id: ["global"]) }

          it "returns resources without a scope" do
            expect(subject.results).to eq [resource_without_scope]
          end
        end
      end

      describe "category_id" do
        context "when the given category has no subcategories" do
          let(:params) { default_params.merge(category_id: subcategory.id) }

          it "returns only results from the given category" do
            expect(subject.results).to eq [result2]
          end
        end

        context "when the given category has some subcategories" do
          let(:params) { default_params.merge(category_id: parent_category.id) }

          it "returns results from this category and its children's" do
            expect(subject.results).to match_array [result1, result2]
          end
        end

        context "when the category does not belong to the current component" do
          let(:external_category) { create :category }
          let(:params) { default_params.merge(category_id: external_category.id) }

          it "returns an empty array" do
            expect(subject.results).to eq []
          end
        end
      end

      describe "parent_id" do
        context "when deep searching" do
          context "when the parent_id is nil" do
            let(:params) { default_params.merge(parent_id: nil) }

            it "returns the search on all results" do
              expect(subject.results).to match_array [result1, result2]
            end
          end

          context "when the parent_id is result1" do
            let(:params) { default_params.merge(parent_id: result1.id) }

            it "returns the search on the children of result" do
              expect(subject.results).to match_array [result2, result3]
            end
          end

          context "when the parent_id is result2" do
            let(:params) { default_params.merge(parent_id: result2.id) }

            it "returns the search on the children of result" do
              expect(subject.results).to match_array [result3]
            end
          end
        end

        context "when not deep searching" do
          context "when the parent_id is nil" do
            let(:params) { default_params.merge(parent_id: nil, deep_search: false) }

            it "returns the search on the result without parent" do
              expect(subject.results).to match_array [result1]
            end
          end

          context "when the parent_id is result1" do
            let(:params) { default_params.merge(parent_id: result1.id, deep_search: false) }

            it "returns the search on the children of result" do
              expect(subject.results).to match_array [result2]
            end
          end
        end
      end
    end
  end
end
