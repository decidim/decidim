# frozen_string_literal: true

require "spec_helper"

describe "Explore posts", type: :system do
  include_context "with a component"
  let(:manifest_name) { "blogs" }

  let!(:old_post) { create(:post, component: component, created_at: Time.current - 2.days) }
  let!(:new_post) { create(:post, component: component, created_at: Time.current) }

  describe "index" do
    it "shows all posts for the given process" do
      visit_component
      expect(page).to have_selector("article.card", count: 2)
      expect(page).to have_selector(".card--post", text: translated(new_post.title).upcase)
      expect(page).to have_selector(".card--post", text: translated(old_post.title).upcase)
    end

    context "when paginating" do
      let(:collection_size) { 10 }
      let!(:collection) { create_list :post, collection_size, component: component }
      let!(:resource_selector) { ".card--post" }

      before do
        visit_component
      end

      it "lists 4 resources per page by default" do
        expect(page).to have_css(resource_selector, count: 4)
        expect(page).to have_css(".pagination .page", count: 3)
      end
    end
  end

  describe "show" do
    let(:posts_count) { 1 }
    let!(:post) { create(:post, component: component) }

    before do
      visit resource_locator(post).path
    end

    it "show post info" do
      expect(page).to have_i18n_content(post.title)
      expect(page).to have_i18n_content(post.body)
      expect(page).to have_content(post.author.name)
      expect(page).to have_content(post.created_at.day)
    end
  end

  describe "most commented" do
    context "when ordering by 'most_commented'" do
      let!(:post_more_comments) { create(:post, component: component) }
      let!(:post_less_comments) { create(:post, component: component) }
      let!(:more_comments) { create_list(:comment, 7, commentable: post_more_comments) }
      let!(:less_comments) { create_list(:comment, 3, commentable: post_less_comments) }

      before do
        visit_component
      end

      it "lists the posts ordered by comments count" do
        within "#most-commented" do
          expect(page).to have_content(translated(post_more_comments.title))
          expect(page).to have_content(translated(post_less_comments.title))
        end
      end
    end
  end
end
