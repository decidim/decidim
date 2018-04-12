# frozen_string_literal: true

require "spec_helper"

shared_examples "manage process attachments examples" do
  let(:attached_to) { participatory_process }
  let(:attachment_collection) { create(:attachment_collection, collection_for: participatory_process) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
    click_link "Files"
  end

  it_behaves_like "manage attachments examples"
end
