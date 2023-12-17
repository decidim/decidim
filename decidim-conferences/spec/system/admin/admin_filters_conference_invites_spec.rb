# frozen_string_literal: true

require "spec_helper"

describe "Admin filters invites" do
  let(:organization) { create(:organization) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let(:conference) { create(:conference, organization:) }

  let(:resource_controller) { Decidim::Conferences::Admin::ConferenceInvitesController }

  let(:name) { "Dummy Name" }
  let(:user1) { create(:user, name:, organization:) }
  let!(:invited_user1) { create(:conference_invite, :accepted, user: user1, conference:) }

  let(:email) { "dummy_email@example.org" }
  let(:user2) { create(:user, email:, organization:) }
  let!(:invited_user2) { create(:conference_invite, user: user2, conference:) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin_conferences.conference_conference_invites_path(conference_slug: conference.slug)
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
    let!(:collection) { create_list(:conference_invite, 50, conference:) }
  end
end
