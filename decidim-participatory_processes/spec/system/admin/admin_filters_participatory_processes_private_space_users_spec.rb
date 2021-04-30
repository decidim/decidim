# frozen_string_literal: true

require "spec_helper"

describe "Admin filters participatory processes private space users", type: :system do
  include_context "with filterable context"

  let(:organization) { create(:organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization: organization) }
  let(:participatory_process) { create(:participatory_process, organization: organization) }

  let!(:invited_user_1) { create(:user, name: name, organization: organization) }
  let!(:invited_private_user_1) { create :participatory_space_private_user, user: invited_user_1, privatable_to: participatory_process }
  let!(:invited_user_2) { create(:user, email: email, organization: organization) }
  let!(:invited_private_user_2) { create :participatory_space_private_user, user: invited_user_2, privatable_to: participatory_process }

  let(:name) { "Dummy Name" }
  let(:email) { "dummy_email@example.org" }

  let(:resource_controller) { Decidim::ParticipatoryProcesses::Admin::ParticipatorySpacePrivateUsersController }

  before do
    invited_user_1.update!(invitation_sent_at: Time.current - 1.day, invitation_accepted_at: Time.current)

    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
    find("a[href*='participatory_space_private_users']").click
  end

  include_examples "filterable participatory space users"
  include_examples "searchable participatory space users"
end
