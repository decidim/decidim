# frozen_string_literal: true

require "spec_helper"

describe "User timeline", type: :system do
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
  let(:user2) { create(:user, organization: organization) }

  let(:component) do
    create(:component, :published, organization: organization)
  end

  let(:component2) do
    create(:component, :published, organization: organization)
  end

  let(:component3) do
    create(:component, :published, organization: organization)
  end

  let(:resource) do
    create(:dummy_resource, component: component, published_at: Time.current)
  end

  let(:resource2) do
    create(:dummy_resource, component: component2, published_at: Time.current)
  end

  let(:resource3) do
    create(:dummy_resource, component: component3, published_at: Time.current)
  end

  let!(:action_log) do
    create(:action_log, action: "create", visibility: "public-only", resource: comment, organization: organization, user: user2)
  end

  let!(:action_log_2) do
    create(:action_log, action: "publish", visibility: "all", resource: resource, organization: organization, participatory_space: component.participatory_space)
  end

  let!(:action_log_3) do
    create(:action_log, action: "publish", visibility: "all", resource: resource2, organization: organization)
  end

  let!(:hidden_action_log) do
    create(:action_log, action: "publish", visibility: "all", resource: resource3, organization: organization)
  end

  before do
    Decidim::Follow.create!(user: user, followable: user2)
    Decidim::Follow.create!(user: user, followable: action_log_2.participatory_space)
    Decidim::Follow.create!(user: user, followable: resource2)
    login_as user, scope: :user
    switch_to_host organization.host
  end

  describe "accessing the user timeline page" do
    before do
      page.visit decidim.profile_timeline_path(nickname: user.nickname)
    end

    it "displays activities from followed users" do
      expect(page).to have_content(comment.commentable.title)
    end

    it "displays activities from followed spaces" do
      expect(page).to have_content(resource.title)
    end

    it "displays activities from followed resources" do
      expect(page).to have_content(resource2.title)
    end

    it "doesn't show irrelevant resources" do
      expect(page).to have_no_content(resource3.title)
    end
  end
end
