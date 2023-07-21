# frozen_string_literal: true

require "spec_helper"

describe "Participatory process admin manages participatory processes", type: :system do
  include_context "when admin administrating a participatory process"

  let(:blocks_manifests) { [:process_hero, :main_data] }

  before do
    blocks_manifests.each do |manifest_name|
      create(:content_block, organization:, scope_name: :participatory_process_homepage, manifest_name:, scoped_resource_id: participatory_process.id)
    end
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_participatory_processes.participatory_processes_path
  end

  it_behaves_like "manage processes examples"
  it_behaves_like "manage processes announcements"

  it "cannot create a new participatory_process" do
    expect(page).not_to have_selector(".actions .new")
  end

  context "when deleting a participatory process" do
    let!(:participatory_process2) { create(:participatory_process, organization:) }

    before do
      visit decidim_admin_participatory_processes.participatory_processes_path
    end

    it "cannot delete a participatory_process" do
      within find("tr", text: translated(participatory_process2.title)) do
        expect(page).not_to have_content("Delete")
      end
    end
  end
end
