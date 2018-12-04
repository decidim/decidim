# frozen_string_literal: true

require "spec_helper"

describe "Participatory process admin manages participatory processes", type: :system do
  include_context "when admin administrating a participatory process"

  it_behaves_like "manage processes examples"
  it_behaves_like "manage processes announcements"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_participatory_processes.participatory_processes_path
  end

  context "when there is more than 15 process" do
    let!(:participatory_process) do
      create_list(:participatory_process, 16, organization: organization)
    end

    it "displays pagination" do
      expect(page).to have_css(".pagination")
    end

    it "displays 15 elements" do
      within "tbody" do
        expect(page).to have_selector("tr", count: 15)
      end
    end
  end

  it "cannot create a new participatory_process" do
    expect(page).to have_no_selector(".actions .new")
  end

  context "when deleting a participatory process" do
    let!(:participatory_process2) { create(:participatory_process, organization: organization) }

    before do
      visit decidim_admin_participatory_processes.participatory_processes_path
    end

    it "cannot delete a participatory_process" do
      within find("tr", text: translated(participatory_process2.title)) do
        expect(page).to have_no_content("Destroy")
      end
    end
  end
end
