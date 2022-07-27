# frozen_string_literal: true

require "spec_helper"

describe "Admin filters, searches, and paginates results", type: :system do
  include_context "when managing a component as an admin"
  include_context "with filterable context"

  let(:manifest_name) { "accountability" }
  let(:resource_controller) { Decidim::Accountability::Admin::ResultsController }

  context "when filtering by scope" do
    let!(:scope1) do
      create(:scope, organization: component.organization, name: { "en" => "Scope1" })
    end
    let!(:scope2) do
      create(:scope, organization: component.organization, name: { "en" => "Scope2" })
    end
    let!(:result_with_scope1) do
      create(:result, component: current_component,
                      title: Decidim::Faker::Localized.localized { generate(:title) },
                      scope: scope1)
    end
    let(:result_with_scope1_title) { translated(result_with_scope1.title) }
    let!(:result_with_scope2) do
      create(:result, component: current_component,
                      title: Decidim::Faker::Localized.localized { generate(:title) },
                      scope: scope2)
    end
    let(:result_with_scope2_title) { translated(result_with_scope2.title) }

    before { visit_component_admin }

    it_behaves_like "a filtered collection", options: "Scope", filter: "Scope1" do
      let(:in_filter) { result_with_scope1_title }
      let(:not_in_filter) { result_with_scope2_title }
    end

    it_behaves_like "a filtered collection", options: "Scope", filter: "Scope2" do
      let(:in_filter) { result_with_scope2_title }
      let(:not_in_filter) { result_with_scope1_title }
    end
  end

  context "when filtering by category" do
    let!(:category1) do
      create(:category, participatory_space:,
                        name: { "en" => "Category1" })
    end
    let!(:category2) do
      create(:category, participatory_space:,
                        name: { "en" => "Category2" })
    end
    let!(:result_with_category1) do
      create(:result, component: current_component,
                      title: Decidim::Faker::Localized.localized { generate(:title) },
                      category: category1)
    end
    let(:result_with_category1_title) { translated(result_with_category1.title) }
    let!(:result_with_category2) do
      create(:result, component: current_component,
                      title: Decidim::Faker::Localized.localized { generate(:title) },
                      category: category2)
    end
    let(:result_with_category2_title) { translated(result_with_category2.title) }

    before { visit_component_admin }

    it_behaves_like "a filtered collection", options: "Category", filter: "Category1" do
      let(:in_filter) { result_with_category1_title }
      let(:not_in_filter) { result_with_category2_title }
    end

    it_behaves_like "a filtered collection", options: "Category", filter: "Category2" do
      let(:in_filter) { result_with_category2_title }
      let(:not_in_filter) { result_with_category1_title }
    end
  end

  context "when filtering by status" do
    let!(:status1) { create(:status, component: current_component, name: { "en" => "Status1" }) }
    let!(:status2) { create(:status, component: current_component, name: { "en" => "Status2" }) }
    let!(:result_with_status1) do
      create(:result, component: current_component,
                      title: Decidim::Faker::Localized.localized { generate(:title) },
                      status: status1)
    end
    let(:result_with_status1_title) { translated(result_with_status1.title) }
    let!(:result_with_status2) do
      create(:result, component: current_component,
                      title: Decidim::Faker::Localized.localized { generate(:title) },
                      status: status2)
    end
    let(:result_with_status2_title) { translated(result_with_status2.title) }

    before { visit_component_admin }

    it_behaves_like "a filtered collection", options: "Status", filter: "Status1" do
      let(:in_filter) { result_with_status1_title }
      let(:not_in_filter) { result_with_status2_title }
    end

    it_behaves_like "a filtered collection", options: "Status", filter: "Status2" do
      let(:in_filter) { result_with_status2_title }
      let(:not_in_filter) { result_with_status1_title }
    end
  end

  context "when searching by ID or title" do
    let!(:result1) do
      create(:result, component: current_component,
                      title: Decidim::Faker::Localized.localized { generate(:title) })
    end
    let!(:result2) do
      create(:result, component: current_component,
                      title: Decidim::Faker::Localized.localized { generate(:title) })
    end
    let!(:result1_title) { translated(result1.title) }
    let!(:result2_title) { translated(result2.title) }

    it "can be searched by ID" do
      search_by_text(result1.id)

      expect(page).to have_content(result1_title)
    end

    it "can be searched by title" do
      search_by_text(result2_title)

      expect(page).to have_content(result2_title)
    end
  end

  context "when listing results" do
    it_behaves_like "paginating a collection" do
      let!(:collection) { create_list(:result, 50, component: current_component) }
    end
  end
end
