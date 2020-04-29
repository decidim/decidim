# frozen_string_literal: true

require "spec_helper"

describe "Explore projects", :slow, type: :system do
  include_context "with a component"
  let(:manifest_name) { "budgets" }
  let(:projects_count) { 5 }
  let!(:projects) do
    create_list(:project, projects_count, component: component)
  end
  let!(:project) { projects.first }
  let(:categories) { create_list(:category, 3, participatory_space: component.participatory_space) }

  describe "index" do
    it "shows all resources for the given component" do
      visit_component
      within "#projects" do
        expect(page).to have_selector(".card--list__item", count: projects_count)
      end

      projects.each do |project|
        expect(page).to have_content(translated(project.title))
      end
    end

    context "when filtering" do
      it "allows searching by text" do
        visit_component
        within ".filters__search" do
          fill_in "filter[search_text]", with: translated(project.title)

          find(".button").click
        end

        within "#projects" do
          expect(page).to have_css(".card--list__item", count: 1)
          expect(page).to have_content(translated(project.title))
        end
      end

      it "allows filtering by scope" do
        scope = create(:scope, organization: organization)
        project.scope = scope
        project.save

        visit_component

        within ".scope_id_check_boxes_tree_filter" do
          uncheck "All"
          check translated(scope.name)
        end

        within "#projects" do
          expect(page).to have_css(".card--list__item", count: 1)
          expect(page).to have_content(translated(project.title))
        end
      end

      it "allows filtering by category" do
        category = categories.first
        project.category = category
        project.save

        visit_component

        within ".category_id_check_boxes_tree_filter" do
          uncheck "All"
          check translated(category.name)
        end

        within "#projects" do
          expect(page).to have_css(".card--list__item", count: 1)
          expect(page).to have_content(translated(project.title))
        end
      end
    end
  end
end
