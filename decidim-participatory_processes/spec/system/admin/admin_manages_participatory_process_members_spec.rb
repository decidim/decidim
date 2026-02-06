# frozen_string_literal: true

require "spec_helper"
require "decidim/admin/test/admin_members_shared_examples"

describe "Admin manages participatory process members" do
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:organization) { create(:organization) }
  let!(:participatory_space) { create(:participatory_process, organization:, has_members: true) }
  let(:participatory_space_edit_path) { decidim_admin_participatory_processes.edit_participatory_process_path(participatory_space) }

  it_behaves_like "manage admin members examples"
end
