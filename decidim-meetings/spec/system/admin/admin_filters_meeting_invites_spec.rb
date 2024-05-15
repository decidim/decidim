# frozen_string_literal: true

require "spec_helper"

describe "Admin filters invites" do
  let(:meeting) { create(:meeting) }
  let(:organization) { meeting.component.organization }
  let(:admin) { create(:user, :admin, :confirmed, organization:) }

  let(:resource_controller) { Decidim::Meetings::Admin::InvitesController }

  let(:name) { "Dummy Name" }
  let(:user1) { create(:user, name:, organization:) }
  let!(:invited_user1) { create(:invite, :accepted, user: user1, meeting:) }

  let(:email) { "dummy_email@example.org" }
  let(:user2) { create(:user, email:, organization:) }
  let!(:invited_user2) { create(:invite, user: user2, meeting:) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit Decidim::EngineRouter.admin_proxy(meeting.component).meeting_registrations_invites_path(meeting)
  end

  include_context "with filterable context"

  context "when filtering by accepted" do
    context "when filtering Accepted" do
      it_behaves_like "a filtered collection", options: "Accepted", filter: "Accepted" do
        let(:in_filter) { user1.name }
        let(:not_in_filter) { user2.name }
      end
    end

    context "when filtering: Not accepted" do
      it_behaves_like "a filtered collection", options: "Accepted", filter: "Not accepted" do
        let(:in_filter) { user2.name }
        let(:not_in_filter) { user1.name }
      end
    end
  end

  it_behaves_like "paginating a collection" do
    let!(:collection) { create_list(:invite, 50, meeting:) }
  end
end
