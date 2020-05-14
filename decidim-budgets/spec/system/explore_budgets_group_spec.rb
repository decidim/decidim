# frozen_string_literal: true

require "spec_helper"

describe "Explore a budgets group component", type: :system do
  include_context "with a component"

  let(:manifest_name) { "budgets_groups" }
  let(:component) { create(:budgets_group_component, :with_children, settings: settings, participatory_space: participatory_space) }
  let(:budgets) { component.children }
  let(:settings) do
    {
      title: Decidim::Faker::Localized.sentence(5),
      description: Decidim::Faker::Localized.paragraph,
      list_heading: Decidim::Faker::Localized.paragraph,
      highlighted_heading: Decidim::Faker::Localized.paragraph,
      more_information: Decidim::Faker::Localized.paragraph,
      workflow: workflow
    }
  end
  let(:workflow) { :random }

  it "shows the custom texts" do
    visit_component

    expect(page).to have_i18n_content(settings[:title])
    expect(page).to have_i18n_content(settings[:description])
  end

  it "doesn't show the highlighted part" do
    visit_component

    expect(page).not_to have_selector("#highlighted_budget")
    expect(page).not_to have_i18n_content(settings[:highlighted_heading])
  end

  it "shows the list of budgets" do
    visit_component

    expect(page).to have_i18n_content(settings[:list_heading])

    within "#budgets" do
      expect(page).to have_selector(".card--list__item", count: budgets.count)

      budgets.each do |budget|
        expect(page).to have_i18n_content(budget.name)
      end
    end
  end

  context "when the user is logged" do
    let(:user) { create :user, :confirmed, organization: organization }

    before { login_as user, scope: :user }

    it "shows the highlighted heading text and a button to that budget" do
      visit_component

      within "#highlighted_budget" do
        expect(page).to have_i18n_content(settings[:highlighted_heading])
        expect(page).to have_selector(".button")
      end
    end

    context "when user has a pending order" do
      let!(:order) { create(:order, :with_projects, user: user, component: budgets.first) }

      it "shows the highlighted heading text and a button to the budget for the pending order" do
        visit_component

        within "#highlighted_budget" do
          expect(page).to have_i18n_content(settings[:highlighted_heading])
          expect(page).to have_i18n_content(order.component.name)
          expect(page).to have_selector(".button")
        end
      end

      it "shows a progress icon within the order's budgets component" do
        visit_component

        within "#budgets .card--list__data-progress" do
          expect(page).to have_i18n_content(order.component.name)
        end
      end
    end

    context "when user has a finished order" do
      let(:order) { create(:order, :with_projects, user: user, component: budgets.first) }

      before { order.update! checked_out_at: Time.current }

      it "shows the voted message and that the process has finished" do
        visit_component

        expect(page).to have_content "You've voted on"
        expect(page).to have_content "If you've changed your mind, you can delete your vote and start over"
      end

      it "allows to delete the vote" do
        visit_component

        click_link "delete your vote and start over"

        expect(page).to have_content "Your vote has been successfully canceled"
        expect(page).to have_current_path main_component_path(component)

        expect(page).not_to have_content("You've voted on")
      end

      it "shows a check icon within the order's budgets component" do
        visit_component

        within "#budgets .card--list__data-added" do
          expect(page).to have_i18n_content(order.component.name)
        end
      end
    end
  end

  describe "budgets flow integration" do
    let!(:project) { create(:project, component: budget, budget: 85_000_000) }
    let(:budget) { budgets.first }
    let(:workflow) { :one }
    let(:user) { create :user, :confirmed, organization: organization }

    before { login_as user, scope: :user }

    it "shows the more information dialog" do
      visit_component

      click_link translated(budget.name)
      click_button "More information"

      expect(page).to have_i18n_content(settings[:title])
      expect(page).to have_i18n_content(settings[:description])
      expect(page).to have_i18n_content(settings[:more_information])

      click_link "Back to #{translated(component.name)}"
      expect(page).to have_current_path main_component_path(component)
    end

    context "when user has a pending order" do
      before do
        visit_component

        click_link translated(budgets.first.name)

        within "#project-#{project.id}-item" do
          page.find(".budget-list__action").click
        end
      end

      it "doesn't allow the user to vote on other budget" do
        visit_component

        click_link translated(budgets.second.name)

        expect(page).not_to have_button("Vote", disabled: true)
      end

      it "offers the user to discard its pending order to vote on other budget" do
        visit_component

        click_link translated(budgets.second.name)

        expect(page).to have_content "You may discard your pending votes on other budgets to vote on this budget:"

        accept_prompt do
          click_link "Discard your pending vote on #{translated(budget.name)}"
        end

        expect(page).to have_content "Your vote has been successfully canceled"
        expect(page).to have_current_path main_component_path(budgets.second)
        expect(page).to have_button("Vote", disabled: true)
      end

      it "doesn't offer to the user to change its vote on the same budgets" do
        visit_component

        click_link translated(budget.name)

        expect(page).not_to have_content "You may discard your pending votes on other budgets to vote on this budget:"
      end
    end

    context "when user emits their vote" do
      before do
        visit_component

        click_link translated(budgets.first.name)

        within "#project-#{project.id}-item" do
          page.find(".budget-list__action").click
        end

        click_button "Vote"
        click_button "Confirm"
      end

      it "redirects to the budgets group page" do
        expect(page).to have_content "Your vote has been successfully accepted"
        expect(page).to have_current_path main_component_path(component)
      end

      it "doesn't allow voting on another budget" do
        click_link translated(budgets.second.name)
        expect(page).not_to have_button("Vote", disabled: true)
      end
    end
  end
end
