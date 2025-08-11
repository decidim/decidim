# frozen_string_literal: true

require "spec_helper"

describe Decidim::System::MenuHelper do
  describe "main_menu" do
    let(:default_main_menu) { helper.main_menu.render }

    it "renders the default main menu" do
      expect(default_main_menu).to \
        have_css("li", count: 5) &
        have_link("Dashboard", href: "/system/") &
        have_link("API credentials", href: "/system/api_users") &
        have_link("Organizations", href: "/system/organizations") &
        have_link("Admins", href: "/system/admins") &
        have_link("OAuth applications", href: "/system/oauth_applications")
    end

    it "selects the correct default active option" do
      allow(view).to \
        receive(:params).and_return(controller: "decidim/system/dashboard", action: "show")

      expect(default_main_menu).to have_css(".active", text: "Dashboard")
    end
  end
end
