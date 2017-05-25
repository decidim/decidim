# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe MenuItemPresenter, type: :helper do
    subject { MenuItemPresenter.new(menu_item, view) }

    context "when label is a literal" do
      let(:menu_item) { MenuItem.new("Foo", "/boo") }

      it "renders the raw label" do
        expect(subject.as_link).to have_content("Foo")
      end
    end

    context "when url is a literal" do
      let(:menu_item) { MenuItem.new("Foo", "/boo") }

      it "renders raw url" do
        expect(subject.as_link).to have_link("Foo", href: "/boo")
      end
    end

    describe "when visible parameter is false" do
      let(:menu_item) { MenuItem.new("Foo", "/foos", if: false) }

      it "renders nothing" do
        expect(subject.as_link).to be_empty
      end
    end
  end
end
