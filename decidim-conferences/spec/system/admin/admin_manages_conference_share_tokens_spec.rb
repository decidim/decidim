# frozen_string_literal: true

require "spec_helper"

describe "Admin manages conference share tokens" do
  include_context "when admin administrating a conference"

  it_behaves_like "manage participatory space share tokens" do
    let(:participatory_space) { conference }
    let(:participatory_space_path) { decidim_admin_conferences.edit_conference_path(conference) }
  end
end
