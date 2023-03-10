# frozen_string_literal: true

require "spec_helper"

describe "Last activity", type: :system do
  let(:organization) { create(:organization) }
  let(:commentable) { create(:dummy_resource, component:) }
  let(:comment) { create(:comment, commentable:) }
  let!(:action_log) do
    create(:action_log, created_at: 1.day.ago, action: "create", visibility: "public-only", resource: comment, organization:)
  end
  let!(:other_action_log) do
    create(:action_log, action: "publish", visibility: "all", resource:, organization:, participatory_space: component.participatory_space)
  end
  let(:long_body_comment) { "This is my very long comment for Last Activity card that must be shorten up because is more than 100 chars" }
  let(:another_comment) { create(:comment, body: long_body_comment) }
  let!(:another_action_log) do
    create(:action_log, created_at: 2.days.ago, action: "create", visibility: "public-only", resource: another_comment, organization:)
  end
  let(:component) do
    create(:component, :published, organization:)
  end
  let(:resource) do
    create(:dummy_resource, component:, published_at: Time.current)
  end

  before do
    allow(Decidim::ActionLog).to receive(:public_resource_types).and_return(
      %w(
        Decidim::Comments::Comment
        Decidim::DummyResources::DummyResource
      )
    )
    allow(Decidim::ActionLog).to receive(:publicable_public_resource_types).and_return(
      %w(Decidim::DummyResources::DummyResource)
    )

    create :content_block, organization: organization, scope_name: :homepage, manifest_name: :last_activity
    switch_to_host organization.host
  end

  describe "accessing the homepage with the last activity content block enabled" do
    before do
      page.visit decidim.root_path
    end

    it "displays the activities at the home page" do
      within "#last_activity" do
        expect(page).to have_css("[data-activity]", count: 3)
      end
    end

    it "shows activities long comment shorten text" do
      expect(page).to have_content(long_body_comment[0..79])
      expect(page).to have_no_content(another_comment.translated_body)
    end

    context "when there is a deleted comment" do
      let(:comment) { create(:comment, :deleted, body: "This is deleted") }

      it "isn't shown" do
        within "#last_activity" do
          expect(page).not_to have_content("This is deleted")
        end
      end
    end

    context "when viewing all activities" do
      before do
        within "#last_activity" do
          click_link "View all"
        end
      end

      it "shows all activities" do
        expect(page).to have_css("[data-activity]", count: 3)
        expect(page).to have_content(translated(resource.title))
        expect(page).to have_content(translated(comment.commentable.title))
        expect(page).to have_content(translated(another_comment.commentable.title))
      end

      it "shows the activities in correct order" do
        result = page.find("#activities .row").text
        expect(result.index(translated(resource.title))).to be < result.index(translated(comment.commentable.title))
        expect(result.index(translated(comment.commentable.title))).to be < result.index(translated(another_comment.commentable.title))
      end

      it "allows filtering by type" do
        within ".filters" do
          choose "Comment"
        end

        expect(page).to have_content(translated(comment.commentable.title))
        expect(page).to have_content(translated(another_comment.commentable.title))
        expect(page).to have_no_content(translated(resource.title))
        expect(page).to have_css("[data-activity]", count: 2)
      end

      context "when there are recently update old activities" do
        let(:commentables) { create_list(:dummy_resource, 20, component:) }
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
          expect(page).not_to have_content(translated(old_comment.commentable.title))
        end
      end

      context "when there are activities from private spaces" do
        before do
          component.participatory_space.update(private_space: true)
          comment.participatory_space.update(private_space: true)
          another_comment.participatory_space.update(private_space: true)
          visit current_path
        end

        it "does not show the activities" do
          expect(page).to have_css("[data-activity]", count: 0)
        end
      end
    end
  end
end
