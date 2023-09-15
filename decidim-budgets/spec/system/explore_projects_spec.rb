# frozen_string_literal: true

require "spec_helper"

describe "Explore projects", :slow, type: :system do
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
          click_filter_item translated(category.name)
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
