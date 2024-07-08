# frozen_string_literal: true

require "spec_helper"

require "decidim/admin/test/invite_participatory_space_collaborators_shared_examples"

describe "Invite process collaborator" do
  let(:participatory_space) { create(:participatory_process) }
  let(:space_sidebar_label) { "Processes" }
  let(:role) { "Collaborator" }
  let(:participatory_space_user_roles_path) { decidim_admin_participatory_processes.participatory_process_user_roles_path(participatory_space) }
  let(:new_button_label) { "New process admin" }

  include_context "when inviting participatory space users"

  it_behaves_like "inviting participatory space collaborators"
end
