# frozen_string_literal: true

require "spec_helper"

describe "Last activity", type: :system do
  Decidim::ActivitySearch.class_eval do
    def resource_types
      %w(
        Decidim::Comments::Comment
        Decidim::DummyResources::DummyResource
      )
    end
  end
  let(:organization) { create(:organization) }
  let(:comment) { create(:comment) }
  let!(:action_log) do
    create(:action_log, action: "create", visibility: "public-only", resource: comment, organization: organization)
  end
  let!(:other_action_log) do
    create(:action_log, action: "publish", visibility: "all", resource: resource, organization: organization, participatory_space: component.participatory_space)
  end
  let(:component) do
    create(:component, :published, organization: organization)
  end
  let(:resource) do
    create(:dummy_resource, component: component, published_at: Time.current)
  end

  before do
    create :content_block, organization: organization, scope: :homepage, manifest_name: :last_activity
    switch_to_host organization.host
  end

  describe "accessing the last activity page" do
    before do
      page.visit decidim.root_path
    end

    it "displays the activities at the home page" do
      within ".upcoming-events" do
        expect(page).to have_css("article.card", count: 2)
      end
    end

    context "when viewing all activities" do
      before do
        within ".upcoming-events" do
          click_link "View all"
        end
      end

      it "shows all activities" do
        expect(page).to have_css("article.card", count: 2)
        expect(page).to have_content(resource.title)
        expect(page).to have_content(comment.commentable.title)
      end

      it "allows filtering by type" do
        within ".filters" do
          choose "Comment"
        end

        expect(page).to have_content(comment.commentable.title)
        expect(page).to have_no_content(resource.title)
        expect(page).to have_css("article.card", count: 1)
      end
    end
  end
end
