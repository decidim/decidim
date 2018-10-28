# frozen_string_literal: true

require "spec_helper"

describe "Proposals", type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }

  let!(:category) { create :category, participatory_space: participatory_process }
  let!(:scope) { create :scope, organization: organization }
  let!(:user) { create :user, :confirmed, organization: organization }
  let(:scoped_participatory_process) { create(:participatory_process, :with_steps, organization: organization, scope: scope) }

  let(:address) { "Carrer Pare Llaurador 113, baixos, 08224 Terrassa" }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }

  before do
    stub_geocoding(address, [latitude, longitude])
  end

  matcher :have_author do |name|
    match { |node| node.has_selector?(".author-data", text: name) }
    match_when_negated { |node| node.has_no_selector?(".author-data", text: name) }
  end

  matcher :have_creation_date do |date|
    match { |node| node.has_selector?(".author-data__extra", text: date) }
    match_when_negated { |node| node.has_no_selector?(".author-data__extra", text: date) }
  end

  context "when viewing a single proposal" do
    let!(:component) do
      create(:proposal_component,
             manifest: manifest,
             participatory_space: participatory_process)
    end

    let!(:proposals) { create_list(:proposal, 3, component: component) }

    it "allows viewing a single proposal" do
      proposal = proposals.first

      visit_component

      click_link proposal.title

      expect(page).to have_content(proposal.title)
      expect(page).to have_content(proposal.body)
      expect(page).to have_author(proposal.creator_author.name)
      expect(page).to have_content(proposal.reference)
      expect(page).to have_creation_date(I18n.l(proposal.published_at, format: :decidim_short))
    end

    context "when process is not related to any scope" do
      let!(:proposal) { create(:proposal, component: component, scope: scope) }

      it "can be filtered by scope" do
        visit_component
        click_link proposal.title
        expect(page).to have_content(translated(scope.name))
      end
    end

    context "when process is related to a child scope" do
      let!(:proposal) { create(:proposal, component: component, scope: scope) }
      let(:participatory_process) { scoped_participatory_process }

      it "does not show the scope name" do
        visit_component
        click_link proposal.title
        expect(page).to have_no_content(translated(scope.name))
      end
    end

    context "when it is an official proposal" do
      let!(:official_proposal) { create(:proposal, :official, component: component) }

      it "shows the author as official" do
        visit_component
        click_link official_proposal.title
        expect(page).to have_content("Official proposal")
      end
    end

    context "when a proposal has comments" do
      let(:proposal) { create(:proposal, component: component) }
      let(:author) { create(:user, :confirmed, organization: component.organization) }
      let!(:comments) { create_list(:comment, 3, commentable: proposal) }

      it "shows the comments" do
        visit_component
        click_link proposal.title

        comments.each do |comment|
          expect(page).to have_content(comment.body)
        end
      end
    end

    context "when a proposal has been linked in a meeting" do
      let(:proposal) { create(:proposal, component: component) }
      let(:meeting_component) do
        create(:component, manifest_name: :meetings, participatory_space: proposal.component.participatory_space)
      end
      let(:meeting) { create(:meeting, component: meeting_component) }

      before do
        meeting.link_resources([proposal], "proposals_from_meeting")
      end

      it "shows related meetings" do
        visit_component
        click_link proposal.title

        expect(page).to have_i18n_content(meeting.title)
      end
    end

    context "when a proposal has been linked in a result" do
      let(:proposal) { create(:proposal, component: component) }
      let(:accountability_component) do
        create(:component, manifest_name: :accountability, participatory_space: proposal.component.participatory_space)
      end
      let(:result) { create(:result, component: accountability_component) }

      before do
        result.link_resources([proposal], "included_proposals")
      end

      it "shows related resources" do
        visit_component
        click_link proposal.title

        expect(page).to have_i18n_content(result.title)
      end
    end

    context "when a proposal is in evaluation" do
      let!(:proposal) { create(:proposal, :with_answer, :evaluating, component: component) }

      it "shows a badge and an answer" do
        visit_component
        click_link proposal.title

        expect(page).to have_content("Evaluating")

        within ".callout.secondary" do
          expect(page).to have_content("This proposal is being evaluated")
          expect(page).to have_i18n_content(proposal.answer)
        end
      end
    end

    context "when a proposal has been rejected" do
      let!(:proposal) { create(:proposal, :with_answer, :rejected, component: component) }

      it "shows the rejection reason" do
        visit_component
        choose "filter_state_rejected"
        page.find_link(proposal.title, wait: 30)
        click_link proposal.title

        expect(page).to have_content("Rejected")

        within ".callout.warning" do
          expect(page).to have_content("This proposal has been rejected")
          expect(page).to have_i18n_content(proposal.answer)
        end
      end
    end

    context "when a proposal has been accepted" do
      let!(:proposal) { create(:proposal, :with_answer, :accepted, component: component) }

      it "shows the acceptance reason" do
        visit_component
        click_link proposal.title

        expect(page).to have_content("Accepted")

        within ".callout.success" do
          expect(page).to have_content("This proposal has been accepted")
          expect(page).to have_i18n_content(proposal.answer)
        end
      end
    end

    context "when the proposals'a author account has been deleted" do
      let(:proposal) { proposals.first }

      before do
        Decidim::DestroyAccount.call(proposal.creator_author, Decidim::DeleteAccountForm.from_params({}))
      end

      it "the user is displayed as a deleted user" do
        visit_component

        click_link proposal.title

        expect(page).to have_content("Deleted user")
      end
    end
  end

  context "when a proposal has been linked in a project" do
    let(:component) do
      create(:proposal_component,
             manifest: manifest,
             participatory_space: participatory_process)
    end
    let(:proposal) { create(:proposal, component: component) }
    let(:budget_component) do
      create(:component, manifest_name: :budgets, participatory_space: proposal.component.participatory_space)
    end
    let(:project) { create(:project, component: budget_component) }

    before do
      project.link_resources([proposal], "included_proposals")
    end

    it "shows related projects" do
      visit_component
      click_link proposal.title

      expect(page).to have_i18n_content(project.title)
    end
  end

  context "when listing proposals in a participatory process" do
    shared_examples_for "a random proposal ordering" do
      let!(:lucky_proposal) { create(:proposal, component: component) }
      let!(:unlucky_proposal) { create(:proposal, component: component) }

      it "lists the proposals ordered randomly by default" do
        visit_component

        expect(page).to have_selector("a", text: "Random")
        expect(page).to have_selector(".card--proposal", count: 2)
        expect(page).to have_selector(".card--proposal", text: lucky_proposal.title)
        expect(page).to have_selector(".card--proposal", text: unlucky_proposal.title)
        expect(page).to have_author(lucky_proposal.creator_author.name)
      end
    end

    it "lists all the proposals" do
      create(:proposal_component,
             manifest: manifest,
             participatory_space: participatory_process)

      create_list(:proposal, 3, component: component)

      visit_component
      expect(page).to have_css(".card--proposal", count: 3)
    end

    describe "editable content" do
      before do
        visit_component
      end

      it_behaves_like "editable content for admins"
    end

    describe "default ordering" do
      it_behaves_like "a random proposal ordering"
    end

    context "when voting phase is over" do
      let!(:component) do
        create(:proposal_component,
               :with_votes_blocked,
               manifest: manifest,
               participatory_space: participatory_process)
      end

      let!(:most_voted_proposal) do
        proposal = create(:proposal, component: component)
        create_list(:proposal_vote, 3, proposal: proposal)
        proposal
      end

      let!(:less_voted_proposal) { create(:proposal, component: component) }

      before { visit_component }

      it "lists the proposals ordered by votes by default" do
        expect(page).to have_selector("a", text: "Most voted")
        expect(page).to have_selector("#proposals .card-grid .column:first-child", text: most_voted_proposal.title)
        expect(page).to have_selector("#proposals .card-grid .column:last-child", text: less_voted_proposal.title)
      end

      it "shows a disabled vote button for each proposal, but no links to full proposals" do
        expect(page).to have_button("Voting disabled", disabled: true, count: 2)
        expect(page).to have_no_link("View proposal")
      end
    end

    context "when voting is disabled" do
      let!(:component) do
        create(:proposal_component,
               :with_votes_disabled,
               manifest: manifest,
               participatory_space: participatory_process)
      end

      describe "order" do
        it_behaves_like "a random proposal ordering"
      end

      it "shows only links to full proposals" do
        create_list(:proposal, 2, component: component)

        visit_component

        expect(page).to have_no_button("Voting disabled", disabled: true)
        expect(page).to have_no_button("Vote")
        expect(page).to have_link("View proposal", count: 2)
      end
    end

    context "when there are a lot of proposals" do
      before do
        create_list(:proposal, Decidim::Paginable::OPTIONS.first + 5, component: component)
      end

      it "paginates them" do
        visit_component

        expect(page).to have_css(".card--proposal", count: Decidim::Paginable::OPTIONS.first)

        click_link "Next"

        expect(page).to have_selector(".pagination .current", text: "2")

        expect(page).to have_css(".card--proposal", count: 5)
      end
    end

    context "when filtering" do
      context "when official_proposals setting is enabled" do
        before do
          component.update!(settings: { official_proposals_enabled: true })
        end

        it "can be filtered by origin" do
          visit_component

          within "form.new_filter" do
            expect(page).to have_content(/Origin/i)
          end
        end

        context "with 'official' origin" do
          it "lists the filtered proposals" do
            create_list(:proposal, 2, :official, component: component, scope: scope)
            create(:proposal, component: component, scope: scope)
            visit_component

            within ".filters" do
              choose "Official"
            end

            expect(page).to have_css(".card--proposal", count: 2)
            expect(page).to have_content("2 PROPOSALS")
          end
        end

        context "with 'citizens' origin" do
          it "lists the filtered proposals" do
            create_list(:proposal, 2, component: component, scope: scope)
            create(:proposal, :official, component: component, scope: scope)
            visit_component

            within ".filters" do
              choose "Citizens"
            end

            expect(page).to have_css(".card--proposal", count: 2)
            expect(page).to have_content("2 PROPOSALS")
          end
        end
      end

      context "when official_proposals setting is not enabled" do
        before do
          component.update!(settings: { official_proposals_enabled: false })
        end

        it "cannot be filtered by origin" do
          visit_component

          within "form.new_filter" do
            expect(page).to have_no_content(/Origin/i)
          end
        end
      end

      context "with scope" do
        let(:scopes_picker) { select_data_picker(:filter_scope_id, multiple: true, global_value: "global") }
        let!(:scope2) { create :scope, organization: participatory_process.organization }

        before do
          create_list(:proposal, 2, component: component, scope: scope)
          create(:proposal, component: component, scope: scope2)
          create(:proposal, component: component, scope: nil)
          visit_component
        end

        it "can be filtered by scope" do
          within "form.new_filter" do
            expect(page).to have_content(/Scopes/i)
          end
        end

        context "when selecting the global scope" do
          it "lists the filtered proposals", :slow do
            within ".filters" do
              scope_pick scopes_picker, nil
            end

            expect(page).to have_css(".card--proposal", count: 1)
            expect(page).to have_content("1 PROPOSAL")
          end
        end

        context "when selecting one scope" do
          it "lists the filtered proposals", :slow do
            within ".filters" do
              scope_pick scopes_picker, scope
            end

            expect(page).to have_css(".card--proposal", count: 2)
            expect(page).to have_content("2 PROPOSALS")
          end
        end

        context "when selecting the global scope and another scope" do
          it "lists the filtered proposals", :slow do
            within ".filters" do
              scope_pick scopes_picker, scope
              scope_pick scopes_picker, nil
            end

            expect(page).to have_css(".card--proposal", count: 3)
            expect(page).to have_content("3 PROPOSALS")
          end
        end

        context "when modifying the selected scope" do
          it "lists the filtered proposals" do
            within ".filters" do
              scope_pick scopes_picker, scope
              scope_pick scopes_picker, nil
              scope_repick scopes_picker, scope, scope2
            end

            expect(page).to have_css(".card--proposal", count: 2)
            expect(page).to have_content("2 PROPOSALS")
          end
        end

        context "when unselecting the selected scope" do
          it "lists the filtered proposals" do
            within ".filters" do
              scope_pick scopes_picker, scope
              scope_pick scopes_picker, nil
              scope_unpick scopes_picker, scope
            end

            expect(page).to have_css(".card--proposal", count: 1)
            expect(page).to have_content("1 PROPOSAL")
          end
        end
      end

      context "when process is related to a scope" do
        let(:participatory_process) { scoped_participatory_process }

        it "cannot be filtered by scope" do
          visit_component

          within "form.new_filter" do
            expect(page).to have_no_content(/Scopes/i)
          end
        end
      end

      context "when proposal_answering component setting is enabled" do
        before do
          component.update!(settings: { proposal_answering_enabled: true })
        end

        context "when proposal_answering step setting is enabled" do
          before do
            component.update!(
              step_settings: {
                component.participatory_space.active_step.id => {
                  proposal_answering_enabled: true
                }
              }
            )
          end

          it "can be filtered by state" do
            visit_component

            within "form.new_filter" do
              expect(page).to have_content(/State/i)
            end
          end

          it "lists accepted proposals" do
            create(:proposal, :accepted, component: component, scope: scope)
            visit_component

            within ".filters" do
              choose "Accepted"
            end

            expect(page).to have_css(".card--proposal", count: 1)
            expect(page).to have_content("1 PROPOSAL")

            within ".card--proposal" do
              expect(page).to have_content("ACCEPTED")
            end
          end

          it "lists the filtered proposals" do
            create(:proposal, :rejected, component: component, scope: scope)
            visit_component

            within ".filters" do
              choose "Rejected"
            end

            expect(page).to have_css(".card--proposal", count: 1)
            expect(page).to have_content("1 PROPOSAL")

            within ".card--proposal" do
              expect(page).to have_content("REJECTED")
            end
          end
        end

        context "when proposal_answering step setting is disabled" do
          before do
            component.update!(
              step_settings: {
                component.participatory_space.active_step.id => {
                  proposal_answering_enabled: false
                }
              }
            )
          end

          it "cannot be filtered by state" do
            visit_component

            within "form.new_filter" do
              expect(page).to have_no_content(/State/i)
            end
          end
        end
      end

      context "when proposal_answering component setting is not enabled" do
        before do
          component.update!(settings: { proposal_answering_enabled: false })
        end

        it "cannot be filtered by state" do
          visit_component

          within "form.new_filter" do
            expect(page).to have_no_content(/State/i)
          end
        end
      end

      context "when the user is logged in" do
        before do
          login_as user, scope: :user
        end

        it "can be filtered by category" do
          create_list(:proposal, 3, component: component)
          create(:proposal, component: component, category: category)

          visit_component

          within "form.new_filter" do
            select category.name[I18n.locale.to_s], from: :filter_category_id
          end

          expect(page).to have_css(".card--proposal", count: 1)
        end
      end
    end

    context "when ordering by 'most_voted'" do
      let!(:component) do
        create(:proposal_component,
               :with_votes_enabled,
               manifest: manifest,
               participatory_space: participatory_process)
      end

      it "lists the proposals ordered by votes" do
        most_voted_proposal = create(:proposal, component: component)
        create_list(:proposal_vote, 3, proposal: most_voted_proposal)
        less_voted_proposal = create(:proposal, component: component)

        visit_component

        within ".order-by" do
          expect(page).to have_selector("ul[data-dropdown-menu$=dropdown-menu]", text: "Random")
          page.find("a", text: "Random").click
          click_link "Most voted"
        end

        expect(page).to have_selector("#proposals .card-grid .column:first-child", text: most_voted_proposal.title)
        expect(page).to have_selector("#proposals .card-grid .column:last-child", text: less_voted_proposal.title)
      end
    end

    context "when ordering by 'recent'" do
      it "lists the proposals ordered by created at" do
        older_proposal = create(:proposal, component: component, created_at: 1.month.ago)
        recent_proposal = create(:proposal, component: component)

        visit_component

        within ".order-by" do
          expect(page).to have_selector("ul[data-dropdown-menu$=dropdown-menu]", text: "Random")
          page.find("a", text: "Random").click
          click_link "Recent"
        end

        expect(page).to have_selector("#proposals .card-grid .column:first-child", text: recent_proposal.title)
        expect(page).to have_selector("#proposals .card-grid .column:last-child", text: older_proposal.title)
      end
    end

    context "when paginating" do
      let!(:collection) { create_list :proposal, collection_size, component: component }
      let!(:resource_selector) { ".card--proposal" }

      it_behaves_like "a paginated resource"
    end
  end
end
