# frozen_string_literal: true

require "spec_helper"

describe "Admin filters user_roles" do
  let(:organization) { create(:organization) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }
  let(:conference) { create(:conference, organization:) }

  let(:resource_controller) { Decidim::Conferences::Admin::ConferenceUserRolesController }
  let(:name) { "Dummy Name" }
  let(:email) { "dummy_email@example.org" }

  let!(:invited_user1) { create(:conference_evaluator, name:, conference:) }
  let!(:invited_user2) { create(:conference_evaluator, email:, conference:) }

  before do
    invited_user2.update!(invitation_sent_at: 1.day.ago, invitation_accepted_at: Time.current, last_sign_in_at: Time.current)

    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin_conferences.conference_user_roles_path(conference_slug: conference.slug)
  end

  include_context "with filterable context"

  include_examples "filterable participatory space user roles"
  include_examples "searchable participatory space user roles"
  context "when sorting" do
    include_examples "sortable participatory space user roles" do
      let!(:collection) do
        create_list(:conference_collaborator, 100, conference:,
                                                   last_sign_in_at: 2.days.ago,
                                                   invitation_accepted_at: 1.day.ago)
      end
      let!(:user) do
        create(:conference_evaluator,
               name: "ZZZupper user",
               conference:,
               last_sign_in_at: 30.seconds.ago,
               invitation_accepted_at: Time.current)
      end

      before do
        visit decidim_admin_conferences.conference_user_roles_path(conference_slug: conference.slug, q: { s: sort_by })
      end
    end
  end

  it_behaves_like "paginating a collection" do
    let!(:collection) { create_list(:conference_evaluator, 100, conference:) }

    before do
      switch_to_host(organization.host)
      login_as admin, scope: :user
      visit decidim_admin_conferences.conference_user_roles_path(conference_slug: conference.slug)
    end
  end
end
