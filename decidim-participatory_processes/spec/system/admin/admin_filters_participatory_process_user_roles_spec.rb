# frozen_string_literal: true

require "spec_helper"

describe "Admin filters user_roles", type: :system do
  let(:organization) { create(:organization) }
  let!(:admin) { create(:user, :admin, :confirmed, organization: organization) }
  let(:participatory_process) { create(:participatory_process, organization: organization) }

  let(:resource_controller) { Decidim::Conferences::Admin::ConferenceUserRolesController }
  let(:name) { "Dummy Name" }
  let(:email) { "dummy_email@example.org" }

  let!(:invited_user1) { create(:process_valuator, name: name, participatory_process: participatory_process) }
  let!(:invited_user2) { create(:process_valuator, email: email, participatory_process: participatory_process) }

  before do
    invited_user2.update!(invitation_sent_at: 1.day.ago, invitation_accepted_at: Time.current, last_sign_in_at: Time.current)

    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin_participatory_processes.participatory_process_user_roles_path(participatory_process_slug: participatory_process.slug)
  end

  include_context "with filterable context"

  include_examples "filterable participatory space user roles"
  include_examples "searchable participatory space user roles"
  context "when sorting" do
    include_examples "sortable participatory space user roles" do
      let!(:collection) do
        create_list(:process_collaborator, 100, participatory_process: participatory_process,
                                                last_sign_in_at: 2.days.ago,
                                                invitation_accepted_at: 1.day.ago)
      end
      let!(:user) do
        create(:process_valuator,
               name: "ZZZupper user",
               email: "zzz@example.org",
               participatory_process: participatory_process,
               last_sign_in_at: 30.seconds.ago,
               invitation_accepted_at: Time.current)
      end

      before do
        visit decidim_admin_participatory_processes.participatory_process_user_roles_path(participatory_process_slug: participatory_process.slug, q: { s: sort_by })
      end
    end
  end

  it_behaves_like "paginating a collection" do
    let!(:collection) { create_list(:process_valuator, 100, participatory_process: participatory_process) }

    before do
      switch_to_host(organization.host)
      login_as admin, scope: :user
      visit decidim_admin_participatory_processes.participatory_process_user_roles_path(participatory_process_slug: participatory_process.slug)
    end
  end
end
