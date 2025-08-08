# frozen_string_literal: true

require "spec_helper"

describe "Vote Proposal", slow: true do
  include_context "with a component"
  let(:manifest_name) { "proposals" }

  let!(:proposals) { create_list(:proposal, 3, component:) }
  let!(:proposal) { Decidim::Proposals::Proposal.find_by(component:) }
  let(:proposal_title) { translated(proposal.title) }
  let(:other_proposals_titles) { Decidim::Proposals::Proposal.where.not(id: proposal.id).map { |p| translated(p.title) } }
  let!(:user) { create(:user, :confirmed, organization:) }

  def expect_page_not_to_include_votes
    expect(page).to have_no_button("Vote")
    expect(page).to have_no_css(".progress-bar__container .progress-bar__number span", text: "0\nVotes")
  end

  context "when votes are not enabled" do
    context "when the user is not logged in" do
      it "does not show the vote proposal button and counts" do
        visit_component
        expect_page_not_to_include_votes

        find(".card__list#proposals__proposal_#{proposal.id}").click
        expect_page_not_to_include_votes
      end

      it "does not show the exit modal" do
        visit_component
        click_on proposal_title

        expect_page_not_to_include_votes
        expect(page).to have_content("Log in or create an account")
        page.find(".main-bar__logo a").click
        expect(page).to have_no_content("Remember you have")
        expect(page).to have_no_content("Cancel")
        expect(page).to have_no_content("Continue")
      end
    end

    context "when the user is logged in" do
      before do
        login_as user, scope: :user
      end

      it "does not show the vote proposal button and counts" do
        visit_component
        expect_page_not_to_include_votes

        find(".card__list#proposals__proposal_#{proposal.id}").click
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

    before do
      visit_component
    end

    context "when on proposal page" do
      it "shows the vote count and the vote button is disabled" do
        expect_page_not_to_include_votes
      end
    end

    context "when on proposals listing page" do
      it "displays the vote button as disabled" do
        within "#proposal-#{proposal.id}-vote-button" do
          expect(page).to have_button("Vote", disabled: true)
        end

        within "#proposal-#{proposal.id}-votes-count" do
          expect(page).to have_content("0\nVotes")
        end
      end
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
        find(".card__list#proposals__proposal_#{proposal.id}").click

        within ".proposal__aside-vote" do
          click_on "Vote"
        end

        expect(page).to have_css("#loginModal", visible: :visible)
      end
    end

    context "when the user is logged in" do
      before do
        login_as user, scope: :user
      end

      context "when voting exclusively from index page" do
        let(:threshold_per_proposal) { 0 }
        let(:minimum_votes_per_user) { 0 }
        let(:vote_limit) { 0 }

        let(:settings) do
          {
            threshold_per_proposal:,
            vote_limit:,
            minimum_votes_per_user:
          }
        end

        let!(:component) do
          create(:proposal_component,
                 :with_votes_enabled,
                 :with_vote_limit,
                 :with_threshold_per_proposal,
                 :with_minimum_votes_per_user,
                 settings:,
                 participatory_space: participatory_process)
        end
        let(:proposals) { create_list(:proposal, 4, component:) }
        let!(:first_proposal) { proposals.first }
        let!(:second_proposal) { proposals.second }
        let!(:unvoted_proposal_ids) { proposals.map(&:id).excluding(first_proposal.id, second_proposal.id) }

        let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }

        before do
          allow(Rails).to receive(:cache).and_return(memory_store)
          Rails.cache.clear
        end

        context "when there is no limit, no threshold nor a minimum" do
          it "it updates the number of votes" do
            visit_component

            within "#proposal-#{first_proposal.id}-vote-button" do
              click_on "Vote"
              expect(page).to have_button("Voted")
            end

            within "#proposal-#{first_proposal.id}-votes-count" do
              expect(page).to have_content("1\nVote")
            end

            visit_component

            within "#proposal-#{first_proposal.id}-vote-button" do
              expect(page).to have_button("Voted")
            end

            within "#proposal-#{first_proposal.id}-votes-count" do
              expect(page).to have_content("1\nVote")
            end
          end
        end

        context "when there is no limit, no minimum but there is a threshold" do
          let(:threshold_per_proposal) { 2 }

          it "it updates the number of votes" do
            visit_component

            within "#proposal-#{first_proposal.id}-vote-button" do
              click_on "Vote"
              expect(page).to have_button("Voted")
            end

            within "#proposal-#{first_proposal.id}-votes-count" do
              expect(page).to have_content("1\n2\nVote")
            end

            within "#proposal-#{second_proposal.id}-vote-button" do
              click_on "Vote"
              expect(page).to have_button("Voted")
            end

            within "#proposal-#{second_proposal.id}-votes-count" do
              expect(page).to have_content("1\n2\nVote")
            end

            visit_component

            within "#proposal-#{first_proposal.id}-vote-button" do
              expect(page).to have_button("Voted")
            end

            within "#proposal-#{first_proposal.id}-votes-count" do
              expect(page).to have_content("1\n2\nVote")
            end
          end
        end

        context "when there is no threshold, no limit but there is a minimum" do
          let(:minimum_votes_per_user) { 2 }

          it "displays single page" do
            visit_component
            click_on translated(first_proposal.title), match: :first

            expect(page).to have_content("You have 2 supports left")

            within "#proposal-#{first_proposal.id}-vote-button" do
              click_on "Vote"
              expect(page).to have_button("Voted")
            end

            within "#proposal-#{first_proposal.id}-votes-count" do
              expect(page).to have_content("0\nVotes")
            end

            expect(page).to have_no_content("Your votes have been successfully accepted")

            expect(page).to have_content("You have 1 supports left")
          end

          it "it updates the number of votes" do
            visit_component

            expect(page).to have_content("You have 2 supports left")

            within "#proposal-#{first_proposal.id}-vote-button" do
              click_on "Vote"
              expect(page).to have_button("Voted")
            end

            expect(page).to have_content("You have 1 supports left")
            expect(page).to have_no_content("Your votes have been successfully accepted")

            within "#proposal-#{second_proposal.id}-vote-button" do
              click_on "Vote"
              expect(page).to have_button("Voted")
            end
            expect(page).to have_content("Your votes have been successfully accepted")

            within "#proposal-#{first_proposal.id}-votes-count" do
              expect(page).to have_content("1\nVote")
            end

            within "#proposal-#{second_proposal.id}-votes-count" do
              expect(page).to have_content("1\nVote")
            end
            visit_component

            within "#proposal-#{first_proposal.id}-vote-button" do
              expect(page).to have_button("Voted")
            end

            within "#proposal-#{second_proposal.id}-vote-button" do
              expect(page).to have_button("Voted")
            end

            within "#proposal-#{first_proposal.id}-votes-count" do
              expect(page).to have_content("1\nVote")
            end

            within "#proposal-#{second_proposal.id}-votes-count" do
              expect(page).to have_content("1\nVote")
            end
          end
        end

        context "when there is no limit but there is a minimum and a threshold" do
          let(:minimum_votes_per_user) { 2 }
          let(:threshold_per_proposal) { 2 }

          it "displays single page" do
            visit_component
            click_on translated(first_proposal.title), match: :first

            expect(page).to have_content("You have 2 supports left")

            within "#proposal-#{first_proposal.id}-vote-button" do
              click_on "Vote"
              expect(page).to have_button("Voted")
            end

            within "#proposal-#{first_proposal.id}-votes-count" do
              expect(page).to have_content("0 2\nVotes")
            end

            expect(page).to have_no_content("Your votes have been successfully accepted")

            expect(page).to have_content("You have 1 supports left")
          end

          it "it updates the number of votes" do
            visit_component

            expect(page).to have_content("You have 2 supports left")

            within "#proposal-#{first_proposal.id}-vote-button" do
              click_on "Vote"
              expect(page).to have_button("Voted")
            end

            expect(page).to have_content("You have 1 supports left")
            expect(page).to have_no_content("Your votes have been successfully accepted")

            within "#proposal-#{second_proposal.id}-vote-button" do
              click_on "Vote"
              expect(page).to have_button("Voted")
            end
            expect(page).to have_content("Your votes have been successfully accepted")

            within "#proposal-#{first_proposal.id}-votes-count" do
              expect(page).to have_content("1\n2\nVote")
            end

            within "#proposal-#{second_proposal.id}-votes-count" do
              expect(page).to have_content("1\n2\nVote")
            end

            visit_component

            within "#proposal-#{first_proposal.id}-vote-button" do
              expect(page).to have_button("Voted")
            end

            within "#proposal-#{second_proposal.id}-vote-button" do
              expect(page).to have_button("Voted")
            end

            within "#proposal-#{first_proposal.id}-votes-count" do
              expect(page).to have_content("1\n2\nVote")
            end

            within "#proposal-#{second_proposal.id}-votes-count" do
              expect(page).to have_content("1\n2\nVote")
            end
          end
        end

        context "when there is no minimum, threshold but there is a limit" do
          let(:vote_limit) { 2 }

          it "displays single page" do
            visit_component
            click_on translated(first_proposal.title), match: :first

            within "#proposal-#{first_proposal.id}-vote-button" do
              click_on "Vote"
              expect(page).to have_button("Voted")
            end

            within "#proposal-#{first_proposal.id}-votes-count" do
              expect(page).to have_content("1\nVote")
            end

            expect(page).to have_no_content("Your votes have been successfully accepted")
          end

          it "it updates the number of votes" do
            visit_component

            within "#proposal-#{first_proposal.id}-vote-button" do
              click_on "Vote"
              expect(page).to have_button("Voted")
            end

            expect(page).to have_no_content("Your votes have been successfully accepted")

            within "#proposal-#{second_proposal.id}-vote-button" do
              click_on "Vote"
              expect(page).to have_button("Voted")
            end
            expect(page).to have_no_content("Your votes have been successfully accepted")

            within "#proposal-#{first_proposal.id}-votes-count" do
              expect(page).to have_content("1\nVote")
            end

            within "#proposal-#{second_proposal.id}-votes-count" do
              expect(page).to have_content("1\nVote")
            end

            unvoted_proposal_ids.each do |proposal_id|
              within "#proposal-#{proposal_id}-vote-button" do
                expect(page).to have_button("Vote", disabled: true)
              end
            end
            visit_component

            within "#proposal-#{first_proposal.id}-vote-button" do
              expect(page).to have_button("Voted")
            end

            within "#proposal-#{second_proposal.id}-vote-button" do
              expect(page).to have_button("Voted")
            end

            within "#proposal-#{first_proposal.id}-votes-count" do
              expect(page).to have_content("1\nVote")
            end

            within "#proposal-#{second_proposal.id}-votes-count" do
              expect(page).to have_content("1\nVote")
            end

            unvoted_proposal_ids.each do |proposal_id|
              within "#proposal-#{proposal_id}-vote-button" do
                expect(page).to have_button("Vote", disabled: true)
              end
            end
          end
        end

        context "when there is no minimum but there is a threshold and a limit" do
          let(:threshold_per_proposal) { 2 }
          let(:vote_limit) { 2 }

          it "displays single page" do
            visit_component
            click_on translated(first_proposal.title), match: :first

            within "#proposal-#{first_proposal.id}-vote-button" do
              click_on "Vote"
              expect(page).to have_button("Voted")
            end

            within "#proposal-#{first_proposal.id}-votes-count" do
              expect(page).to have_content("1 2\nVote")
            end

            expect(page).to have_no_content("Your votes have been successfully accepted")
          end

          it "it updates the number of votes" do
            visit_component

            within "#proposal-#{first_proposal.id}-vote-button" do
              click_on "Vote"
              expect(page).to have_button("Voted")
            end

            within "#proposal-#{second_proposal.id}-vote-button" do
              click_on "Vote"
              expect(page).to have_button("Voted")
            end

            within "#proposal-#{first_proposal.id}-votes-count" do
              expect(page).to have_content("1\n2\nVote")
            end

            within "#proposal-#{second_proposal.id}-votes-count" do
              expect(page).to have_content("1\n2\nVote")
            end

            unvoted_proposal_ids.each do |proposal_id|
              within "#proposal-#{proposal_id}-vote-button" do
                expect(page).to have_button("Vote", disabled: true)
              end
            end

            visit_component

            within "#proposal-#{first_proposal.id}-vote-button" do
              expect(page).to have_button("Voted")
            end

            within "#proposal-#{second_proposal.id}-vote-button" do
              expect(page).to have_button("Voted")
            end

            within "#proposal-#{first_proposal.id}-votes-count" do
              expect(page).to have_content("1\n2\nVote")
            end

            within "#proposal-#{second_proposal.id}-votes-count" do
              expect(page).to have_content("1\n2\nVote")
            end

            unvoted_proposal_ids.each do |proposal_id|
              within "#proposal-#{proposal_id}-vote-button" do
                expect(page).to have_button("Vote", disabled: true)
              end
            end
          end
        end

        context "when there is no threshold but there is a minimum and a limit" do
          let(:minimum_votes_per_user) { 2 }
          let(:vote_limit) { 2 }

          it "displays single page" do
            visit_component
            click_on translated(first_proposal.title), match: :first

            within "#proposal-#{first_proposal.id}-vote-button" do
              click_on "Vote"
              expect(page).to have_button("Voted")
            end

            within "#proposal-#{first_proposal.id}-votes-count" do
              expect(page).to have_content("0\nVotes")
            end

            expect(page).to have_no_content("Your votes have been successfully accepted")
          end

          it "it updates the number of votes" do
            visit_component

            expect(page).to have_content("You have 2 supports left")
            within "#proposal-#{first_proposal.id}-vote-button" do
              click_on "Vote"
              expect(page).to have_button("Voted")
            end

            expect(page).to have_content("You have 1 supports left")
            within "#proposal-#{second_proposal.id}-vote-button" do
              click_on "Vote"
              expect(page).to have_button("Voted")
            end

            within "#proposal-#{first_proposal.id}-votes-count" do
              expect(page).to have_content("1\nVote")
            end

            within "#proposal-#{second_proposal.id}-votes-count" do
              expect(page).to have_content("1\nVote")
            end

            unvoted_proposal_ids.each do |proposal_id|
              within "#proposal-#{proposal_id}-vote-button" do
                expect(page).to have_button("Vote", disabled: true)
              end
            end

            expect(page).to have_content("Your votes have been successfully accepted")

            visit_component

            within "#proposal-#{first_proposal.id}-vote-button" do
              expect(page).to have_button("Voted")
            end

            within "#proposal-#{second_proposal.id}-vote-button" do
              expect(page).to have_button("Voted")
            end

            within "#proposal-#{first_proposal.id}-votes-count" do
              expect(page).to have_content("1\nVote")
            end

            within "#proposal-#{second_proposal.id}-votes-count" do
              expect(page).to have_content("1\nVote")
            end

            unvoted_proposal_ids.each do |proposal_id|
              within "#proposal-#{proposal_id}-vote-button" do
                expect(page).to have_button("Vote", disabled: true)
              end
            end
          end
        end

        context "when there is a threshold, a minimum and a limit" do
          let(:minimum_votes_per_user) { 2 }
          let(:threshold_per_proposal) { 2 }
          let(:vote_limit) { 2 }

          it "displays single page" do
            visit_component
            click_on translated(first_proposal.title), match: :first

            within "#proposal-#{first_proposal.id}-vote-button" do
              click_on "Vote"
              expect(page).to have_button("Voted")
            end

            within "#proposal-#{first_proposal.id}-votes-count" do
              expect(page).to have_content("0 2\nVotes")
            end

            expect(page).to have_no_content("Your votes have been successfully accepted")
          end

          it "it updates the number of votes" do
            visit_component

            expect(page).to have_content("You have 2 supports left")

            within "#proposal-#{first_proposal.id}-vote-button" do
              click_on "Vote"
              expect(page).to have_button("Voted")
            end
            expect(page).to have_no_content("Your votes have been successfully accepted")

            expect(page).to have_content("You have 1 supports left")
            within "#proposal-#{second_proposal.id}-vote-button" do
              click_on "Vote"
              expect(page).to have_button("Voted")
            end

            within "#proposal-#{first_proposal.id}-votes-count" do
              expect(page).to have_content("1\n2\nVote")
            end

            within "#proposal-#{second_proposal.id}-votes-count" do
              expect(page).to have_content("1\n2\nVote")
            end

            unvoted_proposal_ids.each do |proposal_id|
              within "#proposal-#{proposal_id}-vote-button" do
                expect(page).to have_button("Vote", disabled: true)
              end
            end

            expect(page).to have_content("Your votes have been successfully accepted")
            visit_component

            within "#proposal-#{first_proposal.id}-vote-button" do
              expect(page).to have_button("Voted")
            end

            within "#proposal-#{second_proposal.id}-vote-button" do
              expect(page).to have_button("Voted")
            end

            within "#proposal-#{first_proposal.id}-votes-count" do
              expect(page).to have_content("1\n2\nVote")
            end

            within "#proposal-#{second_proposal.id}-votes-count" do
              expect(page).to have_content("1\n2\nVote")
            end

            unvoted_proposal_ids.each do |proposal_id|
              within "#proposal-#{proposal_id}-vote-button" do
                expect(page).to have_button("Vote", disabled: true)
              end
            end
          end
        end
      end

      context "when the proposal is not voted yet" do
        context "when on proposal page" do
          before do
            visit_component
            find(".card__list#proposals__proposal_#{proposal.id}").click
          end

          it "is able to vote the proposal" do
            within "#proposal-#{proposal.id}-vote-button" do
              click_on "Vote"
              expect(page).to have_button("Voted")
            end

            within "#proposal-#{proposal.id}-votes-count" do
              expect(page).to have_content("1\nVote")
            end
          end
        end

        context "when on proposals listing page" do
          before do
            visit_component
          end

          it "is able to vote the proposal" do
            within "#proposal-#{proposal.id}-vote-button" do
              click_on "Vote"
              expect(page).to have_button("Voted")
            end

            within "#proposal-#{proposal.id}-votes-count" do
              expect(page).to have_content("1\nVote")
            end
          end
        end
      end

      context "when the proposal is Voted" do
        context "when on proposal page" do
          before do
            create(:proposal_vote, proposal:, author: user)
            visit_component
            find(".card__list#proposals__proposal_#{proposal.id}").click
          end

          it "is not able to vote it again" do
            within "#proposal-#{proposal.id}-vote-button" do
              expect(page).to have_button("Voted")
            end

            within "#proposal-#{proposal.id}-votes-count" do
              expect(page).to have_content("1\nVote")
            end
          end

          it "is able to undo the vote" do
            within "#proposal-#{proposal.id}-vote-button" do
              click_on "Voted"
              expect(page).to have_button("Vote")
            end

            within "#proposal-#{proposal.id}-votes-count" do
              expect(page).to have_content("0\nVotes")
            end
          end
        end

        context "when on proposals listing page" do
          before do
            create(:proposal_vote, proposal:, author: user)
            visit_component
          end

          it "is not able to vote it again" do
            within "#proposal-#{proposal.id}-vote-button" do
              expect(page).to have_button("Voted")
            end

            within "#proposal-#{proposal.id}-votes-count" do
              expect(page).to have_content("1\nVote")
            end
          end

          it "is able to undo the vote" do
            within "#proposal-#{proposal.id}-vote-button" do
              click_on "Voted"
              expect(page).to have_button("Vote")
            end

            within "#proposal-#{proposal.id}-votes-count" do
              expect(page).to have_content("0\nVotes")
            end
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
          let(:proposals) { create_list(:proposal, 2, component:) }
          let(:proposal_title) { translated(proposals.first.title) }

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

              expect(page).to have_no_css("#voting-rules")
              expect(page).to have_no_css("div[data-remaining-votes-count=\"true\"]")

              find(".card__list#proposals__proposal_#{proposal.id}").click

              expect(page).to have_no_css("#voting-rules")
              expect(page).to have_no_css("div[data-remaining-votes-count=\"true\"]")
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

            it "shows the voting rules" do
              visit_component

              expect(page).to have_css("#voting-rules")

              find(".card__list#proposals__proposal_#{proposal.id}").click

              expect(page).to have_css("#proposal-voting-rules")
            end
          end

          context "when votes are disabled" do
            let!(:component) do
              create(:proposal_component,
                     :with_votes_disabled,
                     :with_vote_limit,
                     vote_limit:,
                     manifest:,
                     participatory_space: participatory_process)
            end

            it "does not show the remaining votes counter" do
              visit_component

              expect(page).to have_no_css("#voting-rules")
              expect(page).to have_no_css("div[data-remaining-votes-count=\"true\"]")

              find(".card__list#proposals__proposal_#{proposal.id}").click

              expect(page).to have_no_css("#voting-rules")
              expect(page).to have_no_css("div[data-remaining-votes-count=\"true\"]")
            end
          end
        end

        context "when the proposal is not voted yet" do
          context "when on proposal page" do
            before do
              visit_component
              find(".card__list#proposals__proposal_#{proposal.id}").click
            end

            it "updates the remaining votes counter" do
              within ".proposal__aside-vote" do
                click_on "Vote"
                expect(page).to have_button("Voted")
              end
            end
          end

          context "when on proposals listing page" do
            before do
              visit_component
            end

            it "updates the remaining votes counter" do
              within "#proposal-#{proposal.id}-vote-button" do
                click_on "Vote"
                expect(page).to have_button("Voted")
              end
            end
          end
        end

        context "when the proposal is not voted yet but the user is not authorized" do
          context "when there is only an authorization required" do
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
              find(".card__list#proposals__proposal_#{proposal.id}").click
            end

            it "redirects to the authorization form" do
              within "#proposal-#{proposal.id}-vote-button" do
                click_on "Vote"
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
                    "dummy_authorization_handler" => { "options" => {} },
                    "another_dummy_authorization_handler" => { "options" => {} }
                  }
                }
              }

              component.update!(permissions:)
              visit_component
              find(".card__list#proposals__proposal_#{proposal.id}").click
            end

            it "redirects to pending onboarding authorizations page" do
              within "#proposal-#{proposal.id}-vote-button" do
                click_on "Vote"
              end

              expect(page).to have_content("You are almost ready to vote")
              expect(page).to have_css("a[data-verification]", count: 2)
            end
          end
        end

        context "when the proposal is Voted" do
          context "when on proposal page" do
            before do
              create(:proposal_vote, proposal:, author: user)
              visit_component
              find(".card__list#proposals__proposal_#{proposal.id}").click
            end

            it "is not able to vote it again" do
              within "#proposal-#{proposal.id}-vote-button" do
                expect(page).to have_button("Voted")
              end
            end

            it "is able to undo the vote" do
              within ".proposal__aside-vote" do
                click_on "Voted"
                expect(page).to have_button("Vote")
              end

              within "#proposal-#{proposal.id}-votes-count" do
                expect(page).to have_content("0\nVotes")
              end
            end
          end

          context "when on proposals listing page" do
            before do
              create(:proposal_vote, proposal:, author: user)
              visit_component
            end

            it "is not able to vote it again" do
              within "#proposal-#{proposal.id}-vote-button" do
                expect(page).to have_button("Voted")
              end
            end

            it "is able to undo the vote" do
              within "#proposal-#{proposal.id}-vote-button" do
                click_on "Voted"
                expect(page).to have_button("Vote")
              end

              within "#proposal-#{proposal.id}-votes-count" do
                expect(page).to have_content("0\nVotes")
              end
            end
          end
        end

        context "when the user has reached the votes limit" do
          let(:vote_limit) { 1 }

          before do
            create(:proposal_vote, proposal:, author: user)
            visit_component
          end

          context "when on proposal page" do
            it "is not able to vote other proposals" do
              find(".card__list#proposals__proposal_#{proposal.id}").click
              within ".proposal__aside-vote" do
                expect(page).to have_content("1\nVote")
              end

              other_proposals_titles.each do |title|
                visit_component
                click_on title
                within ".proposal__aside-vote" do
                  expect(page).to have_content("No votes remaining")
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
                find(".card__list#proposals__proposal_#{proposal.id}").click
                within ".proposal__aside-vote" do
                  expect(page).to have_content("1\nVote")
                end

                other_proposals_titles.each do |title|
                  visit_component
                  click_on title
                  within ".proposal__aside-vote" do
                    expect(page).to have_content("Vote")
                    expect(page).to have_css(".button[disabled]")
                  end
                end
              end
            end
          end

          context "when on proposals listing page" do
            it "is not able to vote other proposals" do
              within "#proposal-#{proposal.id}-vote-button" do
                expect(page).to have_button("Voted")
              end

              within "#proposal-#{proposal.id}-votes-count" do
                expect(page).to have_content("1\nVote")
              end

              2.times do |index|
                within "#proposal-#{proposals[1 + index].id}-vote-button" do
                  expect(page).to have_button("Vote", disabled: true)
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
                within "#proposal-#{proposal.id}-vote-button" do
                  expect(page).to have_button("Voted", disabled: true)
                end

                within "#proposal-#{proposal.id}-votes-count" do
                  expect(page).to have_content("1\nVote")
                end

                2.times do |index|
                  within "#proposal-#{proposals[1 + index].id}-vote-button" do
                    expect(page).to have_button("Vote", disabled: true)
                  end
                end
              end
            end
          end
        end
      end

      context "when participant has a minimum number of votes per proposal" do
        let(:vote_limit) { 8 }
        let(:minimum_votes_per_user) { 5 }

        let!(:component) do
          create(:proposal_component,
                 :with_votes_enabled,
                 participatory_space: participatory_process,
                 settings:)
        end
        let(:settings) do
          {
            minimum_votes_per_user:,
            vote_limit:
          }
        end

        it "shows the voting rules" do
          visit_component

          expect(page).to have_css("#voting-rules")
          expect(page).to have_content("You can support up to 8 proposals.")
          expect(page).to have_content("You have to distribute a minimum of 5 supports among different proposals so that your supports are taken into account.")

          click_on proposal_title, match: :first

          expect(page).to have_css("#proposal-voting-rules")
        end

        it "shows a modal dialog" do
          visit_component
          click_on proposal_title, match: :first
          expect(page).to have_content("Vote")
          click_on "Vote"
          expect(page).to have_content("Voted")
          first("a", text: "Proposals").click

          expect(page).to have_content("Remember you have 4 votes left")
          expect(page).to have_content("You have to give 4 more votes between different proposals for your votes to be taken into account.")
          expect(page).to have_content("Continue")
          expect(page).to have_content("Cancel")

          click_on "Continue"
          expect(page).to have_content("proposals")
          expect(page).to have_content("Status")
        end

        context "when participant vote" do
          let!(:vote_limit) { 4 }
          let!(:minimum_votes_per_user) { 2 }

          context "when on proposal page" do
            before do
              visit_component
              click_on proposal_title, match: :first
              click_on "Vote"
            end

            it "shows a notification indicating how many votes participant has left to give" do
              expect(page).to have_content("You have 1 supports left")
              expect(page).to have_content("Remember that you still have to give 1 supports between different proposals so that your supports are taken into account.")

              click_on "Voted"
              expect(page).to have_content("You have 2 supports left")
            end
          end
        end

        context "when participant has voted for the minimum number of proposals" do
          let!(:vote_limit) { 2 }
          let!(:minimum_votes_per_user) { 1 }

          context "when on proposal page" do
            before do
              visit_component
              click_on proposal_title, match: :first
              click_on "Vote"
            end

            it "shows a notification indicating that participant have correctly given all the minimum votes" do
              expect(page).to have_content("Your votes have been successfully accepted")
            end

            context "when participant start voting proposals" do
              let!(:vote_limit) { 4 }
              let!(:minimum_votes_per_user) { 2 }

              it "shows the exit modal" do
                expect(page).to have_content("Voted")

                expect(page).to have_content("Proposals")
                first("a", text: "Proposals").click

                expect(page).to have_content("Remember you have 1 votes left", wait: 10)
                expect(page).to have_content("You have to give 1 more votes between different proposals for your votes to be taken into account.")
                expect(page).to have_content("Continue")
                expect(page).to have_content("Cancel")

                click_on "Cancel"

                expect(page).to have_content("You have 1 supports left", wait: 10)
                expect(page).to have_content("Remember that you still have to give")
              end
            end

            it "does not show the exit modal" do
              expect(page).to have_content("Voted")
              expect(page).to have_content("Your votes have been successfully accepted")

              click_on "Voted"
              expect(page).to have_content("See other proposals")
              expect(page).to have_content("You have 1 supports left", wait: 10)

              click_on "See other proposals"
              expect(page).to have_content("3 proposals")
              expect(page).to have_css("#proposals__proposal_#{proposal.id}")

              click_on translated_attribute(proposal.title), match: :first
              click_on "Vote"
              expect(page).to have_content("Your votes have been successfully accepted")

              page.find(".main-bar__logo a").click
              expect(page).to have_no_content("Voted", wait: 10)
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

        click_on rejected_proposal_title
        expect(page).to have_no_selector("#proposal-#{rejected_proposal.id}-vote-button")
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

      context "when on proposal page" do
        it "does not allow users to vote to a proposal that is reached the limit" do
          create(:proposal_vote, proposal:)
          visit_component
          find(".card__list#proposals__proposal_#{proposal.id}").click

          within "#proposal-#{proposal.id}-vote-button" do
            expect(page).to have_content("Vote limit reached")
          end
        end

        it "allows users to vote on proposals under the limit" do
          visit_component
          find(".card__list#proposals__proposal_#{proposal.id}").click

          within ".proposal__aside-vote" do
            click_on "Vote"
            expect(page).to have_button("Voted")
          end
        end
      end

      context "when on proposals listing page" do
        it "does not allow users to vote to a proposal that is reached the limit" do
          create(:proposal_vote, proposal:)
          visit_component

          within "#proposal-#{proposal.id}-vote-button" do
            expect(page).to have_content("Vote limit reached")
          end
        end

        it "allows users to vote on proposals under the limit" do
          visit_component

          within "#proposal-#{proposal.id}-vote-button" do
            click_on "Vote"
            expect(page).to have_content("Voted")
          end

          within "#proposal-#{proposal.id}-votes-count" do
            expect(page).to have_content("1\nVote")
          end
        end
      end
    end

    context "when proposals have vote limit but can accumulate more votes" do
      let!(:component) do
        create(:proposal_component,
               :with_votes_enabled,
               :with_threshold_per_proposal,
               :with_can_accumulate_votes_beyond_threshold,
               manifest:,
               participatory_space: participatory_process)
      end

      before do
        login_as user, scope: :user
      end

      context "when on proposal page" do
        it "allows users to vote on proposals over the limit" do
          create(:proposal_vote, proposal:)
          visit_component

          find(".card__list#proposals__proposal_#{proposal.id}").click

          within ".proposal__aside-vote" do
            expect(page).to have_content("1\nVote")
          end
        end
      end

      context "when on proposals listing page" do
        it "allows users to vote on proposals over the limit" do
          visit_component

          within "#proposal-#{proposal.id}-vote-button" do
            click_on "Vote"
            sleep(1)
            expect(page).to have_content("Voted")
          end
          within "#proposal-#{proposal.id}-votes-count" do
            expect(page).to have_content("1\nVote")
          end
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

      context "when on proposal page" do
        it "does not count votes unless the minimum is achieved" do
          visit_component

          proposal_ids = proposals.map(&:id)

          find(".card__list#proposals__proposal_#{proposal_ids[0]}").click

          within ".proposal__aside-vote" do
            click_on "Vote"
            expect(page).to have_content("Voted")
            expect(page).to have_content("0\nVotes")
          end

          visit_component
          find(".card__list#proposals__proposal_#{proposal_ids[1]}").click
          within ".proposal__aside-vote" do
            click_on "Vote"
            expect(page).to have_content("Voted")
            expect(page).to have_content("0\nVotes")
          end

          visit_component
          find(".card__list#proposals__proposal_#{proposal_ids[2]}").click
          within ".proposal__aside-vote" do
            click_on "Vote"
            expect(page).to have_content("Voted")
            expect(page).to have_content("1\nVote")
          end

          visit_component
          find(".card__list#proposals__proposal_#{proposal_ids[0]}").click
          within ".proposal__aside-vote" do
            expect(page).to have_content("1\nVote")
          end

          visit_component
          find(".card__list#proposals__proposal_#{proposal_ids[1]}").click
          within ".proposal__aside-vote" do
            expect(page).to have_content("1\nVote")
          end
        end
      end

      context "when on proposals listing page" do
        it "does not count votes unless the minimum is achieved" do
          visit_component

          proposal_ids = proposals.map(&:id)

          within "#proposal-#{proposal_ids[0]}-vote-button" do
            click_on "Vote"
            sleep(1)
            expect(page).to have_content("Voted")
          end
          within "#proposal-#{proposal_ids[0]}-votes-count" do
            expect(page).to have_content("0\nVotes")
          end

          within "#proposal-#{proposal_ids[1]}-vote-button" do
            click_on "Vote"
            sleep(1)
            expect(page).to have_content("Voted")
          end
          within "#proposal-#{proposal_ids[1]}-votes-count" do
            expect(page).to have_content("0\nVotes")
          end

          within "#proposal-#{proposal_ids[2]}-vote-button" do
            click_on "Vote"
            sleep(1)
            expect(page).to have_content("Voted")
          end

          3.times do |index|
            within "#proposal-#{proposal_ids[index]}-votes-count" do
              expect(page).to have_content("1\nVote")
            end
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
        find(".card__list#proposals__proposal_#{proposal.id}").click

        expect do
          within ".proposal__aside-vote" do
            click_on "Vote"
            expect(page).to have_content("1\nVote")
          end
        end.to change { Decidim::Gamification.status_for(user, :proposal_votes).score }.by(1)
      end
    end
  end
end
