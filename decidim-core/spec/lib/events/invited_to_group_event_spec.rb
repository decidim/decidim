# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe InvitedToGroupEvent do
    include_context "when a simple event"

    let(:user_group) { create :user_group, users: [] }
    let!(:membership) { create :user_group_membership, user:, user_group:, role: :member }
    let(:extra) { { user_group_name: user_group.name, user_group_nickname: user_group.nickname } }
    let(:event_name) { "decidim.events.groups.invited_to_group" }
    let(:resource) { user_group }
    let(:resource_path) do
      Decidim::Core::Engine.routes.url_helpers.profile_path(resource.nickname)
    end
    let(:groups_tab_path) do
      Decidim::Core::Engine.routes.url_helpers.profile_groups_path(user.nickname)
    end

    it_behaves_like "a simple event", skip_space_checks: true

    describe "email_subject" do
      it "is generated correctly" do
        expect(subject.email_subject).to include("You have been invited")
      end
    end

    describe "email_intro" do
      it "is generated correctly" do
        expect(subject.email_intro).to include(resource_path)
      end
    end

    describe "notification_title" do
      it "is generated correctly" do
        expect(subject.notification_title).to include(groups_tab_path)
      end
    end
  end
end
