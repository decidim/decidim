# frozen_string_literal: true

shared_context "when admin manages proposals" do
  let(:manifest_name) { "proposals" }
  let!(:proposal) { create :proposal, component: current_component, skip_injection: true }
  let!(:reportables) { create_list(:proposal, 3, component: current_component, skip_injection: true) }
  let(:participatory_space_path) do
    decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
  end

  include_context "when managing a component as an admin"
end
