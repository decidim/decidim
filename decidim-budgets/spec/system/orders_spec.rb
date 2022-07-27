# frozen_string_literal: true

require "spec_helper"

describe "Orders", type: :system do
  include_context "with a component"
  let(:manifest_name) { "budgets" }

  let(:organization) { create :organization, available_authorizations: %w(dummy_authorization_handler) }
  let!(:user) { create :user, :confirmed, organization: }
  let(:project) { projects.first }

  let!(:component) do
    create(:budgets_component,
           :with_vote_threshold_percent,
           manifest:,
           participatory_space: participatory_process)
  end
  let(:budget) { create :budget, component: }

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

      context "when voting by percentage threshold" do
        it "displays description messages" do
          within ".budget-summary" do
            expect(page).to have_content("You decide the budget\nWhat projects do you think we should allocate budget for? Assign at least €70,000,000 to the projects you want and vote according to your preferences to define the budget.")
          end
        end

        it "displays rules" do
          within ".voting-rules" do
            expect(page).to have_content("Assign at least €70,000,000 to the projects you want and vote according to your preferences to define the budget.")
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
          within ".budget-summary" do
            expect(page).to have_content("What projects do you think we should allocate budget for? Select at least 3 projects you want and vote according to your preferences to define the budget.")
          end
        end

        it "displays rules" do
          within ".voting-rules" do
            expect(page).to have_content("Select at least 3 projects you want and vote according to your preferences to define the budget.")
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
          within ".budget-summary" do
            expect(page).to have_content("What projects do you think we should allocate budget for? Select up to 6 projects you want and vote according to your preferences to define the budget.")
          end
        end

        it "displays rules" do
          within ".voting-rules" do
            expect(page).to have_content("Select up to 6 projects you want and vote according to your preferences to define the budget.")
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
          within ".budget-summary" do
            expect(page).to have_content("What projects do you think we should allocate budget for? Select at least 3 and up to 6 projects you want and vote according to your preferences to define the budget.")
          end
        end

        it "displays rules" do
          within ".voting-rules" do
            expect(page).to have_content("Select at least 3 and up to 6 projects you want and vote according to your preferences to define the budget.")
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

          expect(page).to have_selector ".budget-list__data--added", count: 1

          expect(page).to have_content "ASSIGNED: €25,000,000"
          expect(page).to have_content "1 project selected"

          within ".budget-summary__selected" do
            expect(page).to have_selector(".budget-summary__selected-item", text: project.title[I18n.locale.to_s], visible: :hidden)
          end

          within "#order-progress .budget-summary__progressbox" do
            expect(page).to have_content "25%"
            expect(page).to have_selector("button.small:disabled")
          end
        end

        it "displays total budget" do
          within ".budget-summary__total" do
            expect(page).to have_content("TOTAL BUDGET €100,000,000")
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

        it "adds a project to the current order" do
          within "#project-#{project.id}-item" do
            page.find(".budget-list__action").click
          end

          expect(page).to have_selector ".budget-list__data--added", count: 1

          expect(page).to have_content "ASSIGNED: €25,000,000"
          expect(page).to have_content "1 project selected"

          within ".budget-summary__selected" do
            expect(page).to have_selector(".budget-summary__selected-item", text: project.title[I18n.locale.to_s], visible: :hidden)
          end

          within "#order-progress .budget-summary__progressbox" do
            expect(page).to have_content "25%"
            expect(page).to have_selector("button.small:disabled")
          end
        end

        it "displays total budget" do
          within ".budget-summary__total" do
            expect(page).to have_content("TOTAL BUDGET €100,000,000")
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

        it "adds a project to the current order" do
          within "#project-#{project.id}-item" do
            page.find(".budget-list__action").click
          end

          expect(page).to have_selector ".budget-list__data--added", count: 1

          expect(page).to have_content "ASSIGNED: 1 / 6"
          expect(page).to have_content "1 project selected"

          within ".budget-summary__selected" do
            expect(page).to have_selector(".budget-summary__selected-item", text: project.title[I18n.locale.to_s], visible: :hidden)
          end

          within "#order-progress .budget-summary__progressbox" do
            expect(page).to have_content "16%"
            expect(page).to have_selector("button.small")
          end
        end

        it "displays total budget" do
          within ".budget-summary__total" do
            expect(page).to have_content("TOTAL VOTES 6")
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

        it "adds a project to the current order" do
          within "#project-#{project.id}-item" do
            page.find(".budget-list__action").click
          end

          expect(page).to have_selector ".budget-list__data--added", count: 1

          expect(page).to have_content "ASSIGNED: 1 / 6"
          expect(page).to have_content "1 project selected"

          within ".budget-summary__selected" do
            expect(page).to have_selector(".budget-summary__selected-item", text: project.title[I18n.locale.to_s], visible: :hidden)
          end

          within "#order-progress .budget-summary__progressbox" do
            expect(page).to have_content "16%"
            expect(page).to have_selector("button.small")
          end
        end

        it "displays total budget" do
          within ".budget-summary__total" do
            expect(page).to have_content("TOTAL VOTES 6")
          end
        end
      end
    end

    context "and isn't authorized" do
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

      it "shows a modal dialog" do
        visit_budget

        within "#project-#{project.id}-item" do
          page.find(".budget-list__action").click
        end

        expect(page).to have_content("Authorization required")
      end
    end

    context "and has pending order" do
      let!(:order) { create(:order, user:, budget:) }
      let!(:line_item) { create(:line_item, order:, project:) }

      it "removes a project from the current order" do
        visit_budget

        expect(page).to have_content "ASSIGNED: €25,000,000"

        within "#project-#{project.id}-item" do
          page.find(".budget-list__action").click
        end

        expect(page).to have_content "ASSIGNED: €0"
        expect(page).to have_no_content "1 project selected"
        expect(page).to have_no_selector ".budget-summary__selected"

        within "#order-progress .budget-summary__progressbox" do
          expect(page).to have_content "0%"
        end

        expect(page).to have_no_selector ".budget-list__data--added"
      end

      it "is alerted when trying to leave the component before completing" do
        budget_projects_path = Decidim::EngineRouter.main_proxy(component).budget_projects_path(budget)

        visit_budget

        expect(page).to have_content "ASSIGNED: €25,000,000"

        page.find(".logo-wrapper a").click

        expect(page).to have_content "You have not yet voted"

        click_button "Return to voting"

        expect(page).not_to have_content("You have not yet voted")
        expect(page).to have_current_path budget_projects_path
      end

      it "is alerted but can sign out before completing" do
        visit_budget

        page.find("#user-menu-control").click
        page.find(".sign-out-link").click

        expect(page).to have_content "You have not yet voted"

        page.find("#exit-notification-link").click
        expect(page).to have_content("Signed out successfully")
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

      context "and in project show page cant exceed the budget" do
        let!(:expensive_project) { create(:project, budget:, budget_amount: 250_000_000) }

        it "cannot add the project" do
          page.visit Decidim::EngineRouter.main_proxy(component).budget_project_path(budget, expensive_project)

          within "#project-#{expensive_project.id}-budget-button" do
            page.find("button").click
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

          expect(page).to have_selector ".budget-list__data--added", count: 2

          within "#order-progress .budget-summary__progressbox:not(.budget-summary__progressbox--fixed)" do
            page.find(".button.small").click
          end

          expect(page).to have_css("#budget-confirm", visible: :visible)

          within "#budget-confirm" do
            page.find(".button.expanded").click
          end

          expect(page).to have_content("successfully")

          within "#order-progress .budget-summary__progressbox" do
            expect(page).to have_no_selector("button.small")
          end
        end
      end

      context "when the voting rule is set to threshold percent" do
        before do
          visit_budget
        end

        it "shows the rule description" do
          within ".card.budget-summary" do
            expect(page).to have_content("Assign at least €70,000,000 to the projects you want and vote")
          end
        end

        context "when the order total budget doesn't exceed the threshold" do
          it "cannot vote" do
            within "#order-progress" do
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
            within "#order-progress" do
              expect(page).to have_button("Vote", disabled: false)
            end
          end

          context "when user has voted" do
            let(:router) { Decidim::EngineRouter.main_proxy(component) }
            let(:another_user) { create(:user, :confirmed, organization:) }

            before do
              find("[data-toggle='budget-confirm']").click
              click_button "Confirm"
              expect(page).to have_css(".flash.success")
            end

            it "shows private-only activity log entry" do
              page.visit decidim.profile_activity_path(nickname: user.nickname)
              expect(page).to have_content("New budgeting vote at #{translated(budget.participatory_space.title)}")
              expect(page).to have_link(translated(budget.title), href: router.budget_path(budget))
            end

            it "does not show activity log entry to another user" do
              relogin_as another_user, scope: :user
              page.visit decidim.profile_activity_path(nickname: user.nickname)
              expect(page).to have_content(user.name)
              expect(page).to have_current_path "/profiles/#{user.nickname}/activity"
              expect(page).not_to have_content("New budgeting vote at")
              expect(page).not_to have_link(translated(budget.title))
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

          within ".card.budget-summary" do
            expect(page).to have_content("Select at least 3 projects you want and vote")
          end
        end

        context "when the order total budget doesn't reach the minimum" do
          it "cannot vote" do
            visit_budget

            within "#order-progress" do
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

            within "#order-progress" do
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

        within ".budget-summary" do
          accept_confirm { page.find(".cancel-order").click }
        end

        expect(page).to have_content("successfully")

        within "#order-progress .budget-summary__progressbox" do
          expect(page).to have_selector("button.small:disabled")
        end

        within ".budget-summary" do
          expect(page).to have_no_selector(".cancel-order")
        end
      end

      it "is not alerted when trying to leave the component" do
        visit_budget

        expect(page).to have_content("Budget vote completed")

        page.find(".logo-wrapper a").click

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

        expect(page).to have_no_selector("button.budget-list__action")
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

        within "#project-#{project.id}-item .budget-list__number" do
          expect(page).to have_selector(".project-votes", text: "1 VOTE")
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

        expect(page).to have_selector(".card__text--status.success", count: 2)
      end
    end
  end

  describe "index" do
    it "respects the projects_per_page setting when under total projects" do
      component.update!(settings: { projects_per_page: 1 })

      create_list(:project, 2, budget:)

      visit_budget

      expect(page).to have_selector("div[id^=project-]", count: 1)
    end

    it "respects the projects_per_page setting when it matches total projects" do
      component.update!(settings: { projects_per_page: 2 })

      create_list(:project, 2, budget:)

      visit_budget

      expect(page).to have_selector("div[id^=project-]", count: 2)
    end

    it "respects the projects_per_page setting when over total projects" do
      component.update!(settings: { projects_per_page: 3 })

      create_list(:project, 2, budget:)

      visit_budget

      expect(page).to have_selector("div[id^=project-]", count: 2)
    end
  end

  describe "show" do
    let!(:project) { create(:project, budget:, budget_amount: 25_000_000) }

    before do
      visit resource_locator([budget, project]).path
    end

    it_behaves_like "has attachments" do
      let(:attached_to) { project }
    end

    it "shows the component" do
      expect(page).to have_i18n_content(project.title)
      expect(page).to have_i18n_content(project.description)
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
        click_link translated(project.title)

        proposals.each do |proposal|
          expect(page).to have_content(translated(proposal.title))
          expect(page).to have_content(proposal.creator_author.name)
          expect(page).to have_content(proposal.votes.size)
        end
      end
    end
  end

  def visit_budget
    page.visit Decidim::EngineRouter.main_proxy(component).budget_projects_path(budget)
  end
end
