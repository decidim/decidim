# frozen_string_literal: true

require "spec_helper"

describe "Explore projects", :slow, type: :system do
  include_context "with a component"
  let(:manifest_name) { "budgets" }
  let(:budget) { create :budget, component: component }
  let(:projects_count) { 5 }
  let!(:projects) do
    create_list(:project, projects_count, budget: budget)
  end
  let!(:project) { projects.first }
  let(:categories) { create_list(:category, 3, participatory_space: component.participatory_space) }

  describe "index" do
    it "shows all resources for the given component" do
      visit_budget
      within "#projects" do
        expect(page).to have_selector(".budget-list__item", count: projects_count)
      end

      projects.each do |project|
        expect(page).to have_content(translated(project.title))
      end
    end

    context "when filtering" do
      it "allows searching by text" do
        visit_budget
        within ".filters__search" do
          fill_in "filter[search_text_cont]", with: translated(project.title)

          find(".button").click
        end

        within "#projects" do
          expect(page).to have_css(".budget-list__item", count: 1)
          expect(page).to have_content(translated(project.title))
        end
      end

      it "allows filtering by scope" do
        scope = create(:scope, organization: organization)
        project.scope = scope
        project.save

        visit_budget

        within ".with_any_scope_check_boxes_tree_filter" do
          uncheck "All"
          check translated(scope.name)
        end

        within "#projects" do
          expect(page).to have_css(".budget-list__item", count: 1)
          expect(page).to have_content(translated(project.title))
        end
      end

      it "allows filtering by category" do
        category = categories.first
        project.category = category
        project.save

        visit_budget

        within ".with_any_category_check_boxes_tree_filter" do
          uncheck "All"
          check translated(category.name)
        end

        within "#projects" do
          expect(page).to have_css(".budget-list__item", count: 1)
          expect(page).to have_content(translated(project.title))
        end
      end

      it "works with 'back to list' link" do
        category = categories.first
        project.category = category
        project.save

        visit_budget

        within ".with_any_category_check_boxes_tree_filter" do
          uncheck "All"
          check translated(category.name)
        end

        within "#projects" do
          expect(page).to have_css(".budget-list__item", count: 1)
          expect(page).to have_content(translated(project.title))
        end

        page.find(".budget-list__item .card__link", match: :first).click
        click_link "View all projects"

        take_screenshot
        within "#projects" do
          expect(page).to have_css(".budget-list__item", count: 1)
          expect(page).to have_content(translated(project.title))
        end
      end

      context "and votes are finished" do
        let!(:component) do
          create(:budgets_component,
                 :with_voting_finished,
                 manifest: manifest,
                 participatory_space: participatory_process)
        end

        it "allows filtering by status" do
          project.selected_at = Time.current
          project.save

          visit_budget

          within ".with_any_status_check_boxes_tree_filter" do
            uncheck "Selected"
          end

          within "#projects" do
            expect(page).to have_css(".budget-list__item", count: 1)
            expect(page).to have_content(translated(project.title))
          end
        end
      end
    end

    context "when geocoding is enabled" do
      before do
        component.update!(settings: { geocoding_enabled: true })

        allow(Decidim.config).to receive(:maps).and_return({
                                                             provider: :here,
                                                             api_key: Rails.application.secrets.maps[:api_key],
                                                             static: { url: "https://image.maps.ls.hereapi.com/mia/1.6/mapview" }
                                                           })
        # To make sure there are 5 points distinct
        projects[0].update!(latitude: -10)
        projects[0].update!(longitude: -10)
        projects[1].update!(latitude: -10)
        projects[1].update!(longitude: 10)
        projects[2].update!(latitude: 0)
        projects[2].update!(longitude: 0)
        projects[3].update!(latitude: 10)
        projects[3].update!(longitude: -10)
        projects[4].update!(latitude: 10)
        projects[4].update!(longitude: 10)

        visit_budget
      end

      it "displays a map with the projects", :slow do
        expect(page).to have_selector("div[data-decidim-map]")
        expect(find("div[data-decidim-map]")["data-decidim-map"]).to have_content("latitude", count: 5)
        expect(page).to have_selector(".leaflet-marker-icon", count: 5)
      end

      it "can be clicked", :slow do
        find(".leaflet-marker-icon[title='#{project.title["en"]}']").click
        within ".leaflet-popup-content-wrapper" do
          expect(page).to have_content(project.title["en"])
          find(".button--sc").click
        end
        expect(page).to have_content(project.address)
      end
    end

    context "when directly accessing from URL with an invalid budget id" do
      it_behaves_like "a 404 page" do
        let(:target_path) { decidim_budgets.budget_projects_path(99_999_999) }
      end
    end

    context "when directly accessing from URL with an invalid project id" do
      it_behaves_like "a 404 page" do
        let(:target_path) { decidim_budgets.budget_project_path(budget, 99_999_999) }
      end
    end
  end

  private

  def decidim_budgets
    Decidim::EngineRouter.main_proxy(component)
  end

  def visit_budget
    page.visit decidim_budgets.budget_projects_path(budget)
  end
end
