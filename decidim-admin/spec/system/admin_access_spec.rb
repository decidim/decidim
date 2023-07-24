# frozen_string_literal: true

require "spec_helper"

describe "AdminAccess", type: :system do
  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization:, title: { en: "My process" }) }
  let(:other_participatory_process) { create(:participatory_process, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  shared_examples "showing the page" do
    it "shows the page" do
      expect(page).to have_content("View public page")
      expect(page).to have_content("My process")
    end
  end

  shared_examples "showing the unauthorized error message" do
    it "redirects to the relevant unauthorized page" do
      expect(page).to have_content("You are not authorized to perform this action")
      expect(page).to have_current_path("/admin/")
    end
  end

  context "when the user is a process admin" do
    let(:user) { create(:process_admin, :confirmed, organization:, participatory_process:) }

    context "and has permission" do
      before do
        visit decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
      end

      it_behaves_like "showing the page"
    end

    context "and does not have permission" do
      before do
        visit decidim_admin_participatory_processes.edit_participatory_process_path(other_participatory_process)
      end

      it_behaves_like "showing the unauthorized error message"
    end
  end

  context "when the user is a valuator" do
    let(:user) { create(:process_valuator, :confirmed, participatory_process:) }

    context "and has permission" do
      before do
        visit decidim_admin_participatory_processes.components_path(participatory_process)
      end

      it_behaves_like "showing the page"
    end

    context "and does not have permission" do
      before do
        visit decidim_admin_participatory_processes.components_path(other_participatory_process)
      end

      it_behaves_like "showing the unauthorized error message"
    end
  end
end
