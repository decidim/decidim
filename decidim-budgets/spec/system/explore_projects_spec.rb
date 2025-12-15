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
  let(:taxonomy) { create(:taxonomy, :with_parent, skip_injection: true, organization:) }
  let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy: taxonomy.parent) }
  let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy) }

  let(:second_taxonomy) { create(:taxonomy, :with_parent, skip_injection: true, organization:) }
  let(:second_taxonomy_filter) { create(:taxonomy_filter, root_taxonomy: second_taxonomy.parent) }
  let!(:second_taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter: second_taxonomy_filter, taxonomy_item: second_taxonomy) }
  let(:taxonomy_filter_ids) { [taxonomy_filter.id, second_taxonomy_filter.id] }

  before do
    component_settings = component["settings"]["global"].merge!(taxonomy_filters: taxonomy_filter_ids)
    component.update!(settings: component_settings)
  end

  describe "show" do
    let(:description) { { en: "Short description", ca: "Descripció curta", es: "Descripción corta" } }
    let(:project) { create(:project, budget:, description:) }

    context "when voting is open" do
      before do
        visit_budget
        click_on translated(project.title)
      end

      it_behaves_like "has embedded video in description", :description
    end

    context "when voting is finished" do
      let(:active_step_id) { participatory_process.active_step.id }

      before do
        component.update!(step_settings: { active_step_id => { votes: :finished, show_votes: } })

        visit_budget
        click_on translated(project.title)
      end

      context "when 'show votes' setting is disabled" do
        let(:show_votes) { false }

        it "does not show the votes" do
          expect(page).to have_no_css("[data-spec-project-votes]", text: 0)
        end
      end

      context "when 'show votes' setting is enabled" do
        let(:show_votes) { true }

        it "shows the votes" do
          expect(page).to have_css("[data-spec-project-votes]", text: 0)
        end
      end
    end
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
        expect(page).to have_css(".card__list", count: projects_count)
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
          Decidim::Budgets::Project.where(budget: budget).geocoded.each_with_index do |project, index|
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
            click_on
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
            click_on
          end
        end

        expect(page).to have_no_content("Another project")
        expect(page).to have_content("Foobar project")

        filter_params = CGI.parse(URI.parse(page.current_url).query)
        expect(filter_params["filter[search_text_cont]"]).to eq(["foobar"])
      end

      it "collapses the accordions on click" do
        visit_budget

        within "#panel-dropdown-menu-taxonomy-#{second_taxonomy_filter.root_taxonomy_id}" do
          expect(page).to have_content "All"
          expect(page).to have_content decidim_sanitize_translated(second_taxonomy.name)
        end

        click_on decidim_sanitize_translated(second_taxonomy_filter.root_taxonomy.name)
        click_on decidim_sanitize_translated(taxonomy_filter.root_taxonomy.name)

        within ".layout-2col__aside" do
          expect(page).to have_no_content decidim_sanitize_translated(taxonomy.name)
          expect(page).to have_no_content decidim_sanitize_translated(second_taxonomy.name)
        end

        click_on decidim_sanitize_translated(second_taxonomy_filter.root_taxonomy.name)

        within ".layout-2col__aside" do
          expect(page).to have_no_content decidim_sanitize_translated(taxonomy.name)
          expect(page).to have_content decidim_sanitize_translated(second_taxonomy.name)
        end
      end

      it "allows filtering by taxonomy" do
        project.taxonomies = [taxonomy]
        project.save

        visit_budget

        within "#panel-dropdown-menu-taxonomy-#{taxonomy.parent.id}" do
          click_filter_item decidim_escape_translated(taxonomy.name)
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
            expect(page).to have_content("0 votes")
          end
        end

        context "and votes are not shown" do
          let(:active_step_id) { component.participatory_space.active_step.id }

          before do
            component.update!(step_settings: { active_step_id => { show_votes: false } })
          end

          it "does not show the votes" do
            visit_budget

            within "#projects" do
              expect(page).to have_no_content("0 votes")
            end
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

  describe "search" do
    before do
      switch_to_host(organization.host)
      visit decidim.search_path
    end

    it "shows the project" do
      expect(page).to have_content(translated_attribute(projects.last.title))
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
