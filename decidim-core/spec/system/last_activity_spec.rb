# frozen_string_literal: true

require "spec_helper"

describe "Last activity" do
  let(:organization) { create(:organization) }
  let!(:proposal_component) { create(:proposal_component) }
  let!(:withdrawn_proposal) { create(:proposal, :withdrawn, component: proposal_component) }
  let!(:proposal) { create(:proposal, :published, component: proposal_component) }
  let(:commentable) { create(:dummy_resource, component:) }
  let(:comment) { create(:comment, commentable:) }
  let!(:action_log) do
    create(:action_log,
           created_at: 1.day.ago,
           visibility: "public-only",
           participatory_space: comment.participatory_space,
           resource: comment,
           organization:)
  end
  let!(:action_log_for_withdrawn_proposal) do
    create(:action_log, created_at: 1.day.ago, action: "create", visibility: "public-only", resource: withdrawn_proposal, organization:, participatory_space: comment.participatory_space,)
  end
  let!(:action_log_for_proposal) do
    create(:action_log, created_at: 1.day.ago, action: "create", visibility: "public-only", resource: proposal, organization:, participatory_space: comment.participatory_space,)
  end
  let!(:another_action_log) do
    create(:action_log,
           created_at: 2.days.ago,
           visibility: "public-only",
           participatory_space: another_comment.participatory_space,
           resource: another_comment,
           organization:)
  end
  let!(:other_action_log) do
    create(:action_log,
           action: "publish",
           visibility: "all",
           resource:,
           participatory_space: resource.participatory_space,
           organization:)
  end
  let(:long_body_comment) { "This is my very long comment for Last Activity card that must be shorten up because is more than 100 chars" }
  let(:another_comment) { create(:comment, body: long_body_comment, commentable: second_commentable) }
  let(:component) do
    create(:component, :published, organization:)
  end
  let(:resource) do
    create(:dummy_resource, component:, published_at: Time.current)
  end
  let(:second_commentable) { create(:dummy_resource, component:) }

  before do
    allow(Decidim::ActionLog).to receive(:public_resource_types).and_return(
      %w(
        Decidim::Comments::Comment
        Decidim::Proposals::Proposal
        Decidim::Dev::DummyResource
      )
    )
    allow(Decidim::ActionLog).to receive(:publicable_public_resource_types).and_return(
      %w(Decidim::Dev::DummyResource)
    )

    create(:content_block, organization:, scope_name: :homepage, manifest_name: :last_activity)
    switch_to_host organization.host
  end

  describe "accessing the homepage with the last activity content block enabled" do
    before do
      page.visit decidim.root_path
    end

    it "displays the activities at the home page" do
      within "#last_activity" do
        expect(page).to have_css("[data-activity]", count: 4)
      end
    end

    it "shows activities long comment shorten text" do
      expect(page).to have_content(long_body_comment[0..79])
      expect(page).to have_no_content(another_comment.translated_body)
      expect(page).to have_no_content(withdrawn_proposal.title)

    end

    context "when there is a deleted comment" do
      let(:comment) { create(:comment, :deleted, body: "This is deleted") }

      it "is not shown" do
        within "#last_activity" do
          expect(page).to have_no_content("This is deleted")
        end
      end
    end

    context "when viewing all activities" do
      before do
        within "#last_activity" do
          click_on "View all"
        end
      end

      it "shows all activities" do
        expect(page).to have_css("[data-activity]", count: 4)
        expect(page).to have_content(translated(resource.title))
        expect(page).to have_content(translated(comment.commentable.title))
        expect(page).to have_content(translated(another_comment.commentable.title))
        expect(page).to have_content(translated(proposal.title))
        expect(page).to have_no_content(translated(withdrawn_proposal.title))
      end

      it "shows the activities in correct order" do
        result = page.find_by_id("activities").text
        expect(result.index(translated(resource.title))).to be < result.index(translated(comment.commentable.title))
        expect(result.index(translated(comment.commentable.title))).to be < result.index(translated(another_comment.commentable.title))
      end

      it "allows filtering by type" do
        within "#filters" do
          click_on("Comment")
        end

        expect(page).to have_content(translated(comment.commentable.title))
        expect(page).to have_content(translated(another_comment.commentable.title))
        expect(page).to have_no_content(translated(resource.title))
        expect(page).to have_css("[data-activity]", count: 2)
      end

      context "when there are recently update old activities" do
        let(:commentables) { create_list(:dummy_resource, 50, component:) }
        let(:comments) { commentables.map { |commentable| create(:comment, commentable:) } }
        let!(:action_logs) do
          comments.map do |comment|
            create(:action_log, created_at: 1.day.ago, action: "create", visibility: "public-only", resource: comment, organization:)
          end
        end

        let(:old_commentable) { create(:dummy_resource, component:) }
        let(:old_comment) { create(:comment, commentable: old_commentable, created_at: 2.years.ago) }
        let!(:create_action_log) { create(:action_log, created_at: 2.years.ago, action: "create", visibility: "public-only", resource: old_comment, organization:) }
        let!(:update_action_log) { create(:action_log, created_at: 1.minute.ago, action: "update", visibility: "public-only", resource: old_comment, organization:) }

        before do
          visit current_path
        end

        it "does not show the old activities at the top of the list" do
          expect(page).to have_no_content(translated(old_comment.commentable.title))
        end
      end

      context "when there are activities from private spaces" do
        before do
          comment.update(body: { es: "this is a private comment" })
          another_comment.update(body: { es: "this is another private comment" })

          component.participatory_space.update(private_space: true)
          comment.participatory_space.update(private_space: true)
          another_comment.participatory_space.update(private_space: true)

          visit current_path
        end

        it "does not show the activities" do
          expect(page).to have_css("[data-activity]", count: 0)
          expect(page).to have_content "There are no entries to show for this activity type."
        end
      end

      context "when there are lots of moderated resources" do
        before do
          100.times.each do
            comment = create(:comment)
            create(:action_log, action: "create", visibility: "all", resource: comment, organization:)
            create(:moderation, reportable: comment, hidden_at: 1.day.ago)
          end
          visit current_path
        end

        it "works without an empty pagination" do
          expect(page).to have_css("[data-activity]", count: 4)
        end
      end
    end
  end
end
