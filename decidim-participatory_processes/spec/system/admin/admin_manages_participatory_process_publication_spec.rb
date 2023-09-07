# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory process publication", type: :system do
  include_context "when admin administrating a participatory process"

  let(:admin_page_path) { decidim_admin_participatory_processes.edit_participatory_process_path(participatory_space) }
  let(:public_collection_path) { decidim_participatory_processes.participatory_processes_path }
  let(:title) { "My space" }
  let!(:participatory_space) { participatory_process }

  it_behaves_like "manage participatory space publications"
end
