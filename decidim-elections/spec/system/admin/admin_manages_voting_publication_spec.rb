# frozen_string_literal: true

require "spec_helper"

describe "Admin manages voting publication" do
  include_context "when admin managing a voting"

  let(:admin_page_path) { decidim_admin_votings.edit_voting_path(participatory_space) }
  let(:public_collection_path) { decidim_votings.votings_path }
  let(:title) { "My space" }
  let!(:participatory_space) { voting }

  it_behaves_like "manage participatory space publications"
end
