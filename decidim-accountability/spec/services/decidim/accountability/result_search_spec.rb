# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability
  describe ResultSearch do
    subject { described_class.new(params) }

    let(:current_feature) { create :accountability_feature }
    let(:scope1) { create :scope, organization: current_feature.organization }
    let(:scope2) { create :scope, organization: current_feature.organization }
    let(:participatory_space) { current_feature.participatory_space }
    let(:parent_category) { create :category, participatory_space: participatory_space }
    let(:subcategory) { create :subcategory, parent: parent_category }
    let!(:result1) do
      create(
        :result,
        feature: current_feature,
        category: parent_category,
        scope: scope1
      )
    end
    let!(:result2) do
      create(
        :result,
        feature: current_feature,
        category: subcategory,
        scope: scope2
      )
    end
    let(:external_result) { create :result }
    let(:feature_id) { current_feature.id }
    let(:organization_id) { current_feature.organization.id }
    let(:default_params) { { feature: current_feature } }
    let(:params) { default_params }

    describe "base query" do
      context "when no feature is passed" do
        let(:default_params) { { feature: nil } }

        it "raises an error" do
          expect { subject.results }.to raise_error(StandardError, "Missing feature")
        end
      end
    end

    describe "filters" do
      describe "feature_id" do
        it "only returns results from the given feature" do
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
          let!(:resource_without_scope) { create(:result, feature: current_feature, scope: nil) }
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
            expect(subject.results).to match_array [result2, result1]
          end
        end

        context "when the category does not belong to the current feature" do
          let(:external_category) { create :category }
          let(:params) { default_params.merge(category_id: external_category.id) }

          it "returns an empty array" do
            expect(subject.results).to eq []
          end
        end
      end
    end
  end
end
