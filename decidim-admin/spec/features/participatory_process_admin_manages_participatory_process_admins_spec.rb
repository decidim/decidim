# frozen_string_literal: true

require "spec_helper"
require_relative "../shared/manage_process_admins_examples"

describe "Participatory process admin manages participatory process admins", type: :feature do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization: organization) }
  let(:participatory_process) do
    create(
      :participatory_process,
      organization: organization,
      description: { en: "Description", ca: "Descripció", es: "Descripción" },
      short_description: { en: "Short description", ca: "Descripció curta", es: "Descripción corta" }
    )
  end
  let(:process_admin) { create :user, organization: organization }
  let!(:user_role) { create :participatory_process_user_role, user: process_admin, participatory_process: participatory_process }
  let!(:current_user_role) { create :participatory_process_user_role, user: user, participatory_process: participatory_process }

  it_behaves_like "manage process admins examples"

  context "removing himself from the list" do
    before do
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_admin.participatory_process_path(participatory_process)
      click_link "Process admins"
    end

    it "cannot remove himself" do
      within find("#process_admins tr", text: user.email) do
        expect(page).not_to have_content("Destroy")
      end
    end
  end
end
