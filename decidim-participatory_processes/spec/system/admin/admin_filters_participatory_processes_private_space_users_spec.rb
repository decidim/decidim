# frozen_string_literal: true

require "spec_helper"

describe "Admin filters participatory processes private space users" do
  include_context "with filterable context"

  let(:organization) { create(:organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization:) }

  let!(:invited_user1) { create(:user, name:, organization:) }
  let!(:invited_private_user1) { create(:participatory_space_private_user, user: invited_user1, privatable_to: participatory_process) }
  let!(:invited_user2) { create(:user, email:, organization:) }
  let!(:invited_private_user2) { create(:participatory_space_private_user, user: invited_user2, privatable_to: participatory_process) }

  let(:name) { "Dummy Name" }
  let(:email) { "dummy_email@example.org" }

  let(:resource_controller) { Decidim::ParticipatoryProcesses::Admin::ParticipatorySpacePrivateUsersController }

  context "when managing private process" do
    let(:participatory_process) { create(:participatory_process, organization:, private_space: true) }

    before do
      invited_user1.update!(invitation_sent_at: 1.day.ago, invitation_accepted_at: Time.current)

      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
      within_admin_sidebar_menu do
        click_on "Members"
      end
    end

    include_examples "filterable participatory space users"
    include_examples "searchable participatory space users"
  end

  context "when managing private users in a public process" do
    let(:participatory_process) { create(:participatory_process, organization:, private_space: false) }

    before do
      invited_user1.update!(invitation_sent_at: 1.day.ago, invitation_accepted_at: Time.current)

      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_participatory_processes.participatory_space_private_users_path(participatory_process_slug: participatory_process.slug)
    end

    it "restricts access" do
      expect(page).to have_admin_callout("You are not authorized to perform this action.")
    end
  end
end
