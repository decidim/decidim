# frozen_string_literal: true

require "spec_helper"

describe "Interact with commenters" do
  include_context "with a component"
  let(:manifest_name) { "proposals" }
  let(:proposal) { create(:proposal, users: [user], component:) }
  let(:commenter) { create(:user, :confirmed, organization:) }
  let!(:comment) { create(:comment, commentable: proposal, author: commenter) }
  let!(:author_comment) { create(:comment, commentable: proposal, author: user) }

  def visit_proposal
    visit resource_locator(proposal).path
  end

  context "when author" do
    before do
      login_as user, scope: :user
      visit_proposal
    end

    context "when the user is the commenter" do
      it "has no actions" do
        within "#comment_#{author_comment.id}" do
          find("#dropdown-trigger-toggle-context-menu-#{author_comment.id}").click
          expect(page).to have_no_content("Mark as co-author")
        end
      end
    end

    context "when the user is not the commenter" do
      let(:notification) { Decidim::Notification.last }

      it "author can invite" do
        expect(page).to have_content("2 comments")
        within "#comment_#{comment.id}" do
          find("#dropdown-trigger-toggle-context-menu-#{comment.id}").click
          perform_enqueued_jobs do
            accept_confirm { click_on("Mark as co-author") }
          end
        end

        expect(page).to have_content("has been successfully invited as a co-author")

        within "#comment_#{comment.id}" do
          find("#dropdown-trigger-toggle-context-menu-#{comment.id}").click
          expect(page).to have_link("Cancel co-author invitation")
          expect(page).to have_no_content("Mark as co-author")
        end

        expect(notification.event_class).to eq("Decidim::Proposals::CoauthorInvitedEvent")
        expect(notification.resource).to eq(proposal)
        expect(notification.user).to eq(commenter)
        # sends email to commenter
        expect(last_email.to).to include(commenter.email)
      end
    end

    context "when a notification already exists" do
      let!(:notification) { create(:notification, :proposal_coauthor_invite, user: commenter, resource: proposal) }

      it "author can cancel invitation" do
        within "#comment_#{comment.id}" do
          find("#dropdown-trigger-toggle-context-menu-#{comment.id}").click
          perform_enqueued_jobs do
            accept_confirm { click_on("Cancel co-author invitation") }
          end
        end

        expect(page).to have_content("Co-author invitation successfully canceled")

        within "#comment_#{comment.id}" do
          find("#dropdown-trigger-toggle-context-menu-#{comment.id}").click
          expect(page).to have_link("Mark as co-author")
          expect(page).to have_no_content("Cancel co-author invitation")
        end

        expect { notification.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  context "when commenter" do
    let!(:notification) { create(:notification, :proposal_coauthor_invite, user: commenter, resource: proposal) }
    let(:author_notification) { Decidim::Notification.find_by(user:) }

    before do
      login_as commenter, scope: :user
      visit decidim.notifications_path
    end

    it "coauthor can accept invitation" do
      expect(page).to have_content("#{user.name} would like to invite you as a co-author of the proposal")

      perform_enqueued_jobs do
        click_on "Accept"

        expect(page).to have_content("The invitation has been accepted")
        expect(proposal.reload.authors).to include(commenter)
        expect { notification.reload }.to raise_error(ActiveRecord::RecordNotFound)

        visit decidim.notifications_path
        expect(page).to have_no_content("would like to invite you as a co-author of the proposal")
        expect(page).to have_content("You have been added as a co-author of the proposal")
        expect(last_email).to be_nil
        expect(author_notification.event_class).to eq("Decidim::Proposals::CoauthorAcceptedInviteEvent")
        expect(author_notification.extra["coauthor_id"]).to eq(commenter.id)
      end
    end

    it "coauthor can decline invitation" do
      perform_enqueued_jobs do
        click_on "Decline"

        expect(page).to have_content("The invitation has been declined")
        expect(proposal.reload.authors).not_to include(commenter)
        expect { notification.reload }.to raise_error(ActiveRecord::RecordNotFound)

        visit decidim.notifications_path
        expect(page).to have_no_content("would like to invite you as a co-author of the proposal")
        expect(page).to have_content("You have declined the invitation from")
        expect(last_email).to be_nil
        expect(author_notification.event_class).to eq("Decidim::Proposals::CoauthorRejectedInviteEvent")
        expect(author_notification.extra["coauthor_id"]).to eq(commenter.id)
      end
    end
  end
end
