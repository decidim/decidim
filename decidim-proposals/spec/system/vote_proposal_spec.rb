# frozen_string_literal: true

require "spec_helper"

describe "Support Proposal", slow: true, type: :system do
  include_context "with a component"
  let(:manifest_name) { "proposals" }

  let!(:proposals) { create_list(:proposal, 3, component:) }
  let!(:proposal) { Decidim::Proposals::Proposal.find_by(component:) }
  let(:proposal_title) { translated(proposal.title) }
  let(:other_proposals_titles) { Decidim::Proposals::Proposal.where.not(id: proposal.id).map { |p| translated(p.title) } }
  let!(:user) { create(:user, :confirmed, organization:) }

  def expect_page_not_to_include_votes
    expect(page).not_to have_button("Support")
    expect(page).not_to have_css(".progress-bar__container .progress-bar__number span", text: "0\nSupports")
  end

  context "when votes are not enabled" do
    context "when the user is not logged in" do
      it "does not show the vote proposal button and counts" do
        visit_component
        expect_page_not_to_include_votes

        click_link proposal_title
        expect_page_not_to_include_votes
      end
    end

    context "when the user is logged in" do
      before do
        login_as user, scope: :user
      end

      it "does not show the vote proposal button and counts" do
        visit_component
        expect_page_not_to_include_votes

        click_link proposal_title
        expect_page_not_to_include_votes
      end
    end
  end

  context "when votes are blocked" do
    let!(:component) do
      create(:proposal_component,
             :with_votes_blocked,
             manifest:,
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
             manifest:,
             participatory_space: participatory_process)
    end

    context "when the user is not logged in" do
      it "is given the option to sign in" do
        visit_component
        click_link proposal_title

        within ".proposal__aside-vote" do
          click_button "Support"
        end

        expect(page).to have_css("#loginModal", visible: :visible)
      end
    end

    context "when the user is logged in" do
      before do
        login_as user, scope: :user
      end

      context "when the proposal is not voted yet" do
        before do
          visit_component
          click_link proposal_title
        end

        it "is able to vote the proposal" do
          within "#proposal-#{proposal.id}-vote-button" do
            click_button "Support"
            expect(page).to have_button("Already supported")
          end

          within "#proposal-#{proposal.id}-votes-count" do
            expect(page).to have_content("1\nSupport")
          end
        end
      end

      context "when the proposal is already voted" do
        before do
          create(:proposal_vote, proposal:, author: user)
          visit_component
          click_link proposal_title
        end

        it "is not able to vote it again" do
          within "#proposal-#{proposal.id}-vote-button" do
            expect(page).to have_button("Already supported")
            expect(page).not_to have_button("Support")
          end

          within "#proposal-#{proposal.id}-votes-count" do
            expect(page).to have_content("1\nSupport")
          end
        end

        it "is able to undo the vote" do
          within "#proposal-#{proposal.id}-vote-button" do
            click_button "Already supported"
            expect(page).to have_button("Support")
          end

          within "#proposal-#{proposal.id}-votes-count" do
            expect(page).to have_content("0\nSupports")
          end
        end
      end

      context "when the component has a vote limit" do
        let(:vote_limit) { 10 }

        let!(:component) do
          create(:proposal_component,
                 :with_votes_enabled,
                 :with_vote_limit,
                 vote_limit:,
                 manifest:,
                 participatory_space: participatory_process)
        end

        describe "vote counter" do
          context "when votes are blocked" do
            let!(:component) do
              create(:proposal_component,
                     :with_votes_blocked,
                     :with_vote_limit,
                     vote_limit:,
                     manifest:,
                     participatory_space: participatory_process)
            end

            it "does not show the remaining votes counter" do
              visit_component

              expect(page).to have_css("#voting-rules")
              expect(page).not_to have_css("#remaining-votes-count")
            end
          end

          context "when votes are enabled" do
            let!(:component) do
              create(:proposal_component,
                     :with_votes_enabled,
                     :with_vote_limit,
                     vote_limit:,
                     manifest:,
                     participatory_space: participatory_process)
            end

            it "shows the remaining votes counter" do
              visit_component

              expect(page).to have_css("#voting-rules")
              expect(page).to have_css("#remaining-votes-count")
            end
          end
        end

        context "when the proposal is not voted yet" do
          before do
            visit_component
            click_link proposal_title
          end

          it "updates the remaining votes counter" do
            within ".proposal__aside-vote" do
              click_button "Support"
              expect(page).to have_button("Already supported")
            end

            expect(page).to have_content("Remaining 9 supports")
          end
        end

        context "when the proposal is not voted yet but the user is not authorized" do
          before do
            permissions = {
              vote: {
                authorization_handlers: {
                  "dummy_authorization_handler" => { "options" => {} }
                }
              }
            }

            component.update!(permissions:)
            visit_component
            click_link proposal_title
          end

          it "shows a modal dialog" do
            within "#proposal-#{proposal.id}-vote-button" do
              click_button "Support"
            end

            expect(page).to have_content("Authorization required")
          end
        end

        context "when the proposal is already voted" do
          before do
            create(:proposal_vote, proposal:, author: user)
            visit_component
            click_link proposal_title
          end

          it "is not able to vote it again" do
            within "#proposal-#{proposal.id}-vote-button" do
              expect(page).to have_button("Already supported")
              expect(page).not_to have_button("Support")
            end
          end

          it "is able to undo the vote" do
            within ".proposal__aside-vote" do
              click_button "Already supported"
              expect(page).to have_button("Support")
            end

            within "#proposal-#{proposal.id}-votes-count" do
              expect(page).to have_content("0\nSupports")
            end

            expect(page).to have_content("Remaining 10 supports")
          end
        end

        context "when the user has reached the votes limit" do
          let(:vote_limit) { 1 }

          before do
            create(:proposal_vote, proposal:, author: user)
            visit_component
          end

          it "is not able to vote other proposals" do
            click_link proposal_title
            within ".proposal__aside-vote" do
              expect(page).to have_content("1\nSupport")
            end

            other_proposals_titles.each do |title|
              visit_component
              click_link title
              within ".proposal__aside-vote" do
                expect(page).to have_content("No supports remaining")
                expect(page).to have_css(".button[disabled]")
              end
            end
          end

          context "when votes are blocked" do
            let!(:component) do
              create(:proposal_component,
                     :with_votes_blocked,
                     manifest:,
                     participatory_space: participatory_process)
            end

            it "shows the vote count but not the vote button" do
              click_link proposal_title
              within ".proposal__aside-vote" do
                expect(page).to have_content("1\nSupport")
              end

              other_proposals_titles.each do |title|
                visit_component
                click_link title
                within ".proposal__aside-vote" do
                  expect(page).to have_content("Supports disabled")
                  expect(page).to have_css(".button[disabled]")
                end
              end
            end
          end
        end
      end
    end

    context "when the proposal is rejected", :slow do
      let!(:rejected_proposal) { create(:proposal, :rejected, component:) }
      let!(:rejected_proposal_title) { translated(rejected_proposal.title) }

      before do
        component.update!(settings: { proposal_answering_enabled: true })
      end

      it "cannot be voted" do
        visit_component

        within "#panel-dropdown-menu-state" do
          check "All"
          uncheck "All"
          check "Rejected"
        end

        page.find_link rejected_proposal_title

        click_link rejected_proposal_title
        expect(page).not_to have_selector("#proposal-#{rejected_proposal.id}-vote-button")
      end
    end

    context "when proposals have a voting limit" do
      let!(:component) do
        create(:proposal_component,
               :with_votes_enabled,
               :with_threshold_per_proposal,
               manifest:,
               participatory_space: participatory_process)
      end

      before do
        login_as user, scope: :user
      end

      it "does not allow users to vote to a proposal that is reached the limit" do
        create(:proposal_vote, proposal:)
        visit_component
        click_link proposal_title

        within "#proposal-#{proposal.id}-vote-button" do
          expect(page).to have_content("Support limit reached")
        end
      end

      it "allows users to vote on proposals under the limit" do
        visit_component
        click_link proposal_title

        within ".proposal__aside-vote" do
          click_button "Support"
          expect(page).to have_content("Already supported")
        end
      end
    end

    context "when proposals have vote limit but can accumulate more votes" do
      let!(:component) do
        create(:proposal_component,
               :with_votes_enabled,
               :with_threshold_per_proposal,
               :with_can_accumulate_supports_beyond_threshold,
               manifest:,
               participatory_space: participatory_process)
      end

      before do
        login_as user, scope: :user
      end

      it "allows users to vote on proposals over the limit" do
        create(:proposal_vote, proposal:)
        visit_component
        click_link proposal_title

        within ".proposal__aside-vote" do
          expect(page).to have_content("1\nSupport")
        end
      end
    end

    context "when proposals have a minimum amount of votes" do
      let!(:component) do
        create(:proposal_component,
               :with_votes_enabled,
               :with_minimum_votes_per_user,
               minimum_votes_per_user: 3,
               manifest:,
               participatory_space: participatory_process)
      end

      before do
        login_as user, scope: :user
      end

      it "does not count votes unless the minimum is achieved" do
        visit_component

        proposal_titles = proposals.map do |proposal|
          translated(proposal.title)
        end

        click_link proposal_titles[0]

        within ".proposal__aside-vote" do
          click_button "Support"
          expect(page).to have_content("Already supported")
          expect(page).to have_content("0\nSupports")
        end

        visit_component
        click_link proposal_titles[1]
        within ".proposal__aside-vote" do
          click_button "Support"
          expect(page).to have_content("Already supported")
          expect(page).to have_content("0\nSupports")
        end

        visit_component
        click_link proposal_titles[2]
        within ".proposal__aside-vote" do
          click_button "Support"
          expect(page).to have_content("Already supported")
          expect(page).to have_content("1\nSupport")
        end

        visit_component
        click_link proposal_titles[0]
        within ".proposal__aside-vote" do
          expect(page).to have_content("1\nSupport")
        end

        visit_component
        click_link proposal_titles[1]
        within ".proposal__aside-vote" do
          expect(page).to have_content("1\nSupport")
        end
      end
    end

    describe "gamification" do
      before do
        login_as user, scope: :user
      end

      it "gives a point after voting" do
        visit_component
        click_link proposal_title

        expect do
          within ".proposal__aside-vote" do
            click_button "Support"
            expect(page).to have_content("1\nSupport")
          end
        end.to change { Decidim::Gamification.status_for(user, :proposal_votes).score }.by(1)
      end
    end
  end
end
