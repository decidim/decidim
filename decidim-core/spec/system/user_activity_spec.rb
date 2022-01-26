# frozen_string_literal: true

require "spec_helper"

describe "User activity", type: :system do
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

  let(:resource_types) do
    %w(Collaborative\ Draft Comment Debate Initiative Meeting Post Proposal Question)
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

    switch_to_host organization.host
  end

  describe "accessing the user activity page" do
    before do
      page.visit decidim.profile_activity_path(nickname: user.nickname)
    end

    it "displays the activities at the home page" do
      within ".user-activity" do
        expect(page).to have_css(".card--activity", count: 2)

        expect(page).to have_content(translated(resource.title))
        expect(page).to have_content(translated(comment.commentable.title))
        expect(page).to have_no_content(translated(resource2.title))
      end
    end

    it "displays activities filter with the correct options" do
      expect(page).to have_select(
        "filter[resource_type]",
        selected: "All types",
        options: resource_types.push("All types")
      )
    end

    context "when accessing a non existing profile" do
      before do
        allow(page.config).to receive(:raise_server_errors).and_return(false)
        visit decidim.profile_activity_path(nickname: "invalid_nickname")
      end

      it "displays an error message" do
        expect(page).to have_text("Puma caught this error: Missing user: invalid_nickname")
      end
    end
  end
end
