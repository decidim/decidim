# frozen_string_literal: true

require "spec_helper"

describe "Budgets Breadcrumb" do
  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, :with_steps, :published, organization:, title: { "en" => "Participatory space" }) }
  let(:component) { create(:budgets_component, :published, :with_votes_disabled, participatory_space:, name: { "en" => "Component" }) }
  let(:budget) { create(:budget, component:, title: { "en" => "Budget" }) }
  let!(:project) { create(:project, budget:, title: { "en" => "Project" }) }
  let(:router) { Decidim::EngineRouter.main_proxy(component) }

  before do
    switch_to_host(organization.host)
  end

  context "when visiting the budgets index page" do
    it "shows the correct information in breadcrumb (space, component)" do
      visit router.root_path(locale: I18n.locale)

      within ".menu-bar" do
        expect(page).to have_content(translated(component.participatory_space.title))
        expect(page).to have_content(translated(component.name))
      end
    end
  end

  context "when visiting single budget page" do
    it "shows the correct information in breadcrumb (space, component, budget)" do
      visit router.budget_path(budget, locale: I18n.locale)

      within ".menu-bar" do
        expect(page).to have_content(translated(component.participatory_space.title))
        expect(page).to have_content(translated(component.name))
        expect(page).to have_content(translated(budget.title))
      end
    end
  end

  context "when visiting single project page" do
    it "shows the correct information in breadcrumb (space, component, budget, project)" do
      visit router.budget_project_path(budget, project, locale: I18n.locale)

      within ".menu-bar" do
        expect(page).to have_content(translated(component.participatory_space.title))
        expect(page).to have_content(translated(component.name))
        expect(page).to have_content(translated(budget.title))
        expect(page).to have_content(translated(project.title))
      end
    end
  end
end
