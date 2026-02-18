# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe MenuHelper do
      describe "main_menu" do
        let(:default_main_menu) { helper.main_menu.render }
        let(:default_main_menu_modules) { helper.main_menu_modules.render }

        let(:current_organization) { create(:organization) }

        before do
          allow(view).to receive(:current_organization).and_return(current_organization)
          allow(view).to receive(:allowed_to?).and_return(true)
        end

        it "renders the default main menu" do
          expect(default_main_menu).to \
            have_css("li", count: 8) &
            have_link("Global moderation", href: "/admin/moderations") &
            have_link("Pages", href: "/admin/static_pages") &
            have_link("Participants", href: "/admin/users") &
            have_link("Newsletters", href: "/admin/newsletters") &
            have_link("Settings", href: "/admin/organization/edit") &
            have_link("Admin activity log", href: "/admin/logs") &
            have_link("Insights", href: "/admin/statistics") &
            have_link("Templates", href: "/admin/templates/questionnaire_templates")
        end

        it "renders the modules" do
          expect(default_main_menu_modules).to \
            have_css("li", count: 4) &
            have_link("Processes", href: "/admin/participatory_processes") &
            have_link("Conferences", href: "/admin/conferences") &
            have_link("Assemblies", href: "/admin/assemblies") &
            have_link("Initiatives", href: "/admin/initiatives")
        end

        it "selects the correct default active option in Appearance" do
          allow(view).to \
            receive(:params).and_return(controller: "decidim/admin/organization_appearance", action: "show")

          expect(default_main_menu).to have_css(".is-active", text: "Settings")
        end

        it "selects the correct default active option in Participants" do
          allow(view).to \
            receive(:params).and_return(controller: "decidim/admin/users", action: "show")

          expect(default_main_menu).to have_css(".is-active", text: "Participants")
        end
      end
    end
  end
end
