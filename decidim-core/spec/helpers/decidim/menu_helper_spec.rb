# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe MenuHelper do
    describe "main_menu" do
      let(:default_main_menu) { helper.main_menu.render }

      it "renders the default main menu" do
        expect(default_main_menu).to \
          have_selector("li", count: 3) &
          have_link("Home", href: "/") &
          have_link("Processes", href: "/processes") &
          have_link("More information", href: "/pages")
      end

      it "selects the correct default active option" do
        allow(view).to \
          receive(:params).and_return(controller: "decidim/pages", action: "show")

        expect(default_main_menu).to \
          have_selector(".main-nav__link--active", text: "Home")
      end
    end
  end
end
