# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Result search", type: :request do
  include Decidim::ComponentPathHelper

  let(:component) { create :accountability_component }
  let(:participatory_space) { component.participatory_space }
  let(:parent_id) { nil }
  let(:filter_params) { {} }

  let!(:result1) do
    create(
      :result,
      component: component,
      parent: nil,
      category: create(:category, participatory_space: participatory_space)
    )
  end
  let!(:result2) do
    create(
      :result,
      component: component,
      parent: result1,
      category: create(:category, participatory_space: participatory_space)
    )
  end
  let!(:result3) do
    create(
      :result,
      component: component,
      parent: result2,
      category: create(:category, participatory_space: participatory_space)
    )
  end

  let(:request_path) { main_component_path(component) }

  before do
    get(
      request_path,
      params: { parent_id: parent_id, filter: filter_params },
      headers: { "HOST" => component.organization.host }
    )
  end

  describe "home" do
    subject { response.body }

    it "displays all categories that have top-level results" do
      expect(subject).to include(translated(result1.category.name))
    end

    it "does not display the categories that only have sub-results" do
      expect(subject).not_to include(translated(result2.category.name))
      expect(subject).not_to include(translated(result3.category.name))
    end
  end

  describe "results" do
    subject { assigns(:results) }

    let(:request_path) { "#{main_component_path(component)}/results" }

    context "when deep searching" do
      context "when the parent_id is nil" do
        it "returns the search on all results" do
          expect(subject).to match_array [result1, result2]
        end
      end

      context "when the parent_id is result1" do
        let(:parent_id) { result1.id }

        it "returns the search on the children of result" do
          expect(subject).to match_array [result2, result3]
        end
      end

      context "when the parent_id is result2" do
        let(:parent_id) { result2.id }

        it "returns the search on the children of result" do
          expect(subject).to match_array [result3]
        end
      end
    end
  end
end
