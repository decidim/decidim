# frozen_string_literal: true

require "spec_helper"

require "decidim/admin/test/invite_participatory_space_admins_shared_examples"

describe "Invite conference administrator" do
  let(:participatory_space) { create(:conference) }
  let(:about_this_space_label) { "About this conference" }
  let(:space_admins_label) { "Conference admins" }
  let(:space_sidebar_label) { "Conferences" }
  let(:role) { "Administrator" }
  let(:participatory_space_user_roles_path) { decidim_admin_conferences.conference_user_roles_path(participatory_space) }
  let(:new_button_label) { "New conference admin" }

  include_context "when inviting participatory space users"

  it_behaves_like "inviting participatory space admins", check_private_space: false, check_landing_page: false
end
