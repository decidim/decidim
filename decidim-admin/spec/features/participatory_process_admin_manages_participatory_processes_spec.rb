# frozen_string_literal: true

require "spec_helper"
require_relative "../shared/participatory_admin_shared_context"
require_relative "../shared/manage_processes_examples"

describe "Participatory process admin manages participatory processes", type: :feature do
  include_context "participatory process admin"
  let(:user) { process_admin }
  it_behaves_like "manage processes examples"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.participatory_processes_path
  end

  it "cannot create a new participatory_process" do
    expect(page).not_to have_selector(".actions .new")
  end

  context "deleting a participatory process" do
    let!(:participatory_process2) { create(:participatory_process, organization: organization) }
    let!(:process_user_role2) { create :participatory_process_user_role, user: user, participatory_process: participatory_process2 }

    before do
      visit decidim_admin.participatory_processes_path
    end

    it "cannot delete a participatory_process" do
      within find("tr", text: translated(participatory_process2.title)) do
        expect(page).not_to have_content("Destroy")
      end
    end
  end
end
