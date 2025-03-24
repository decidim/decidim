# frozen_string_literal: true

require "spec_helper"

shared_examples "an uncommentable component" do
  let!(:component) do
    create(:component,
           manifest:,
           participatory_space:)
  end
  let!(:comment) { create(:comment, commentable: resources.first) }

  it "does not displays comments count" do
    component.update!(settings: { comments_enabled: false })

    visit_component

    resources.each do |resource|
      expect(page).to have_no_link(resource_locator(resource).path)
    end
  end

  describe "when search a comment in the global search" do
    it "does displays the comments" do
      visit decidim.root_path

      within ".main-bar__search" do
        fill_in "term", with: comment.body["en"]
        find("input#input-search").native.send_keys :enter
      end

      expect(page).to have_content("1 Results for the search")
    end

    it "does not displays the comment when comments are disable" do
      component.update!(settings: { comments_enabled: false })
      visit decidim.root_path

      within ".main-bar__search" do
        fill_in "term", with: comment.body["en"]
        find("input#input-search").native.send_keys :enter
      end

      expect(page).to have_content("0 Results for the search")
    end
  end
end
