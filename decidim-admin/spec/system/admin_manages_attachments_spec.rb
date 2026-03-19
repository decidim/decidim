# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe "Admin manages attachments" do
    let(:organization) { create(:organization) }
    let!(:participatory_process) { create(:participatory_process, organization:) }
    let!(:admin) { create(:user, :admin, :confirmed, organization:) }
    let!(:attachment) { create(:attachment, attached_to: participatory_process) }

    before do
      switch_to_host(organization.host)
      login_as admin, scope: :user
      visit decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
    end

    context "when managing attachments" do
      it "will persist picture when error is present" do
        within_admin_sidebar_menu do
          click_on "Attachments"
        end

        within "#attachments" do
          click_on "New attachment"
        end

        within ".new_attachment" do
          fill_in_i18n(
            :attachment_title,
            "#attachment-title-tabs",
            en: "",
            es: "",
            ca: ""
          )
        end

        within ".new_attachment" do
          find_by_id("trigger-file").click
        end

        dynamically_attach_file(:attachment_file, Decidim::Dev.asset("city.jpeg"))

        within ".new_attachment" do
          find("*[type=submit]").click
        end

        within ".new_attachment" do
          find("*[type=submit]").click
        end

        expect(page).to have_css("img[src*='city.jpeg']")
      end
    end
  end
end
