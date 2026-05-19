# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe FooterMenuPresenter, type: :helper do
    subject { FooterMenuPresenter.new(:custom_menu, view, role: false, label: "Footer") }

    after { MenuRegistry.destroy(:custom_menu) }

    before do
      MenuRegistry.register :custom_menu do |menu|
        menu.add_item :foo, "Foo", "/foo"
      end
    end

    it "renders menu items without the menuitem role" do
      expect(subject.render).to have_css("li", count: 1)
      expect(subject.render).to have_no_css("li[role='menuitem']")
    end
  end
end
