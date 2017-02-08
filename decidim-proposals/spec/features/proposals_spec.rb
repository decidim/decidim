# frozen_string_literal: true
require "spec_helper"

describe "Proposals", type: :feature do
  include_context "feature"
  let(:manifest_name) { "proposals" }

  let!(:proposals) { create_list(:proposal, 3, feature: feature) }
  let!(:category) { create :category, participatory_process: participatory_process }
  let!(:scope) { create :scope, organization: organization }
  let!(:user) { create :user, :confirmed, organization: organization }

  before do
    visit_feature
  end

  context "creating a new proposal" do
    context "when the user is logged in" do
      before do
        login_as user, scope: :user
        visit_feature
      end

      context "with creation enabled" do
        let!(:feature) do
          create(:proposal_feature,
                 :with_creation_enabled,
                 manifest: manifest,
                 participatory_process: participatory_process)
        end

        it "creates a new proposal" do
          click_link "New proposal"

          within ".new_proposal" do
            fill_in :proposal_title, with: "Oriol for president"
            fill_in :proposal_body, with: "He will solve everything"
            select category.name["en"], from: :proposal_category_id
            select scope.name, from: :proposal_scope_id

            find("*[type=submit]").click
          end

          expect(page).to have_content("successfully")
          expect(page).to have_content("Oriol for president")
          expect(page).to have_content("He will solve everything")
          expect(page).to have_content(category.name["en"])
          expect(page).to have_content(scope.name)
          expect(page).to have_content(user.name)
        end

        context "when the user has verified organizations" do
          let(:user_group) { create(:user_group, :verified) }

          before do
            create(:user_group_membership, user: user, user_group: user_group)
          end

          it "creates a new proposal as a user group" do
            click_link "New proposal"

            within ".new_proposal" do
              fill_in :proposal_title, with: "Oriol for president"
              fill_in :proposal_body, with: "He will solve everything"
              select category.name["en"], from: :proposal_category_id
              select scope.name, from: :proposal_scope_id
              select user_group.name, from: :proposal_user_group_id

              find("*[type=submit]").click
            end

            expect(page).to have_content("successfully")
            expect(page).to have_content("Oriol for president")
            expect(page).to have_content("He will solve everything")
            expect(page).to have_content(category.name["en"])
            expect(page).to have_content(scope.name)
            expect(page).to have_content(user_group.name)
          end
        end

        context "when the user isn't authorized" do
          before do
            feature.update_attribute(:permissions, create: { authorization_handler_name: "decidim/dummy_authorization_handler" })
            visit_feature
          end

          it "should show a modal dialog" do
            click_link "New proposal"
            expect(page).to have_content("Authorization required")
          end
        end
      end

      context "when creation is not enabled" do
        it "does not show the creation button" do
          expect(page).to have_no_link("New proposal")
        end
      end
    end
  end

  context "viewing a single proposal" do
    it "allows viewing a single proposal" do
      proposal = proposals.first

      click_link proposal.title

      expect(page).to have_content(proposal.title)
      expect(page).to have_content(proposal.body)
      expect(page).to have_content(proposal.author.name)
    end

    context "when it is an official proposal" do
      let!(:official_proposal) { create(:proposal, feature: feature, author: nil) }

      it "shows the author as official" do
        visit_feature
        click_link official_proposal.title
        expect(page).to have_content("Official proposal")
      end
    end

    context "when a proposal has comments" do
      let(:proposal) { create(:proposal, feature: feature) }
      let(:author) { create(:user, :confirmed, organization: feature.organization) }
      let!(:comments) { create_list(:comment, 3, commentable: proposal) }

      it "shows the comments" do
        visit_feature
        click_link proposal.title

        comments.each do |comment|
          expect(page).to have_content(comment.body)
        end
      end
    end

    context "when a proposal has been linked in a meeting" do
      let(:proposal) { create(:proposal, feature: feature) }
      let(:meeting_feature) do
        create(:feature, manifest_name: :meetings, participatory_process: proposal.feature.participatory_process)
      end
      let(:meeting) { create(:meeting, feature: meeting_feature) }

      before do
        meeting.link_resources([proposal], "proposals_from_meeting")
      end

      it "shows related meetings" do
        visit_feature
        click_link proposal.title

        expect(page).to have_i18n_content(meeting.title)
      end
    end

    context "when a proposal has been linked in a result" do
      let(:proposal) { create(:proposal, feature: feature) }
      let(:result_feature) do
        create(:feature, manifest_name: :results, participatory_process: proposal.feature.participatory_process)
      end
      let(:result) { create(:result, feature: result_feature) }

      before do
        result.link_resources([proposal], "included_proposals")
      end

      it "shows related results" do
        visit_feature
        click_link proposal.title

        expect(page).to have_i18n_content(result.title)
      end
    end

    context "when a proposal has been accepted" do
      let!(:proposal) { create(:proposal, :accepted, feature: feature) }

      it "shows a badge" do
        visit_feature
        click_link proposal.title

        expect(page).to have_content("Accepted")
        expect(page).to have_i18n_content(proposal.answer)
      end
    end

    context "when a proposal has been rejected" do
      let!(:proposal) { create(:proposal, :rejected, feature: feature) }

      it "shows the rejection reason" do
        visit_feature
        click_link proposal.title

        expect(page).to have_content("Rejected")
        expect(page).to have_i18n_content(proposal.answer)
      end
    end
  end

  context "when a proposal has been linked in a project" do
    let(:proposal) { create(:proposal, feature: feature)}
    let(:budget_feature) do
      create(:feature, manifest_name: :budgets, participatory_process: proposal.feature.participatory_process)
    end
    let(:project) { create(:project, feature: budget_feature) }

    before do
      project.link_resources([proposal], "included_proposals")
    end

    it "shows related projects" do
      visit_feature
      click_link proposal.title

      expect(page).to have_i18n_content(project.title)
    end
  end

  context "listing proposals in a participatory process" do
    it "lists all the proposals" do
      expect(page).to have_css(".card--proposal", count: 3)
    end

    context "when there are a lot of proposals" do
      before do
        create_list(:proposal, 17, feature: feature)
        visit_feature
      end

      it "paginates them" do
        expect(page).to have_css(".card--proposal", count: 12)

        find(".pagination-next a").click

        expect(page).to have_css(".card--proposal", count: 8)
      end
    end

    context "when filtering" do
      context "by origin 'official'" do
        it "lists the filtered proposals" do
          create(:proposal, :official, feature: feature, scope: scope)
          visit_feature

          within ".filters" do
            choose "Official"
          end

          expect(page).to have_css(".card--proposal", count: 1)
          expect(page).to have_content("1 PROPOSAL")
        end
      end

      context "by origin 'citizenship'" do
        it "lists the filtered proposals" do
          within ".filters" do
            choose "Citizenship"
          end

          expect(page).to have_css(".card--proposal", count: proposals.size)
          expect(page).to have_content("#{proposals.size} PROPOSALS")
        end
      end

      context "by accepted" do
        it "lists the filtered proposals" do
          create(:proposal, :accepted, feature: feature, scope: scope)
          visit_feature

          within ".filters" do
            choose "Accepted"
          end

          expect(page).to have_css(".card--proposal", count: 1)
          expect(page).to have_content("1 PROPOSAL")

          within ".card--proposal" do
            expect(page).to have_content("Accepted")
          end
        end
      end

      context "by rejected" do
        it "lists the filtered proposals" do
          create(:proposal, :rejected, feature: feature, scope: scope)
          visit_feature

          within ".filters" do
            choose "Rejected"
          end

          expect(page).to have_css(".card--proposal", count: 1)
          expect(page).to have_content("1 PROPOSAL")

          within ".card--proposal" do
            expect(page).to have_content("Rejected")
          end
        end
      end
    end

    context "when ordering" do
      context "by 'most_support'" do
        let!(:feature) do
          create(:proposal_feature,
            :with_votes_enabled,
            manifest: manifest,
            participatory_process: participatory_process)
        end

        before do
          proposals.each do |proposal|
            create(:proposal_vote, proposal: proposal)
          end
        end

        it "lists the proposals ordered by votes" do
          most_voted_proposal = create(:proposal, feature: feature)
          create_list(:proposal_vote, 3, proposal: most_voted_proposal)
          less_voted_proposal = create(:proposal, feature: feature)

          visit_feature

          within ".order-by" do
            page.find('.dropdown.menu .is-dropdown-submenu-parent').hover
          end

          click_link "Most voted"

          expect(page.find('#proposals .card-grid .column:first-child', text: most_voted_proposal.title)).to be
          expect(page.find('#proposals .card-grid .column:last-child', text: less_voted_proposal.title)).to be
        end
      end

      context "by 'recent'" do
        it "lists the proposals ordered by created at" do
          older_proposal = create(:proposal, feature: feature, created_at: 1.month.ago)
          recent_proposal = create(:proposal, feature: feature)

          visit_feature

          within ".order-by" do
            page.find('.dropdown.menu .is-dropdown-submenu-parent').hover
          end

          click_link "Recent"

          expect(page.find('#proposals .card-grid .column:first-child', text: recent_proposal.title)).to be
          expect(page.find('#proposals .card-grid .column:last-child', text: older_proposal.title)).to be
        end
      end
    end
  end
end
