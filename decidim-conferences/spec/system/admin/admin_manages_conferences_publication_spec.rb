# frozen_string_literal: true

require "spec_helper"

describe "Admin manages conference publication" do
  include_context "when admin administrating a conference"

  let(:admin_page_path) { decidim_admin_conferences.edit_conference_path(participatory_space) }
  let(:public_collection_path) { decidim_conferences.conferences_path }
  let(:title) { "My space" }
  let!(:participatory_space) { conference }

  it_behaves_like "manage participatory space publications"
end
