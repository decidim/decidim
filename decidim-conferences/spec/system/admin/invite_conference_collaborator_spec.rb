# frozen_string_literal: true

require "spec_helper"

require "decidim/admin/test/invite_participatory_space_collaborators_shared_examples"

describe "Invite conference collaborator" do
  let(:participatory_space) { create(:conference) }
  let(:participatory_space_user_roles_path) { decidim_admin_conferences.conference_user_roles_path(participatory_space) }
  let(:new_button_label) { "New conference admin" }

  include_context "when inviting participatory space users"

  let(:space_sidebar_label) { "Conferences" }
  let(:role) { "Collaborator" }

  it_behaves_like "inviting participatory space collaborators"
end
