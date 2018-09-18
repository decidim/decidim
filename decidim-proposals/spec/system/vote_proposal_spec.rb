# frozen_string_literal: true

require "spec_helper"

describe "Vote Proposal", type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }

  let!(:proposals) { create_list(:proposal, 3, component: component) }
  let!(:proposal) { Decidim::Proposals::Proposal.find_by(component: component) }
  let!(:user) { create :user, :confirmed, organization: organization }

  def expect_page_not_to_include_votes
    expect(page).to have_no_button("Vote")
    expect(page).to have_no_css(".card__support__data span", text: "0 VOTES")
  end

  context "when votes are not enabled" do
    context "when the user is not logged in" do
      it "doesn't show the vote proposal button and counts" do
        visit_component
        expect_page_not_to_include_votes

        click_link proposal.title
        expect_page_not_to_include_votes
      end
    end

    context "when the user is logged in" do
      before do
        login_as user, scope: :user
      end

      it "doesn't show the vote proposal button and counts" do
        visit_component
        expect_page_not_to_include_votes

        click_link proposal.title
        expect_page_not_to_include_votes
      end
    end
  end

  context "when votes are blocked" do
    let!(:component) do
      create(:proposal_component,
             :with_votes_blocked,
             manifest: manifest,
             participatory_space: participatory_process)
    end

    it "shows the vote count and the vote button is disabled" do
      visit_component
      expect_page_not_to_include_votes
    end
  end

  context "when votes are enabled" do
    let!(:component) do
      create(:proposal_component,
             :with_votes_enabled,
             manifest: manifest,
             participatory_space: participatory_process)
    end

    context "when the user is not logged in" do
      it "is given the option to sign in" do
        visit_component

        within ".card__support", match: :first do
          click_button "Vote"
        end

        expect(page).to have_css("#loginModal", visible: true)
      end
    end

    context "when the user is logged in" do
      before do
        login_as user, scope: :user
      end

      context "when the proposal is not voted yet" do
        before do
          visit_component
        end

        it "is able to vote the proposal" do
          within "#proposal-#{proposal.id}-vote-button" do
            click_button "Vote"
            expect(page).to have_button("Already voted")
          end

          within "#proposal-#{proposal.id}-votes-count" do
            expect(page).to have_content("1 VOTE")
          end
        end
      end

      context "when the proposal is already voted" do
        before do
          create(:proposal_vote, proposal: proposal, author: user)
          visit_component
        end

        it "is not able to vote it again" do
          within "#proposal-#{proposal.id}-vote-button" do
            expect(page).to have_button("Already voted")
            expect(page).to have_no_button("Vote")
          end

          within "#proposal-#{proposal.id}-votes-count" do
            expect(page).to have_content("1 VOTE")
          end
        end

        it "is able to undo the vote" do
          within "#proposal-#{proposal.id}-vote-button" do
            click_button "Already voted"
            expect(page).to have_button("Vote")
          end

          within "#proposal-#{proposal.id}-votes-count" do
            expect(page).to have_content("0 VOTES")
          end
        end
      end

      context "when the component has a vote limit" do
        let(:vote_limit) { 10 }

        let!(:component) do
          create(:proposal_component,
                 :with_votes_enabled,
                 :with_vote_limit,
                 vote_limit: vote_limit,
                 manifest: manifest,
                 participatory_space: participatory_process)
        end

        describe "vote counter" do
          context "when votes are blocked" do
            let!(:component) do
              create(:proposal_component,
                     :with_votes_blocked,
                     :with_vote_limit,
                     vote_limit: vote_limit,
                     manifest: manifest,
                     participatory_space: participatory_process)
            end

            it "doesn't show the remaining votes counter" do
              visit_component

              expect(page).to have_css(".voting-rules")
              expect(page).to have_no_css(".remaining-votes-counter")
            end
          end

          context "when votes are enabled" do
            let!(:component) do
              create(:proposal_component,
                     :with_votes_enabled,
                     :with_vote_limit,
                     vote_limit: vote_limit,
                     manifest: manifest,
                     participatory_space: participatory_process)
            end

            it "shows the remaining votes counter" do
              visit_component

              expect(page).to have_css(".voting-rules")
              expect(page).to have_css(".remaining-votes-counter")
            end
          end
        end

        context "when the proposal is not voted yet" do
          before do
            visit_component
          end

          it "updates the remaining votes counter" do
            within "#proposal-#{proposal.id}-vote-button" do
              click_button "Vote"
              expect(page).to have_button("Already voted")
            end

            expect(page).to have_content("REMAINING\n9\nVOTES")
          end
        end

        context "when the proposal is not voted yet but the user isn't authorized" do
          before do
            permissions = {
              vote: {
                authorization_handler_name: "dummy_authorization_handler"
              }
            }

            component.update!(permissions: permissions)
            visit_component
          end

          it "shows a modal dialog" do
            within "#proposal-#{proposal.id}-vote-button" do
              click_button "Vote"
            end

            expect(page).to have_content("Authorization required")
          end
        end

        context "when the proposal is already voted" do
          before do
            create(:proposal_vote, proposal: proposal, author: user)
            visit_component
          end

          it "is not able to vote it again" do
            within "#proposal-#{proposal.id}-vote-button" do
              expect(page).to have_button("Already voted")
              expect(page).to have_no_button("Vote")
            end
          end

          it "is able to undo the vote" do
            within "#proposal-#{proposal.id}-vote-button" do
              click_button "Already voted"
              expect(page).to have_button("Vote")
            end

            within "#proposal-#{proposal.id}-votes-count" do
              expect(page).to have_content("0 VOTES")
            end

            expect(page).to have_content("REMAINING\n10\nVOTES")
          end
        end

        context "when the user has reached the votes limit" do
          let(:vote_limit) { 1 }

          before do
            create(:proposal_vote, proposal: proposal, author: user)
            visit_component
          end

          it "is not able to vote other proposals" do
            expect(page).to have_css(".button[disabled]", count: 2)
          end

          context "when votes are blocked" do
            let!(:component) do
              create(:proposal_component,
                     :with_votes_blocked,
                     manifest: manifest,
                     participatory_space: participatory_process)
            end

            it "shows the vote count but not the vote button" do
              within "#proposal_#{proposal.id} .card__support" do
                expect(page).to have_content("1 VOTE")
              end

              expect(page).to have_content("VOTING DISABLED")
            end
          end
        end
      end
    end

    context "when the proposal is rejected" do
      let!(:rejected_proposal) { create(:proposal, :rejected, component: component) }

      before do
        component.update!(settings: { proposal_answering_enabled: true })
      end

      it "cannot be voted" do
        visit_component

        choose "filter_state_rejected"
        page.find_link(rejected_proposal.title, wait: 30)
        expect(page).to have_no_selector("#proposal-#{rejected_proposal.id}-vote-button")

        click_link rejected_proposal.title
        expect(page).to have_no_selector("#proposal-#{rejected_proposal.id}-vote-button")
      end
    end

    context "when proposals have a voting limit" do
      let!(:component) do
        create(:proposal_component,
               :with_votes_enabled,
               :with_threshold_per_proposal,
               manifest: manifest,
               participatory_space: participatory_process)
      end

      before do
        login_as user, scope: :user
      end

      it "doesn't allow users to vote to a proposal that's reached the limit" do
        create(:proposal_vote, proposal: proposal)
        visit_component

        proposal_element = page.find("article", text: proposal.title)

        within proposal_element do
          within ".card__support", match: :first do
            expect(page).to have_content("VOTE LIMIT REACHED")
          end
        end
      end

      it "allows users to vote on proposals under the limit" do
        visit_component

        proposal_element = page.find("article", text: proposal.title)

        within proposal_element do
          within ".card__support", match: :first do
            click_button "Vote"
            expect(page).to have_content("ALREADY VOTED")
          end
        end
      end
    end

    context "when proposals have vote limit but can accumulate more votes" do
      let!(:component) do
        create(:proposal_component,
               :with_votes_enabled,
               :with_threshold_per_proposal,
               :with_can_accumulate_supports_beyond_threshold,
               manifest: manifest,
               participatory_space: participatory_process)
      end

      before do
        login_as user, scope: :user
      end

      it "allows users to vote on proposals over the limit" do
        create(:proposal_vote, proposal: proposal)
        visit_component

        proposal_element = page.find("article", text: proposal.title)

        within proposal_element do
          within ".card__support", match: :first do
            expect(page).to have_content("1 VOTE")
          end
        end
      end
    end

    describe "gamification" do
      before do
        login_as user, scope: :user
      end

      it "gives a point after voting" do
        visit_component

        proposal_element = page.find("article", text: proposal.title)

        expect do
          within proposal_element do
            within ".card__support", match: :first do
              click_button "Vote"
              expect(page).to have_content("1 VOTE")
            end
          end
        end.to change { Decidim::Gamification.status_for(user, :proposal_votes).score }.by(1)
      end
    end
  end
end
