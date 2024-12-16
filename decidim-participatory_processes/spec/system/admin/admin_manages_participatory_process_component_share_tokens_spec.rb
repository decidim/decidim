# frozen_string_literal: true

require "spec_helper"

describe "Admin manages participatory process component share tokens" do
  include_context "when admin administrating a participatory process"

  it_behaves_like "manage component share tokens" do
    let(:participatory_space) { participatory_process }
    let(:participatory_space_engine) { decidim_admin_participatory_processes }
  end
end
