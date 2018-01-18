# frozen_string_literal: true

require "spec_helper"

describe "Process admin manages comments", type: :system do
  let(:manifest_name) { "dummy" }
  let!(:dummy) { create :dummy_resource, feature: current_feature }
  let!(:resources) { create_list(:dummy_resource, 3, feature: current_feature) }
  let!(:reportables) do
    resources.map do |resource|
      create(:comment, commentable: resource)
    end
  end
  let(:participatory_space_path) do
    decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
  end

  include_context "when managing a feature as a process admin"

  it_behaves_like "manage moderations"
end
