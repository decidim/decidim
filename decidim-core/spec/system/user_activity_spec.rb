# frozen_string_literal: true

require "spec_helper"

describe "User activity" do
  let(:organization) { create(:organization) }
  let(:comment) { create(:comment, commentable: resource) }
  let(:user) { create(:user, :confirmed, organization:) }

  let!(:action_log) do
    create(:action_log, action: "create", visibility: "public-only", resource: comment, organization:, user:)
  end

  let!(:action_log2) do
    create(:action_log, action: "publish", visibility: "all", resource:, organization:, participatory_space: component.participatory_space, user:)
  end

  let!(:hidden_action_log) do
    create(:action_log, action: "publish", visibility: "all", resource: resource2, organization:, participatory_space: component.participatory_space)
  end

  let!(:private_action_log) do
    create(:action_log, action: "update", visibility: "private-only", resource: resource3, organization:, participatory_space: component.participatory_space, user:)
  end

  let(:component) do
    create(:component, :published, organization:)
  end

  let(:resource) do
    create(:dummy_resource, component:, published_at: Time.current)
  end

  let(:resource2) do
    create(:dummy_resource, component:, published_at: Time.current)
  end

  let!(:resource3) do
    create(:coauthorable_dummy_resource, component:)
  end

  let(:resource_types) do
    ["Collaborative draft", "Comment", "Debate", "Initiative", "Meeting", "Post", "Proposal"]
  end

  before do
    allow(Decidim::ActionLog).to receive(:public_resource_types).and_return(
      %w(
        Decidim::Comments::Comment
        Decidim::Dev::DummyResource
      )
    )
    allow(Decidim::ActionLog).to receive(:private_resource_types).and_return(
      %w(Decidim::Dev::CoauthorableDummyResource)
    )
    allow(Decidim::ActionLog).to receive(:publicable_public_resource_types).and_return(
      %w(Decidim::Dev::DummyResource)
    )

    switch_to_host organization.host
  end

  context "when signed in" do
    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
    end

    describe "accessing user's own activity page" do
      it "displays the private-only action also" do
        # rubocop:disable RSpec/AnyInstance
        # Because CoauthorableDummyResource does not have path.
        allow_any_instance_of(Decidim::ActivityCell).to receive(:resource_link_path).and_return("/example/path")
        # rubocop:enable RSpec/AnyInstance

        page.visit decidim.profile_activity_path(nickname: user.nickname)
        within "#activities-container" do
          expect(page).to have_css("[data-activity]", count: 3)

          expect(page).to have_content(translated(resource.title))
          expect(page).to have_content(translated(comment.commentable.title))
          expect(page).to have_content(translated(resource3.title))
          expect(page).to have_no_content(translated(resource2.title))
        end
      end
    end
  end

  describe "accessing the user activity page" do
    before do
      page.visit decidim.profile_activity_path(nickname: user.nickname)
    end

    it "displays the activities at the home page" do
      within "#activities-container" do
        expect(page).to have_css("[data-activity]", count: 2)

        expect(page).to have_content(translated(resource.title))
        expect(page).to have_content(translated(comment.commentable.title))
        expect(page).to have_no_content(translated(resource2.title))
        expect(page).to have_no_content(translated(resource3.title))
      end
    end

    it "displays activities filter with the correct options" do
      within("#dropdown-menu-resource") do
        resource_types.push("All activity types").each do |type|
          expect(page).to have_link(type)
        end
      end
    end

    it "displays activities filter with the All types option checked by default" do
      within("#dropdown-menu-resource") do
        expect(page).to have_link("All activity types", class: "filter is-active")
      end
    end

    context "when accessing a nonexistent profile" do
      before do
        allow(page.config).to receive(:raise_server_errors).and_return(false)
        visit decidim.profile_activity_path(nickname: "invalid_nickname")
      end

      it "displays an error message" do
        expect(page).to have_text("Routing Error\nMissing user: invalid_nickname")
      end
    end
  end
end
