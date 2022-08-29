# frozen_string_literal: true

require "spec_helper"

describe "User timeline", type: :system do
  let(:organization) { create(:organization) }
  let(:comment) { create(:comment) }
  let(:user) { create(:user, :confirmed, organization:) }
  let(:user2) { create(:user, organization:) }

  let(:component) do
    create(:component, :published, organization:)
  end

  let(:component2) do
    create(:component, :published, organization:)
  end

  let(:component3) do
    create(:component, :published, organization:)
  end

  let(:resource) do
    create(:dummy_resource, component:, published_at: Time.current)
  end

  let(:resource2) do
    create(:dummy_resource, component: component2, published_at: Time.current)
  end

  let(:resource3) do
    create(:dummy_resource, component: component3, published_at: Time.current)
  end

  let!(:action_log) do
    create(:action_log, action: "create", visibility: "public-only", resource: comment, organization:, user: user2)
  end

  let!(:action_log2) do
    create(:action_log, action: "publish", visibility: "all", resource:, organization:, participatory_space: component.participatory_space)
  end

  let!(:action_log3) do
    create(:action_log, action: "publish", visibility: "all", resource: resource2, organization:)
  end

  let!(:hidden_action_log) do
    create(:action_log, action: "publish", visibility: "all", resource: resource3, organization:)
  end

  let(:resource_types) do
    ["Collaborative Draft", "Comment", "Debate", "Initiative", "Meeting", "Post", "Proposal", "Question"]
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

    Decidim::Follow.create!(user:, followable: user2)
    Decidim::Follow.create!(user:, followable: action_log2.participatory_space)
    Decidim::Follow.create!(user:, followable: resource2)
    login_as user, scope: :user
    switch_to_host organization.host
  end

  describe "accessing the user timeline page" do
    before do
      page.visit decidim.profile_timeline_path(nickname: user.nickname)
    end

    it "displays activities from followed users" do
      expect(page).to have_content(translated(comment.commentable.title))
    end

    it "displays activities from followed spaces" do
      expect(page).to have_content(translated(resource.title))
    end

    it "displays activities from followed resources" do
      expect(page).to have_content(translated(resource2.title))
    end

    it "doesn't show irrelevant resources" do
      expect(page).to have_no_content(translated(resource3.title))
    end

    it "displays activities filter with the correct options" do
      expect(page).to have_select(
        "filter[resource_type]",
        selected: "All types",
        options: resource_types.push("All types")
      )
    end
  end
end
