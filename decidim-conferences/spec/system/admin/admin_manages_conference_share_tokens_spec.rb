# frozen_string_literal: true

require "spec_helper"

describe "Admin manages conference share tokens" do
  include_context "when admin administrating a conference"
  let(:participatory_space) { conference }
  let(:participatory_space_path) { decidim_admin_conferences.edit_conference_path(conference) }
  let(:participatory_spaces_path) { decidim_admin_conferences.conferences_path }

  it_behaves_like "manage participatory space share tokens"

  context "when the user is a conference admin" do
    let(:user) { create(:user, :confirmed, :admin_terms_accepted, organization:) }
    let!(:role) { create(:conference_user_role, user:, conference:, role: :admin) }

    it_behaves_like "manage participatory space share tokens"
  end
end
