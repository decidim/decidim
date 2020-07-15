# frozen_string_literal: true

require "spec_helper"

describe "Sorting projects", type: :system do
  include_context "with a component"
  let(:manifest_name) { "budgets" }

  let(:organization) { create :organization }
  let!(:user) { create :user, :confirmed, organization: organization }
  let(:project) { projects.first }

  let!(:component) do
    create(:budget_component,
           :with_total_budget_and_vote_threshold_percent,
           manifest: manifest,
           participatory_space: participatory_process)
  end

  let!(:project1) { create(:project, component: component, budget: 25_000_000) }
  let!(:project2) { create(:project, component: component, budget: 50_000_000) }

  before do
    login_as user, scope: :user
    visit_component
  end

  shared_examples "ordering projects by selected option" do |selected_option|
    before do
      visit_component
      within ".order-by" do
        expect(page).to have_selector("ul[data-dropdown-menu$=dropdown-menu]", text: "Random order")
        page.find("a", text: "Random order").hover
        click_link(selected_option)
      end
    end

    it "lists the projects ordered by selected option" do
      # expect(page).to have_selector("#projects li.is-dropdown-submenu-parent a", text: selected_option)
      within "#projects li.is-dropdown-submenu-parent a" do
        expect(page).to have_no_content("Random order", wait: 20)
        expect(page).to have_content(selected_option)
      end

      expect(page).to have_selector("#projects .budget-list .budget-list__item:first-child", text: translated(first_project.title))
      expect(page).to have_selector("#projects .budget-list .budget-list__item:last-child", text: translated(last_project.title))
    end
  end

  context "when ordering by highest cost" do
    it_behaves_like "ordering projects by selected option", "Highest cost" do
      let(:first_project) { project2 }
      let(:last_project) { project1 }
    end
  end

  context "when ordering by lowest cost" do
    it_behaves_like "ordering projects by selected option", "Lowest cost" do
      let(:first_project) { project1 }
      let(:last_project) { project2 }
    end
  end

  describe "when the voting is finished" do
    let!(:component) do
      create(
        :budget_component,
        :with_voting_finished,
        manifest: manifest,
        participatory_space: participatory_process
      )
    end
    let!(:project1) { create(:project, component: component, budget: 25_000_000) }
    let!(:project2) { create(:project, component: component, budget: 77_000_000) }

    context "when ordering by most votes" do
      before do
        order = build :order, component: component
        create :line_item, order: order, project: project2
        order = Decidim::Budgets::Order.last
        order.checked_out_at = Time.zone.now
        order.save
      end

      it "automatically sorts by votes" do
        visit_component

        within "#projects li.is-dropdown-submenu-parent a" do
          expect(page).to have_content("Most voted")
        end

        expect(page).to have_selector("#projects .budget-list .budget-list__item:first-child", text: translated(project2.title))
        expect(page).to have_selector("#projects .budget-list .budget-list__item:last-child", text: translated(project1.title))
      end
    end
  end
end
