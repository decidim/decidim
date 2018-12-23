# frozen_string_literal: true

shared_examples "orders" do |options|
  let(:manifest_name) { "budgets" }

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
        page.find(".budget--list__action").click
      end

      expect(page).to have_css("#loginModal", visible: true)
    end
  end

  context "when the user is logged in" do
    if options == :total_budget
      context "when voting by budget" do
        let!(:projects) { create_list(:project, 3, component: component, budget: 25_000_000) }

        before do
          login_as user, scope: :user
        end

        context "and has not a pending order" do
          it "adds a project to the current order" do
            visit_component

            within "#project-#{project.id}-item" do
              page.find(".budget--list__action").click
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
                authorization_handler_name: "dummy_authorization_handler"
              }
            }

            component.update!(permissions: permissions)
          end

          it "shows a modal dialog" do
            visit_component

            within "#project-#{project.id}-item" do
              page.find(".budget--list__action").click
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
              page.find(".budget--list__action").click
            end

            expect(page).to have_content "ASSIGNED: €0"
            expect(page).to have_no_content "1 project selected"
            expect(page).to have_no_selector ".budget-summary__selected"

            within "#order-progress .budget-summary__progressbox" do
              expect(page).to have_content "0%"
            end

            expect(page).to have_no_selector ".budget-list__data--added"
          end

          context "and try to vote a project that exceed the total budget" do
            let!(:expensive_project) { create(:project, component: component, budget: 250_000_000) }

            it "cannot add the project" do
              visit_component

              within "#project-#{expensive_project.id}-item" do
                page.find(".budget--list__action").click
              end

              expect(page).to have_css("#limit-excess", visible: true)
            end
          end

          context "and add another project exceeding vote threshold" do
            let!(:other_project) { create(:project, component: component, budget: 50_000_000) }

            it "can complete the checkout process" do
              visit_component

              within "#project-#{other_project.id}-item" do
                page.find(".budget--list__action").click
              end

              expect(page).to have_selector ".budget-list__data--added", count: 2

              within "#order-progress .budget-summary__progressbox:not(.budget-summary__progressbox--fixed)" do
                page.find(".button.small").click
              end

              expect(page).to have_css("#budget-confirm", visible: true)

              within "#budget-confirm" do
                page.find(".button.expanded").click
              end

              expect(page).to have_content("successfully")

              within "#order-progress .budget-summary__progressbox" do
                expect(page).to have_no_selector("button.small")
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

            expect(page).to have_selector("button.budget--list__action[disabled]", count: 3)
            expect(page).to have_no_selector(".budget-summary")
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
              expect(page).to have_content("1 SUPPORT")
            end
          end
        end
      end
    end

    if options == :total_projects
      context "when voting by project" do
        let(:component) do
          create(:budget_component,
                 :with_vote_per_project,
                 total_projects: 5,
                 manifest: manifest,
                 participatory_space: participatory_process)
        end
        let!(:projects) { create_list(:project, 5, component: component, budget: 25_000_000) }

        before do
          login_as user, scope: :user
        end

        context "and has not a pending order" do
          it "adds a project to the current order" do
            visit_component

            within "#project-#{project.id}-item" do
              page.find(".budget--list__action").click
            end

            expect(page).to have_selector ".budget-list__data--added", count: 1

            expect(page).to have_content "1 project selected out of a total of 5 projets"

            within ".budget-summary__selected" do
              expect(page).to have_content project.title[I18n.locale]
            end

            within ".budget-summary__selected" do
              expect(page).to have_selector("button.small:disabled")
            end
          end

          context "when projects number exceed limit", :slow do
            let!(:other_project) { create(:project, component: component, budget: 50_000_000) }

            it "can't complete the checkout process" do
              visit_component

              projects.each do |project|
                within "#project-#{project.id}-item" do
                  page.find(".budget--list__action").click
                end
              end

              within "#project-#{other_project.id}-item" do
                page.find(".budget--list__action").click
              end

              within "#limit-excess" do
                expect(page).to have_content("Maximum number of projects reached")
              end
            end
          end
        end

        context "and isn't authorized" do
          before do
            permissions = {
              vote: {
                authorization_handler_name: "dummy_authorization_handler"
              }
            }

            component.update!(permissions: permissions)
          end

          it "shows a modal dialog" do
            visit_component

            within "#project-#{project.id}-item" do
              page.find(".budget--list__action").click
            end

            expect(page).to have_content("Authorization required")
          end
        end

        context "and has pending order" do
          let!(:order) { create(:order, user: user, component: component) }
          let!(:line_item) { create(:line_item, order: order, project: project) }

          it "removes a project from the current order" do
            visit_component

            expect(page).to have_content "1 project selected out of a total of 5 projets"

            within "#project-#{project.id}-item" do
              page.find(".budget--list__action").click
            end

            expect(page).to have_content "Choose 5 projects and validate your vote"
            expect(page).to have_no_content "1 project selected"
            expect(page).to have_no_selector ".budget-summary__selected"

            expect(page).to have_no_selector ".budget-list__data--added"
          end

          context "when projects exceed limit" do
            let!(:other_project) { create(:project, component: component, budget: 50_000_000) }
            let!(:line_item_two) { create(:line_item, order: order, project: projects[1]) }
            let!(:line_item_three) { create(:line_item, order: order, project: projects[2]) }
            let!(:line_item_four) { create(:line_item, order: order, project: projects[3]) }
            let!(:line_item_five) { create(:line_item, order: order, project: projects[4]) }

            it "can't click on another project", :slow do
              visit_component

              expect(page).to have_selector ".budget-list__data--added", count: 5
              expect(page).to have_selector("button.budget--list__action[disabled]", count: 1)

              within ".budget-summary__selected" do
                page.find("button.button.small.button--sc").click
              end

              find_button("Confirm").click

              expect(page).to have_content("successfully")
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

            within ".budget-summary" do
              expect(page).to have_content("Choose 5 projects and validate your vote.")
              expect(page).to have_no_selector(".cancel-order")
            end
          end
        end

        context "and votes are disabled" do
          let!(:component) do
            create(:budget_component,
                   :with_votes_disabled,
                   :with_vote_per_project,
                   manifest: manifest,
                   participatory_space: participatory_process)
          end

          it "cannot create new orders" do
            visit_component

            expect(page).to have_selector("button.budget--list__action[disabled]", count: 5)
            expect(page).to have_no_selector(".budget-summary")
          end
        end

        context "and show votes are enabled" do
          let!(:component) do
            create(:budget_component,
                   :with_show_votes_enabled,
                   :with_vote_per_project,
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
              expect(page).to have_content("1 SUPPORT")
            end
          end
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
          expect(page).to have_content(proposal.title)
          expect(page).to have_content(proposal.author.name)
          expect(page).to have_content(proposal.votes.size)
        end
      end
    end
  end
end
