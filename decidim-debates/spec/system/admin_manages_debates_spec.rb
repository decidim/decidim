# frozen_string_literal: true

require "spec_helper"

describe "Admin manages debates", type: :system do
  let(:manifest_name) { "debates" }

  let!(:reportables) { create_list(:debate, 2, component:) }
  let(:participatory_space_path) do
    decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
  end

  include_context "when managing a component as an admin"
  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component_admin
  end

  it_behaves_like "manage debates"
  it_behaves_like "manage announcements"
  it_behaves_like "export debates comments"
  it_behaves_like "manage moderations"
end
