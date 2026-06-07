# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe MenuHelper do
      include Decidim::Core::Engine.routes.url_helpers
      include Decidim::Templates::AdminEngine.routes.url_helpers

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
            have_link("Global moderation", href: decidim_admin.moderations_path) &
            have_link("Pages", href: decidim_admin.static_pages_path) &
            have_link("Participants", href: decidim_admin.users_path) &
            have_link("Newsletters", href: decidim_admin.newsletters_path) &
            have_link("Settings", href: decidim_admin.edit_organization_path) &
            have_link("Admin activity log", href: decidim_admin.logs_path) &
            have_link("Insights", href: decidim_admin.statistics_path) &
            have_link("Templates", href: decidim_admin_templates.questionnaire_templates_path)
        end

        it "renders the modules" do
          expect(default_main_menu_modules).to \
            have_css("li", count: 4) &
            have_link("Processes", href: decidim_admin_participatory_processes.participatory_processes_path) &
            have_link("Conferences", href: decidim_admin_conferences.conferences_path) &
            have_link("Assemblies", href: decidim_admin_assemblies.assemblies_path) &
            have_link("Initiatives", href: decidim_admin_initiatives.initiatives_path)
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
