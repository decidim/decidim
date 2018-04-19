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

        RSpec::Matchers.define_negated_matcher :have_no_link, :have_link

        context "when all spaces are inactive" do
          it "renders the default main menu" do
            expect(default_main_menu).to \
              have_selector("li", count: 7) &
              have_link("Dashboard", href: "/admin/") &
              have_link("Pages", href: "/admin/static_pages") &
              have_link("Users", href: "/admin/users") &
              have_link("Newsletters", href: "/admin/newsletters") &
              have_link("Settings", href: "/admin/organization/edit") &
              have_link("Admin activity log", href: "/admin/logs") &
              have_link("OAuth applications", href: "/admin/oauth_applications")

            expect(default_main_menu).to \
              have_no_link("Processes", href: "/admin/participatory_processes") &
              have_no_link("Process groups", href: "/admin/participatory_process_groups") &
              have_no_link("Assemblies", href: "/admin/assemblies") &
              have_no_link("Consultations", href: "/admin/consultations")
          end
        end

        context "when all spaces are active" do
          before do
            create :participatory_space, :active, organization: current_organization, manifest_name: :participatory_processes
            create :participatory_space, :active, organization: current_organization, manifest_name: :assemblies
            create :participatory_space, :active, organization: current_organization, manifest_name: :consultations
          end

          it "renders the default main menu" do
            expect(default_main_menu).to \
              have_selector("li", count: 11) &
              have_link("Dashboard", href: "/admin/") &
              have_link("Processes", href: "/admin/participatory_processes") &
              have_link("Process groups", href: "/admin/participatory_process_groups") &
              have_link("Assemblies", href: "/admin/assemblies") &
              have_link("Consultations", href: "/admin/consultations") &
              have_link("Pages", href: "/admin/static_pages") &
              have_link("Users", href: "/admin/users") &
              have_link("Newsletters", href: "/admin/newsletters") &
              have_link("Settings", href: "/admin/organization/edit") &
              have_link("Admin activity log", href: "/admin/logs") &
              have_link("OAuth applications", href: "/admin/oauth_applications")
          end
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
