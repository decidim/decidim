# frozen_string_literal: true
require "spec_helper"

describe Decidim::Debates::DebateSearch do
  let(:current_feature) { create :feature, manifest_name: "debates" }
  let(:parent_category) { create :category, participatory_space: current_feature.participatory_space }
  let(:subcategory) { create :subcategory, parent: parent_category }
  let!(:debate1) do
    create(
      :debate,
      feature: current_feature,
      start_time: 1.day.from_now,
      category: parent_category
    )
  end
  let!(:debate2) do
    create(
      :debate,
      feature: current_feature,
      start_time: 2.day.from_now,
      category: subcategory
    )
  end
  let(:external_debate) { create :debate }
  let(:feature_id) { current_feature.id }
  let(:organization_id) { current_feature.organization.id }
  let(:default_params) { { feature: current_feature } }
  let(:params) { default_params }

  subject { described_class.new(params) }

  describe "base query" do
    context "when no feature is passed" do
      let(:default_params) { { feature: nil } }

      it "raises an error" do
        expect { subject.results }.to raise_error(StandardError, "Missing feature")
      end
    end
  end

  describe "filters" do
    context "feature_id" do
      it "only returns debates from the given feature" do
        external_debate = create(:debate)

        expect(subject.results).not_to include(external_debate)
      end
    end

    context "order_start_time" do
      let(:params) { default_params.merge(order_start_time: order) }

      context "is :asc" do
        let(:order) { :asc }

        it "sorts the debates by start_time asc" do
          expect(subject.results).to eq [debate1, debate2]
        end
      end

      context "is :desc" do
        let(:order) { :desc }

        it "sorts the debates by start_time desc" do
          expect(subject.results).to eq [debate2, debate1]
        end
      end
    end

    context "category_id" do
      context "when the given category has no subcategories" do
        let(:params) { default_params.merge(category_id: subcategory.id) }

        it "returns only debates from the given category" do
          expect(subject.results).to eq [debate2]
        end
      end

      context "when the given category has some subcategories" do
        let(:params) { default_params.merge(category_id: parent_category.id) }

        it "returns debates from this category and its children's" do
          expect(subject.results).to match_array [debate2, debate1]
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
