# frozen_string_literal: true

require "spec_helper"

describe "Participatory process admin manages participatory process admins", type: :feature do
  include_context "participatory process admin"
  let(:user) { process_admin }

  it_behaves_like "manage process admins examples"

  context "removing himself from the list" do
    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin.edit_participatory_process_path(participatory_process)
      click_link "Process admins"
    end

    it "cannot remove himself" do
      within find("#process_admins tr", text: user.email) do
        expect(page).not_to have_content("Destroy")
      end
    end
  end
end
