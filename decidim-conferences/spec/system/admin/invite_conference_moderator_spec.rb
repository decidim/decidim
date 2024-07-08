# frozen_string_literal: true

require "spec_helper"

require "decidim/admin/test/invite_participatory_space_moderators_shared_examples"

describe "Invite conference moderator" do
  let(:participatory_space) { create(:conference) }
  let(:space_sidebar_label) { "Conferences" }
  let(:participatory_space_user_roles_path) { decidim_admin_conferences.conference_user_roles_path(participatory_space) }
  let(:new_button_label) { "New conference admin" }

  include_context "when inviting participatory space users"

  it_behaves_like "inviting participatory space moderators"
end
