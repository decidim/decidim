# frozen_string_literal: true

require "spec_helper"

describe "Explore projects", :slow do
  include_context "with a component"
  let(:manifest_name) { "budgets" }
  let(:budget) { create(:budget, component:) }
  let(:projects_count) { 5 }
  let!(:projects) do
    create_list(:project, projects_count, budget:)
  end
  let!(:project) { projects.first }
  let(:categories) { create_list(:category, 3, participatory_space: component.participatory_space) }

  describe "show" do
    let(:description) { { en: "Short description", ca: "Descripció curta", es: "Descripción corta" } }
    let(:project) { create(:project, budget:, description:) }

    before do
      visit_budget
      click_link translated(project.title)
    end

    it_behaves_like "has embedded video in description", :description
  end

  describe "index" do
    context "when there are no projects" do
      let!(:projects) { nil }
      let(:project) { nil }

      it "shows an empty page with a message" do
        visit_budget

        expect(page).to have_content("There are no projects yet")
      end
    end

    it "shows all resources for the given component" do
      visit_budget
      within "#projects" do
        expect(page).to have_selector(".card__list", count: projects_count)
      end

      projects.each do |project|
        expect(page).to have_content(translated(project.title))
      end
    end

    context "when filtering" do
      context "when maps are enabled" do
        let(:component) { create(:budgets_component, :with_geocoding_enabled, participatory_space: participatory_process) }
        let!(:projects) { create_list(:project, 2, budget:) }
        let!(:findable_project) { create(:project, budget:, title: { en: "Findable project" }) }
        let!(:another_findable_project) { create(:project, budget:, title: { en: "Findable project number 2" }) }

        # We are providing a list of coordinates to make sure the points are scattered all over the map
        # otherwise, there is a chance that markers can be clustered, which may result in a flaky spec.
        before do
          coordinates = [
            [-95.501705376541395, 95.10059236654689],
            [-95.501705376541395, -95.10059236654689],
            [95.10059236654689, -95.501705376541395],
            [95.10059236654689, 95.10059236654689],
            [142.15275006889419, -33.33377235135252],
            [33.33377235135252, -142.15275006889419],
            [-33.33377235135252, 142.15275006889419],
            [-142.15275006889419, 33.33377235135252],
            [-55.28745034772282, -35.587843900166945]
          ]
          Decidim::Budgets::Project.where(budget:).geocoded.each_with_index do |project, index|
            project.update!(latitude: coordinates[index][0], longitude: coordinates[index][1]) if coordinates[index]
          end

          visit_budget
        end

        it "shows markers for selected project" do
          expect(page).to have_css(".leaflet-marker-icon", count: 4)
          within "#dropdown-menu-filters" do
            fill_in("filter[search_text_cont]", with: "Findable")
            within "div.filter-search" do
              click_on
            end
          end
          expect(page).to have_css(".leaflet-marker-icon", count: 2)

          expect_no_js_errors
        end
      end

      it "allows searching by text" do
        visit_budget
        within "aside form.new_filter" do
          fill_in "filter[search_text_cont]", with: translated(project.title)

          within "div.filter-search" do
            click_button
          end
        end

        within "#projects" do
          expect(page).to have_css(".card__list", count: 1)
          expect(page).to have_content(translated(project.title))
        end
      end

      it "updates the current URL with the text filter" do
        create(:project, budget:, title: { en: "Foobar project" })
        create(:project, budget:, title: { en: "Another project" })
        visit_budget

        within "aside form.new_filter" do
          fill_in("filter[search_text_cont]", with: "foobar")
          within "div.filter-search" do
            click_button
          end
        end

        expect(page).not_to have_content("Another project")
        expect(page).to have_content("Foobar project")

        filter_params = CGI.parse(URI.parse(page.current_url).query)
        expect(filter_params["filter[search_text_cont]"]).to eq(["foobar"])
      end

      it "allows filtering by scope" do
        scope = create(:scope, organization:)
        project.scope = scope
        project.save

        visit_budget

        within "#panel-dropdown-menu-scope" do
          click_filter_item translated(scope.name)
        end

        within "#projects" do
          expect(page).to have_css(".card__list", count: 1)
          expect(page).to have_content(translated(project.title))
        end
      end

      it "allows filtering by category" do
        category = categories.first
        project.category = category
        project.save

        visit_budget

        within "#panel-dropdown-menu-category" do
          click_filter_item decidim_escape_translated(category.name)
        end

        within "#projects" do
          expect(page).to have_css(".card__list", count: 1)
          expect(page).to have_content(translated(project.title))
        end
      end

      context "and votes are finished" do
        let!(:component) do
          create(:budgets_component,
                 :with_voting_finished,
                 manifest:,
                 participatory_space: participatory_process)
        end

        it "allows filtering by status" do
          project.selected_at = Time.current
          project.save

          visit_budget

          within "#panel-dropdown-menu-status" do
            click_filter_item "Selected"
          end

          within "#projects" do
            expect(page).to have_css(".card__list", count: 1)
            expect(page).to have_content(translated(project.title))
          end
        end
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
