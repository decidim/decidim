# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe MenuItemPresenter, type: :helper do
    subject { MenuItemPresenter.new(menu_item, view) }

    let(:menu_item) { MenuItem.new("Foo", "/boo", :foo) }

    it "renders the label" do
      expect(subject.render).to have_content("Foo")
    end

    it "renders the url" do
      expect(subject.render).to have_link("Foo", href: "/boo")
    end

    it "does not add the aria-current attribute for non-active page" do
      expect(subject.render).not_to include('aria-current="page"')
    end

    context "when the link URL is active" do
      let(:request) { double }
      let(:current_path) { "/boo" }

      before do
        allow(view).to receive(:request).and_return(request)
        allow(request).to receive(:original_fullpath).and_return(current_path)
      end

      it "adds the aria-current attribute to the link" do
        expect(subject.render).to include('aria-current="page"')
      end

      context "and the page is a sub-page of the menu link" do
        let(:current_path) { "/boo/bar" }

        it "adds the aria-current attribute to the link" do
          expect(subject.render).to include('aria-current="page"')
        end
      end
    end
  end
end
