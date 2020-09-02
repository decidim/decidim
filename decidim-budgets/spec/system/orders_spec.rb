# frozen_string_literal: true

require "spec_helper"

describe "Orders", type: :system do
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

  context "when the user is not logged in" do
    let!(:projects) { create_list(:project, 1, component: component, budget: 25_000_000) }

    it "is given the option to sign in" do
      visit_component

      within "#project-#{project.id}-item" do
        page.find(".budget-list__action").click
      end

      expect(page).to have_css("#loginModal", visible: :visible)
    end
  end

  context "when the user is logged in" do
    let!(:projects) { create_list(:project, 3, component: component, budget: 25_000_000) }

    before do
      login_as user, scope: :user
    end

    context "and has not a pending order" do
      it "adds a project to the current order" do
        visit_component

        within "#project-#{project.id}-item" do
          page.find(".budget-list__action").click
        end

        expect(page).to have_selector ".budget-list__data--added", count: 1

        expect(page).to have_content "ASSIGNED: €25,000,000"
        expect(page).to have_content "1 project selected"

        within ".budget-summary__selected" do
          expect(page).to have_content project.title[I18n.locale]
        end

        within "#order-progress .budget-summary__progressbox" do
          expect(page).to have_content "25%"
          expect(page).to have_selector("button.small:disabled")
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

        component.update!(permissions: permissions)
      end

      it "shows a modal dialog" do
        visit_component

        within "#project-#{project.id}-item" do
          page.find(".budget-list__action").click
        end

        expect(page).to have_content("Authorization required")
      end
    end

    context "and has pending order" do
      let!(:order) { create(:order, user: user, component: component) }
      let!(:line_item) { create(:line_item, order: order, project: project) }

      it "removes a project from the current order" do
        visit_component

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
        visit_component

        expect(page).to have_content "ASSIGNED: €25,000,000"

        # Note that this is not a default alert box, this is the default browser
        # prompt for verifying the page unload. Therefore, `dismiss_prompt` is
        # used instead of `dismiss_confirm`.
        dismiss_prompt do
          page.find(".logo-wrapper a").click
        end

        expect(page).to have_current_path main_component_path(component)
      end

      context "and try to vote a project that exceed the total budget" do
        let!(:expensive_project) { create(:project, component: component, budget: 250_000_000) }

        it "cannot add the project" do
          visit_component

          within "#project-#{expensive_project.id}-item" do
            page.find(".budget-list__action").click
          end

          expect(page).to have_css("#budget-excess", visible: :visible)
        end
      end

      context "and add another project exceeding vote threshold" do
        let!(:other_project) { create(:project, component: component, budget: 50_000_000) }

        it "can complete the checkout process" do
          visit_component

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
          visit_component
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
          let(:projects) { create_list(:project, 2, component: component, budget: 36_000_000) }
          let(:order_percent) { create(:order, user: user, component: component) }

          before do
            order.destroy!
            order_percent.projects << projects
            order_percent.save!
          end

          it "can vote" do
            visit_component
            within "#order-progress" do
              expect(page).to have_button("Vote", disabled: false)
            end
          end
        end
      end

      context "when the voting rule is set to minimum projects" do
        before do
          order.destroy!
        end

        let(:component) do
          create(:budget_component,
                 :with_total_budget_and_minimum_budget_projects,
                 manifest: manifest,
                 participatory_space: participatory_process)
        end

        let!(:order_min) { create(:order, user: user, component: component) }

        it "shows the rule description" do
          visit_component

          within ".card.budget-summary" do
            expect(page).to have_content("Select at least 3 projects you want and vote")
          end
        end

        context "when the order total budget doesn't reach the minimum" do
          it "cannot vote" do
            visit_component

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
            visit_component

            within "#order-progress" do
              expect(page).to have_button("Vote", disabled: false)
            end
          end
        end
      end
    end

    context "and has a finished order" do
      let!(:order) do
        order = create(:order, user: user, component: component)
        order.projects = projects
        order.checked_out_at = Time.current
        order.save!
        order
      end

      it "can cancel the order" do
        visit_component

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
        visit_component

        expect(page).to have_content("Budget vote completed")

        page.find(".logo-wrapper a").click

        expect(page).to have_current_path decidim.root_path
      end
    end

    context "and votes are disabled" do
      let!(:component) do
        create(:budget_component,
               :with_votes_disabled,
               manifest: manifest,
               participatory_space: participatory_process)
      end

      it "cannot create new orders" do
        visit_component

        expect(page).to have_selector("button.budget-list__action[disabled]", count: 3)
        expect(page).to have_no_css(".budget-summary")
      end
    end

    context "and show votes are enabled" do
      let!(:component) do
        create(:budget_component,
               :with_show_votes_enabled,
               manifest: manifest,
               participatory_space: participatory_process)
      end

      let!(:order) do
        order = create(:order, user: user, component: component)
        order.projects = projects
        order.checked_out_at = Time.current
        order.save!
        order
      end

      it "displays the number of votes for a project" do
        visit_component

        within "#project-#{project.id}-item" do
          expect(page).to have_content("1 support")
        end
      end
    end
  end

  describe "index" do
    it "respects the projects_per_page setting when under total projects" do
      component.update!(settings: { projects_per_page: 1 })

      create_list(:project, 2, component: component)

      visit_component

      expect(page).to have_selector("[id^=project-]", count: 1)
    end

    it "respects the projects_per_page setting when it matches total projects" do
      component.update!(settings: { projects_per_page: 2 })

      create_list(:project, 2, component: component)

      visit_component

      expect(page).to have_selector("[id^=project-]", count: 2)
    end

    it "respects the projects_per_page setting when over total projects" do
      component.update!(settings: { projects_per_page: 3 })

      create_list(:project, 2, component: component)

      visit_component

      expect(page).to have_selector("[id^=project-]", count: 2)
    end
  end

  describe "show" do
    let!(:project) { create(:project, component: component, budget: 25_000_000) }

    before do
      visit resource_locator(project).path
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
        visit_component
        click_link translated(project.title)

        proposals.each do |proposal|
          expect(page).to have_content(translated(proposal.title))
          expect(page).to have_content(proposal.creator_author.name)
          expect(page).to have_content(proposal.votes.size)
        end
      end
    end
  end
end
