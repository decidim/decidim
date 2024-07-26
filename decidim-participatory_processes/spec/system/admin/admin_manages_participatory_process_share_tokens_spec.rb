# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory process share tokens" do
  include_context "when admin administrating a participatory process"

  it_behaves_like "manage participatory space share tokens" do
    let(:participatory_space) { participatory_process }
    let(:participatory_space_path) { decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process) }
  end
end
