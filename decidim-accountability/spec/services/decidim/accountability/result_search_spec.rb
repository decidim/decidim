# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability
  describe ResultSearch do
    subject { described_class.new(params).results }

    let(:component) { create :accountability_component }
    let(:participatory_space) { component.participatory_space }
    let(:default_params) do
      { component: component, deep_search: true }
    end
    let(:params) { default_params }

    it_behaves_like "a resource search", :result
    it_behaves_like "a resource search with scopes", :result
    it_behaves_like "a resource search with categories", :result

    describe "filters" do
      let!(:result1) do
        create(
          :result,
          component: component,
          parent: nil
        )
      end
      let!(:result2) do
        create(
          :result,
          component: component,
          parent: result1
        )
      end
      let!(:result3) do
        create(
          :result,
          component: component,
          parent: result2
        )
      end

      describe "parent_id" do
        context "when deep searching" do
          context "when the parent_id is nil" do
            let(:params) { default_params.merge(parent_id: nil) }

            it "returns the search on all results" do
              expect(subject).to match_array [result1, result2]
            end
          end

          context "when the parent_id is result1" do
            let(:params) { default_params.merge(parent_id: result1.id) }

            it "returns the search on the children of result" do
              expect(subject).to match_array [result2, result3]
            end
          end

          context "when the parent_id is result2" do
            let(:params) { default_params.merge(parent_id: result2.id) }

            it "returns the search on the children of result" do
              expect(subject).to match_array [result3]
            end
          end
        end

        context "when not deep searching" do
          context "when the parent_id is nil" do
            let(:params) { default_params.merge(parent_id: nil, deep_search: false) }

            it "returns the search on the result without parent" do
              expect(subject).to match_array [result1]
            end
          end

          context "when the parent_id is result1" do
            let(:params) { default_params.merge(parent_id: result1.id, deep_search: false) }

            it "returns the search on the children of result" do
              expect(subject).to match_array [result2]
            end
          end
        end
      end
    end
  end
end
