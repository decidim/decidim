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
          allow(view).to receive(:can?).and_return(true)
        end

        it "renders the default main menu" do
          expect(default_main_menu).to \
            have_selector("li", count: 8) &
            have_link("Dashboard", href: "/admin/") &
            have_link("Processes", href: "/admin/participatory_processes") &
            have_link("Process groups", href: "/admin/participatory_process_groups") &
            have_link("Assemblies", href: "/admin/assemblies") &
            have_link("Pages", href: "/admin/static_pages") &
            have_link("Users", href: "/admin/users") &
            have_link("Newsletters", href: "/admin/newsletters") &
            have_link("Settings", href: "/admin/organization/edit")
        end

        it "selects the correct default active option" do
          allow(view).to \
            receive(:params).and_return(controller: "decidim/admin/dashboard", action: "show")

          expect(default_main_menu).to have_selector(".is-active", text: "Dashboard")
        end
      end
    end
  end
end
