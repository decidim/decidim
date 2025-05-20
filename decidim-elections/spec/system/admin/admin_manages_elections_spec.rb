# frozen_string_literal: true

require "spec_helper"

describe "Admin manages elections" do
  let(:manifest_name) { "elections" }
  let(:participatory_space_path) do
    decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
  end

  include_context "when managing a component as an admin"

  it_behaves_like "manage elections"
end
