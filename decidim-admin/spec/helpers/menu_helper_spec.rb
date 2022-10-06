# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe MenuHelper do
      describe "main_menu" do
        let(:default_main_menu) { helper.main_menu.render }

        let(:current_organization) { create(:organization) }

        before do
          allow(view).to receive(:current_organization).and_return(current_organization)
          allow(view).to receive(:allowed_to?).and_return(true)
          allow(view).to receive(:redesign_enabled?).and_return(false)
        end

        it "renders the default main menu" do
          expect(default_main_menu).to \
            have_selector("li", count: 14) &
            have_link("Dashboard", href: "/admin/") &
            have_link("Processes", href: "/admin/participatory_processes") &
            have_link("Conferences", href: "/admin/conferences") &
            have_link("Assemblies", href: "/admin/assemblies") &
            have_link("Votings", href: "/admin/votings") &
            have_link("Consultations", href: "/admin/consultations") &
            have_link("Initiatives", href: "/admin/initiatives") &
            have_link("Global moderation", href: "/admin/moderations") &
            have_link("Pages", href: "/admin/static_pages") &
            have_link("Participants", href: "/admin/users") &
            have_link("Newsletters", href: "/admin/newsletters") &
            have_link("Settings", href: "/admin/organization/edit") &
            have_link("Admin activity log", href: "/admin/logs") &
            have_link("Templates", href: "/admin/templates/questionnaire_templates")
        end

        it "selects the correct default active option in Dashboard" do
          allow(view).to \
            receive(:params).and_return(controller: "decidim/admin/dashboard", action: "show")

          expect(default_main_menu).to have_selector(".is-active", text: "Dashboard")
        end

        it "selects the correct default active option in Appearance" do
          allow(view).to \
            receive(:params).and_return(controller: "decidim/admin/organization_appearance", action: "show")

          expect(default_main_menu).to have_selector(".is-active", text: "Settings")
        end

        it "selects the correct default active option in Participants" do
          allow(view).to \
            receive(:params).and_return(controller: "decidim/admin/users", action: "show")

          expect(default_main_menu).to have_selector(".is-active", text: "Participants")
        end
      end
    end
  end
end
