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

    context "when label is a proc" do
      let(:menu_item) { MenuItem.new(-> { foo_label }, "/boo") }

      it "renders label evaluated in view context" do
        allow(view).to receive(:foo_label).and_return("A beautiful foo")

        expect(subject.as_link).to have_content("A beautiful foo")
      end
    end

    context "when url is a literal" do
      let(:menu_item) { MenuItem.new("Foo", "/boo") }

      it "renders raw url" do
        expect(subject.as_link).to have_link("Foo", href: "/boo")
      end
    end

    context "when url is a proc" do
      let(:menu_item) { MenuItem.new("Foo", -> { foo_path }) }

      it "renders url evaluated in view context" do
        allow(view).to receive(:foo_path).and_return("/path/to/foos")

        expect(subject.as_link).to have_link("Foo", href: "/path/to/foos")
      end
    end
  end
end
