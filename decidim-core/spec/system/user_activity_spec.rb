# frozen_string_literal: true

require "spec_helper"

describe "User activity", type: :system do
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
  let(:user) { create(:user, organization: organization) }

  let!(:action_log) do
    create(:action_log, action: "create", visibility: "public-only", resource: comment, organization: organization, user: user)
  end

  let!(:action_log_2) do
    create(:action_log, action: "publish", visibility: "all", resource: resource, organization: organization, participatory_space: component.participatory_space, user: user)
  end

  let!(:hidden_action_log) do
    create(:action_log, action: "publish", visibility: "all", resource: resource2, organization: organization, participatory_space: component.participatory_space)
  end

  let(:component) do
    create(:component, :published, organization: organization)
  end

  let(:resource) do
    create(:dummy_resource, component: component, published_at: Time.current)
  end

  let(:resource2) do
    create(:dummy_resource, component: component, published_at: Time.current)
  end

  before do
    switch_to_host organization.host
  end

  describe "accessing the user activity page" do
    before do
      page.visit decidim.profile_activity_path(nickname: user.nickname)
    end

    it "displays the activities at the home page" do
      within ".user-activity" do
        expect(page).to have_css("article.card", count: 2)

        expect(page).to have_content(resource.title)
        expect(page).to have_content(comment.commentable.title)
        expect(page).to have_no_content(resource2.title)
      end
    end
  end
end
