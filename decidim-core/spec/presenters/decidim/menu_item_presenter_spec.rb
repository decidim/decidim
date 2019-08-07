# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe MenuItemPresenter, type: :helper do
    subject { MenuItemPresenter.new(menu_item, view) }

    let(:menu_item) { MenuItem.new("Foo", "/boo") }

    it "renders the label" do
      expect(subject.render).to have_content("Foo")
    end

    it "renders the url" do
      expect(subject.render).to have_link("Foo", href: "/boo")
    end
  end
end
