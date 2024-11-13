# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory processes taxonomy filters" do
  let(:space_manifest) { "participatory_processes" }
  let(:participatory_space_collection_name) { "participatory processes" }

  include_context "with taxonomy filters context"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_participatory_processes.participatory_process_filters_path
  end

  it_behaves_like "a taxonomy filters controller"
end
