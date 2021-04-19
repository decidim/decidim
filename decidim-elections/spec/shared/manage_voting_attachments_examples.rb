# frozen_string_literal: true

require "spec_helper"

shared_examples "manage voting attachments examples" do
  let(:attached_to) { voting }
  let(:attachment_collection) { create(:attachment_collection, collection_for: voting) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_votings.edit_voting_path(voting)
    click_link "Files"
  end

  it_behaves_like "manage attachments examples"
end
