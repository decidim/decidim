# frozen_string_literal: true

require "spec_helper"

require "decidim/admin/test/invite_participatory_space_moderators_shared_examples"

describe "Invite process moderator" do
  let(:participatory_space) { create(:participatory_process) }
  let(:participatory_space_user_roles_path) { decidim_admin_participatory_processes.participatory_process_user_roles_path(participatory_space) }
  let(:new_button_label) { "New process admin" }

  include_context "when inviting participatory space users"

  let(:space_sidebar_label) { "Processes" }

  it_behaves_like "inviting participatory space moderators"
end
