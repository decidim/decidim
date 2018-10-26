# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe JoinRequestRejectedEvent do
    include_context "when a simple event"

    let(:user_group) { create :user_group, users: [] }
    let!(:membership) { create :user_group_membership, user_group: user_group, role: :member }
    let(:extra) { { user_group_name: user_group.name, user_group_nickname: user_group.nickname } }
    let(:event_name) { "decidim.events.groups.join_request_rejected" }
    let(:resource) { user_group }
    let(:resource_path) do
      Decidim::Core::Engine.routes.url_helpers.profile_path(nickname: resource.nickname)
    end

    it_behaves_like "a simple event", skip_space_checks: true

    describe "email_subject" do
      it "is generated correctly" do
        expect(subject.email_subject).to include("has been rejected")
      end
    end

    describe "email_intro" do
      it "is generated correctly" do
        expect(subject.email_intro).to include(resource_path)
      end
    end
  end
end
