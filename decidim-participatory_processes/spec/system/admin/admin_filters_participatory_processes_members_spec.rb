# frozen_string_literal: true

require "spec_helper"

describe "Admin filters participatory processes members" do
  include_context "with filterable context"

  let(:organization) { create(:organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization:) }

  let!(:invited_user1) { create(:user, name:, organization:) }
  let!(:invited_member1) { create(:member, user: invited_user1, participatory_space: participatory_process) }
  let!(:invited_user2) { create(:user, email:, organization:) }
  let!(:invited_member2) { create(:member, user: invited_user2, participatory_space: participatory_process) }

  let(:name) { "Dummy Name" }
  let(:email) { "dummy_email@example.org" }

  let(:resource_controller) { Decidim::ParticipatoryProcesses::Admin::MembersController }

  context "when managing process with members" do
    let(:participatory_process) { create(:participatory_process, organization:, has_members: true) }

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

  context "when trying to manage members and the space does not have members" do
    let(:participatory_process) { create(:participatory_process, organization:, has_members: false) }

    before do
      invited_user1.update!(invitation_sent_at: 1.day.ago, invitation_accepted_at: Time.current)

      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin_participatory_processes.members_path(participatory_process_slug: participatory_process.slug)
    end

    it "restricts access" do
      expect(page).to have_admin_callout("You are not authorized to perform this action.")
    end
  end
end
