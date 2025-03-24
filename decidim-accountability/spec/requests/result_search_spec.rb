# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Result search" do
  include Decidim::ComponentPathHelper

  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, organization:) }
  let(:component) { create(:accountability_component, participatory_space:, settings: { taxonomy_filters: [taxonomy_filter.id] }) }
  let(:parent_id) { nil }
  let(:filter_params) { {} }
  let(:root_taxonomy) { create(:taxonomy, organization:) }
  let(:taxonomy1) { create(:taxonomy, parent: root_taxonomy, organization:) }
  let(:taxonomy2) { create(:taxonomy, parent: root_taxonomy, organization:) }
  let(:child_taxonomy1) { create(:taxonomy, organization:, parent: taxonomy1) }
  let(:child_taxonomy2) { create(:taxonomy, organization:, parent: taxonomy2) }
  let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:, participatory_space_manifests: [participatory_space.manifest.name]) }
  let!(:taxonomy_filter_item1) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy1) }
  let!(:taxonomy_filter_item2) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy2) }
  let!(:taxonomy_filter_item3) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: child_taxonomy1) }
  let!(:taxonomy_filter_item4) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: child_taxonomy2) }

  let!(:result1) do
    create(
      :result,
      title: Decidim::Faker::Localized.literal("A doggo in the title"),
      component:,
      parent: nil,
      taxonomies: [taxonomy1]
    )
  end
  let!(:result2) do
    create(
      :result,
      description: Decidim::Faker::Localized.literal("There is a doggo in the office"),
      component:,
      parent: result1,
      taxonomies: [taxonomy2]
    )
  end
  let!(:result3) do
    create(
      :result,
      component:,
      parent: result2,
      taxonomies: [child_taxonomy1]
    )
  end
  let!(:result4) do
    create(
      :result,
      component:,
      parent: nil,
      taxonomies: [child_taxonomy2]
    )
  end

  let(:request_path) { main_component_path(component) }

  before do
    get(
      request_path,
      params: { parent_id:, filter: filter_params },
      headers: { "HOST" => component.organization.host }
    )
  end

  describe "home" do
    subject { response.body }

    it "displays all taxonomies that have top-level results" do
      expect(subject).to include(decidim_escape_translated(taxonomy1.name))
      expect(subject).to include(decidim_escape_translated(taxonomy2.name))
      expect(subject).not_to include(decidim_escape_translated(child_taxonomy1.name))
      expect(subject).to include(decidim_escape_translated(child_taxonomy2.name))
    end
  end

  describe "results" do
    subject { assigns(:results) }

    let(:request_path) { "#{main_component_path(component)}/results" }

    context "when deep searching" do
      context "when the parent_id is nil" do
        it "returns the search on all results" do
          expect(subject).to contain_exactly(result1, result2, result4)
        end
      end

      context "when the parent_id is result1" do
        let(:parent_id) { result1.id }

        it "returns the search on the children of result" do
          expect(subject).to contain_exactly(result2, result3)
        end
      end

      context "when the parent_id is result2" do
        let(:parent_id) { result2.id }

        it "returns the search on the children of result" do
          expect(subject).to contain_exactly(result3)
        end
      end
    end

    context "when searching by text" do
      let(:filter_params) { { search_text_cont: "doggo" } }

      it "returns the search results matching the word in title or description" do
        expect(subject).to contain_exactly(result1, result2)
      end
    end
  end
end
