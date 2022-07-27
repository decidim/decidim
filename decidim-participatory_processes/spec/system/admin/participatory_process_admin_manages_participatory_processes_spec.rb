# frozen_string_literal: true

require "spec_helper"

describe "Participatory process admin manages participatory processes", type: :system do
  include_context "when admin administrating a participatory process"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_participatory_processes.participatory_processes_path
  end

  it_behaves_like "manage processes examples"
  it_behaves_like "manage processes announcements"

  it "cannot create a new participatory_process" do
    expect(page).to have_no_selector(".actions .new")
  end

  context "when deleting a participatory process" do
    let!(:participatory_process2) { create(:participatory_process, organization:) }

    before do
      visit decidim_admin_participatory_processes.participatory_processes_path
    end

    it "cannot delete a participatory_process" do
      within find("tr", text: translated(participatory_process2.title)) do
        expect(page).to have_no_content("Delete")
      end
    end
  end
end
