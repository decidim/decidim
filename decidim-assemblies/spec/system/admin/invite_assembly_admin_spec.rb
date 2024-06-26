# frozen_string_literal: true

require "spec_helper"

require "decidim/admin/test/invite_participatory_space_admins_shared_examples"

describe "Invite assembly administrator" do
  let(:participatory_space) { create(:assembly) }
  let(:private_participatory_space) { create(:assembly, private_space: true) }
  let(:about_this_space_label) { "About this assembly" }
  let(:space_admins_label) { "Assembly admins" }
  let(:space_sidebar_label) { "Assemblies" }
  let(:role) { "Administrator" }
  let(:participatory_space_user_roles_path) { decidim_admin_assemblies.assembly_user_roles_path(participatory_space) }
  let(:new_button_label) { "New assembly admin" }

  include_context "when inviting participatory space users"

  it_behaves_like "inviting participatory space admins"
end
