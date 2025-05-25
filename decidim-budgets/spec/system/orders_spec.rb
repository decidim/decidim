# frozen_string_literal: true

require "spec_helper"

describe "Orders" do
  include_context "with a component"
  let(:manifest_name) { "budgets" }

  let(:organization) { create(:organization, available_authorizations: %w(dummy_authorization_handler another_dummy_authorization_handler)) }
  let!(:user) { create(:user, :confirmed, organization:) }
  let(:project) { projects.first }

  let!(:component) do
    create(:budgets_component,
           :with_vote_threshold_percent,
           manifest:,
           participatory_space: participatory_process)
  end
  let(:budget) { create(:budget, component:) }

  context "when the user is not logged in" do
    let!(:projects) { create_list(:project, 1, budget:, budget_amount: 25_000_000) }

    it "is given the option to sign in" do
      visit_budget

      within "#project-#{project.id}-item" do
        page.find(".budget-list__action").click
      end

      expect(page).to have_css("#loginModal", visible: :visible)
    end
  end

  context "when the user is logged in" do
    let!(:projects) { create_list(:project, 3, budget:, budget_amount: 25_000_000) }

    before do
      login_as user, scope: :user
    end

    context "when visiting budget" do
      before do
        visit_budget
      end

      it "shows a filter to select added projects" do
        within(".budget__list--header") do
          expect(page).to have_text("Added")
        end
      end

      context "when voting by percentage threshold" do
        it "displays description messages" do
          within ".budget-summary", match: :first do
            expect(page).to have_content("Start adding projects. Assign at least €70,000,000 to the projects you want and vote according to your preferences to define the budget.")
          end
        end
      end

      context "when voting by minimum projects number" do
        let!(:component) do
          create(:budgets_component,
                 :with_minimum_budget_projects,
                 manifest:,
                 participatory_space: participatory_process)
        end

        it "displays description messages" do
          within ".budget-summary", match: :first do
            expect(page).to have_content("Start adding projects. Select at least 3 projects you want and vote according to your preferences to define the budget.")
          end
        end
      end

      context "when voting by maximum projects number" do
        let!(:component) do
          create(:budgets_component,
                 :with_budget_projects_range,
                 vote_minimum_budget_projects_number: 0,
                 manifest:,
                 participatory_space: participatory_process)
        end

        it "displays description messages" do
          within ".budget-summary", match: :first do
            expect(page).to have_content("Start adding projects. Select up to 6 projects you want and vote according to your preferences to define the budget.")
          end
        end
      end

      context "when voting by minimum and maximum projects number" do
        let!(:component) do
          create(:budgets_component,
                 :with_budget_projects_range,
                 manifest:,
                 participatory_space: participatory_process)
        end

        it "displays description messages" do
          within ".budget-summary", match: :first do
            expect(page).to have_content("Start adding projects. Select at least 3 and up to 6 projects you want and vote according to your preferences to define the budget.")
          end
        end
      end

      context "when the total budget is zero" do
        let(:budget) { create(:budget, total_budget: 0, component:) }

        it "displays total budget" do
          within ".budget-summary", match: :first do
            expect(page).to have_content("€0\nBudget")
          end
        end
      end
    end

    context "and has not a pending order" do
      before do
        visit_budget
      end

      context "when voting by percentage threshold" do
        it "adds a project to the current order" do
          within "#project-#{project.id}-item" do
            page.find(".budget-list__action").click
          end

          expect(page).to have_css ".budget-list__data--added", count: 1

          within ".budget-summary__progressbar-marks", match: :first do
            expect(page).to have_content(/€25,000,000\sAssigned/)
          end
          within ".budget__list--header" do
            expect(page).to have_content(/Added\s1/)
          end

          within "#order-progress .budget-summary__content", match: :first do
            expect(page).to have_css ".budget-summary__progressbar--meter", style: "width: 25%"
            expect(page).to have_button(disabled: true, text: "Vote budget")
          end
        end

        it "displays total budget" do
          expect(page).to have_css(".budget-summary__progressbar-marks_right", text: "€100,000,000")
        end
      end

      context "when voting by minimum projects number" do
        let!(:component) do
          create(:budgets_component,
                 :with_minimum_budget_projects,
                 manifest:,
                 participatory_space: participatory_process)
        end

        it "adds a project to the current order" do
          within "#project-#{project.id}-item" do
            page.find(".budget-list__action").click
          end

          expect(page).to have_css ".budget-list__data--added", count: 1

          within ".budget-summary__progressbar-marks", match: :first do
            expect(page).to have_content(/€25,000,000\sAssigned/)
          end
          within ".budget__list--header" do
            expect(page).to have_content(/Added\s1/)
          end

          within "#order-progress .budget-summary__content", match: :first do
            expect(page).to have_css ".budget-summary__progressbar--meter", style: "width: 25%"
            expect(page).to have_button(disabled: true, text: "Vote budget")
          end
        end

        it "displays total budget" do
          expect(page).to have_css(".budget-summary__progressbar-marks_right", text: "€100,000,000")
        end
      end

      context "when voting by maximum projects number" do
        let!(:component) do
          create(:budgets_component,
                 :with_budget_projects_range,
                 vote_minimum_budget_projects_number: 0,
                 manifest:,
                 participatory_space: participatory_process)
        end

        it "adds a project to the current order" do
          within "#project-#{project.id}-item" do
            page.find(".budget-list__action").click
          end

          expect(page).to have_css ".budget-list__data--added", count: 1

          within ".budget-summary__progressbar-marks", match: :first do
            expect(page).to have_content "1 / 6"
          end
          within ".budget__list--header" do
            expect(page).to have_content(/Added\s1/)
          end

          within "#order-progress .budget-summary__content", match: :first do
            expect(page).to have_css ".budget-summary__progressbar--meter", style: "width: 16%"
            expect(page).to have_button(text: "Vote budget")
          end
        end

        it "displays total budget" do
          expect(page).to have_css(".budget-summary__progressbar-marks_right", text: "6")
        end
      end

      context "when voting by minimum and maximum projects number" do
        let!(:component) do
          create(:budgets_component,
                 :with_budget_projects_range,
                 manifest:,
                 participatory_space: participatory_process)
        end

        it "adds a project to the current order" do
          within "#project-#{project.id}-item" do
            page.find(".budget-list__action").click
          end

          expect(page).to have_css ".budget-list__data--added", count: 1
          within ".budget-summary__progressbar-marks", match: :first do
            expect(page).to have_content "1 / 6"
          end
          within ".budget__list--header" do
            expect(page).to have_content(/Added\s1/)
          end

          within "#order-progress .budget-summary__content", match: :first do
            expect(page).to have_css ".budget-summary__progressbar--meter", style: "width: 16%"
            expect(page).to have_button(disabled: true, text: "Vote budget")
          end
        end

        it "displays total budget" do
          expect(page).to have_css(".budget-summary__progressbar-marks_right", text: "6")
        end
      end
    end

    context "and is not authorized" do
      context "when there is only an authorization required" do
        before do
          permissions = {
            vote: {
              authorization_handlers: {
                "dummy_authorization_handler" => {}
              }
            }
          }

          component.update!(permissions:)
        end

        it "redirects to the authorization form" do
          visit_budget

          within "#project-#{project.id}-item" do
            page.find(".budget-list__action").click
          end

          expect(page).to have_content("We need to verify your identity")
          expect(page).to have_content("Verify with Example authorization")
        end
      end

      context "when there are more than one authorization required" do
        before do
          permissions = {
            vote: {
              authorization_handlers: {
                "dummy_authorization_handler" => {},
                "another_dummy_authorization_handler" => { "options" => {} }
              }
            }
          }

          component.update!(permissions:)
        end

        it "redirects to pending onboarding authorizations page" do
          visit_budget

          within "#project-#{project.id}-item" do
            page.find(".budget-list__action").click
          end

          expect(page).to have_content("You are almost ready to vote")
          expect(page).to have_css("a[data-verification]", count: 2)
        end
      end
    end

    context "and has pending order" do
      let!(:order) { create(:order, user:, budget:) }
      let!(:line_item) { create(:line_item, order:, project:) }

      it "removes a project from the current order" do
        visit_budget

        within ".budget-summary__progressbar-marks", match: :first do
          expect(page).to have_content(/€25,000,000\sAssigned/)
        end
        within ".budget__list--header" do
          expect(page).to have_content(/Added\s1/)
        end

        within "#project-#{project.id}-item" do
          page.find(".budget-list__action").click
        end

        within ".budget-summary__progressbar-marks", match: :first do
          expect(page).to have_content(/€0\sAssigned/)
        end
        within ".budget__list--header" do
          expect(page).to have_content(/Added\s0/)
        end
        expect(page).to have_css ".budget-summary__progressbar--meter", style: "width: 0%"
        expect(page).to have_no_css ".budget-list__data--added"
      end

      it "is alerted when trying to leave the component before completing" do
        budget_projects_path = Decidim::EngineRouter.main_proxy(component).budget_projects_path(budget)

        visit_budget

        expect(page).to have_content "€25,000,000"

        page.find("header a", text: translated(organization.name)).click

        expect(page).to have_content "You have not yet voted"

        click_on "Return to voting"

        expect(page).to have_no_content("You have not yet voted")
        expect(page).to have_current_path budget_projects_path
      end

      it "is alerted but can sign out before completing" do
        visit_budget

        within_user_menu do
          click_on("Log out")
        end

        expect(page).to have_content "You have not yet voted"

        page.find_by_id("exit-notification-link").click
        expect(page).to have_content("Logged out successfully")
      end

      context "and try to vote a project that exceed the total budget" do
        let!(:expensive_project) { create(:project, budget:, budget_amount: 250_000_000) }

        it "cannot add the project" do
          visit_budget

          within "#project-#{expensive_project.id}-item" do
            page.find(".budget-list__action").click
          end

          expect(page).to have_css("#budget-excess", visible: :visible)
        end
      end

      context "and in project show page cannot exceed the budget" do
        let!(:expensive_project) { create(:project, budget:, budget_amount: 250_000_000) }

        it "cannot add the project" do
          page.visit Decidim::EngineRouter.main_proxy(component).budget_project_path(budget, expensive_project)

          within "#project-#{expensive_project.id}-budget-button" do
            click_on
          end

          expect(page).to have_css("#budget-excess", visible: :visible)
        end
      end

      context "and add another project exceeding vote threshold" do
        let!(:other_project) { create(:project, budget:, budget_amount: 50_000_000) }

        it "can complete the checkout process" do
          visit_budget

          within "#project-#{other_project.id}-item" do
            page.find(".budget-list__action").click
          end

          expect(page).to have_css ".budget-list__data--added", count: 2

          within "#order-progress .budget-summary__content", match: :first do
            page.find(".button", match: :first).click
          end

          expect(page).to have_css("#budget-confirm", visible: :visible)

          within "#budget-confirm" do
            page.find(".button", text: "Confirm").click
          end

          expect(page).to have_content("successfully")

          page.find(".button", text: "View votes").click

          within "#order-progress .budget-summary__content", match: :first do
            expect(page).to have_css(".button", text: "delete your vote")
          end
        end
      end

      context "when the voting rule is set to threshold percent" do
        before do
          visit_budget
        end

        it "shows the rule description" do
          within ".budget-summary", match: :first do
            expect(page).to have_content("Assign at least €70,000,000 to the projects you want and vote")
          end
        end

        context "when the order total budget does not exceed the threshold" do
          it "cannot vote" do
            within "#order-progress", match: :first do
              expect(page).to have_button("Vote", disabled: true)
            end
          end
        end

        context "when the order total budget exceeds the threshold" do
          let(:projects) { create_list(:project, 2, budget:, budget_amount: 36_000_000) }
          let(:order_percent) { create(:order, user:, budget:) }

          before do
            order.destroy!
            order_percent.projects << projects
            order_percent.save!
            visit_budget
          end

          it "can vote" do
            within "#order-progress", match: :first do
              expect(page).to have_button("Vote", disabled: false)
            end
          end

          context "when user has voted" do
            let(:router) { Decidim::EngineRouter.main_proxy(component) }
            let(:another_user) { create(:user, :confirmed, organization:) }

            before do
              find("[data-dialog-open='budget-confirm']", match: :first).click
              click_on "Confirm"
              expect(page).to have_css("h1", text: "Your vote has been successfully accepted")
            end

            it "shows private-only activity log entry" do
              page.visit decidim.profile_activity_path(nickname: user.nickname)
              expect(page).to have_content("New budgeting vote at #{translated(budget.title)}")
              expect(page).to have_link(translated(budget.title), href: router.budget_path(budget))
            end

            it "does not show activity log entry to another user" do
              relogin_as another_user, scope: :user
              page.visit decidim.profile_activity_path(nickname: user.nickname)
              expect(page).to have_content(user.name)
              expect(page).to have_current_path "/profiles/#{user.nickname}/activity"
              expect(page).to have_no_content("New budgeting vote at")
              expect(page).to have_no_link(translated(budget.title))
            end
          end
        end
      end

      context "when the voting rule is set to minimum projects" do
        before do
          order.destroy!
        end

        let(:component) do
          create(:budgets_component,
                 :with_minimum_budget_projects,
                 manifest:,
                 participatory_space: participatory_process)
        end

        let!(:order_min) { create(:order, user:, budget:) }

        it "shows the rule description" do
          visit_budget

          within ".budget-summary", match: :first do
            expect(page).to have_content("Select at least 3 projects you want and vote")
          end
        end

        context "when the order total budget does not reach the minimum" do
          it "cannot vote" do
            visit_budget

            within "#order-progress", match: :first do
              expect(page).to have_button("Vote", disabled: true)
            end
          end
        end

        context "when the order total budget exceeds the minimum" do
          before do
            order_min.projects = projects
            order_min.save!
          end

          it "can vote" do
            visit_budget

            within "#order-progress", match: :first do
              expect(page).to have_button("Vote", disabled: false)
            end
          end
        end
      end
    end

    context "and has a finished order" do
      let!(:order) do
        order = create(:order, user:, budget:)
        order.projects = projects
        order.checked_out_at = Time.current
        order.save!
        order
      end

      it "can cancel the order" do
        visit_budget

        within ".budget-summary__content", match: :first do
          accept_confirm { page.find(".cancel-order", match: :first).click }
        end

        expect(page).to have_content("successfully")

        within "#order-progress .budget-summary__content", match: :first do
          expect(page).to have_button(disabled: true)
        end

        within ".budget-summary__content", match: :first do
          expect(page).to have_no_css(".button", text: "delete your vote")
        end
      end

      it "is not alerted when trying to leave the component" do
        visit_budget

        expect(page).to have_content("Budget vote completed")

        page.find("a[href='#{decidim.root_path}']").click

        expect(page).to have_current_path decidim.root_path
      end
    end

    context "and votes are disabled" do
      let!(:component) do
        create(:budgets_component,
               :with_votes_disabled,
               manifest:,
               participatory_space: participatory_process)
      end

      it "cannot create new orders" do
        visit_budget

        expect(page).to have_no_button(class: "budget-list__action")
      end
    end

    context "and show votes are enabled" do
      let!(:component) do
        create(:budgets_component,
               :with_show_votes_enabled,
               manifest:,
               participatory_space: participatory_process)
      end

      let!(:order) do
        order = create(:order, user:, budget:)
        order.projects = projects
        order.checked_out_at = Time.current
        order.save!
        order
      end

      it "displays the number of votes for a project" do
        visit_budget

        within "#project-#{project.id}-item .card__list" do
          expect(page).to have_css(".project-votes", text: "1 vote")
        end
      end
    end

    context "and votes are finished" do
      let!(:component) do
        create(:budgets_component,
               :with_voting_finished,
               manifest:,
               participatory_space: participatory_process)
      end
      let!(:projects) { create_list(:project, 2, :selected, budget:, budget_amount: 25_000_000) }

      it "renders selected projects" do
        visit_budget

        expect(page).to have_css(".card__list-metadata .success", count: 2)
      end

      it "does not show a filter to select added projects" do
        visit_budget

        within(".budget__list--header") do
          expect(page).to have_no_text("Added")
        end
      end
    end
  end

  describe "index" do
    it "respects the projects_per_page setting when under total projects" do
      component.update!(settings: { projects_per_page: 1 })

      create_list(:project, 2, budget:)

      visit_budget

      expect(page).to have_css("div[id^=project-]", count: 1)
    end

    it "respects the projects_per_page setting when it matches total projects" do
      component.update!(settings: { projects_per_page: 2 })

      create_list(:project, 2, budget:)

      visit_budget

      expect(page).to have_css("div[id^=project-]", count: 2)
    end

    it "respects the projects_per_page setting when over total projects" do
      component.update!(settings: { projects_per_page: 3 })

      create_list(:project, 2, budget:)

      visit_budget

      expect(page).to have_css("div[id^=project-]", count: 2)
    end
  end

  describe "show" do
    let!(:project) { create(:project, budget:, budget_amount: 25_000_000) }

    before do
      visit resource_locator([budget, project]).path
    end

    it_behaves_like "has attachments tabs" do
      let(:attached_to) { project }
    end

    it "shows the component" do
      expect(page).to have_i18n_content(project.title, strip_tags: true)
      expect(page).to have_i18n_content(project.description, strip_tags: true)
    end

    context "with linked proposals" do
      let(:proposal_component) do
        create(:component, manifest_name: :proposals, participatory_space: project.component.participatory_space)
      end
      let(:proposals) { create_list(:proposal, 3, component: proposal_component) }

      before do
        project.link_resources(proposals, "included_proposals")
      end

      it "shows related proposals" do
        visit_budget
        click_on translated(project.title)

        expect(page).to have_content("History")

        proposals.each do |proposal|
          expect(page).to have_content(decidim_sanitize_translated(proposal.title))
          expect(page).to have_no_content(proposal.creator_author.name)
          expect(page).to have_content(proposal.endorsements.size)
        end
      end

      context "with votes enabled" do
        let(:proposal_component) do
          create(:proposal_component, :with_votes_enabled, participatory_space: project.component.participatory_space)
        end

        let(:proposals) { create_list(:proposal, 1, :with_votes, component: proposal_component) }

        it "does not show the amount of votes" do
          visit_budget
          click_on translated(project.title)

          expect(page).to have_no_css(".card__list-metadata", text: "5")
        end
      end
    end
  end

  def visit_budget
    page.visit Decidim::EngineRouter.main_proxy(component).budget_projects_path(budget)
  end
end
