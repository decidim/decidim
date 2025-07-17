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

  describe "when searching a comment in the global search" do
    it "does displays the comments" do
      visit decidim.root_path

      within ".main-bar__search" do
        fill_in "term", with: comment.body["en"]
        find("input#input-search").native.send_keys :enter
      end

      expect(page).to have_content("1 results for the search")
    end

    it "does not display the comment when comments are disabled" do
      component.update!(settings: { comments_enabled: false })
      visit decidim.root_path

      within ".main-bar__search" do
        fill_in "term", with: comment.body["en"]
        find("input#input-search").native.send_keys :enter
      end

      expect(page).to have_content("0 results for the search")
    end

    context "when filtering using :with_resource_type" do
      let(:comments_enabled) { true }
      let!(:comments) { create_list(:comment, 3, commentable: resources.first, body: "Comment in #{manifest_name}, #{resources.first.title["en"]}") }
      let!(:deleted_comment) { create(:comment, :deleted, commentable: resources.first, body: "Deleted comment, #{resources.first.title["en"]}") }
      let!(:moderated_comment) { create(:comment, :moderated, commentable: resources.first, body: "Moderated comment, #{resources.first.title["en"]}") }

      before do
        component.update!(settings: { comments_enabled: })
        visit decidim.root_path

        within ".main-bar__search" do
          fill_in "term", with: resources.first.title["en"]
          find("input#input-search").native.send_keys :enter
        end
      end

      it "displays the visible comments" do
        expect(page).to have_content("4 results for the search")

        within "aside.layout-2col__aside #dropdown-menu-search" do
          click_on manifest.name.to_s.humanize
        end

        expect(page).to have_content("1 results for the search")
      end

      context "when comments are disabled" do
        let(:comments_enabled) { false }

        it "does not display any commment" do
          expect(page).to have_content("1 results for the search")

          within "aside.layout-2col__aside #dropdown-menu-search" do
            click_on manifest.name.to_s.humanize
          end

          expect(page).to have_content("1 results for the search")
        end
      end
    end
  end
end
