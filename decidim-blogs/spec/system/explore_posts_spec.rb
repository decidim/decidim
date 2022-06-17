# frozen_string_literal: true

require "spec_helper"

describe "Explore posts", type: :system do
  include_context "with a component"
  let(:manifest_name) { "blogs" }

  let!(:old_post) { create(:post, component:, created_at: 2.days.ago) }
  let!(:new_post) { create(:post, component:, created_at: Time.current) }

  let!(:image) { create(:attachment, attached_to: old_post) }

  describe "index" do
    it "shows all posts for the given process" do
      visit_component
      expect(page).to have_selector(".card", count: 2)
      expect(page).to have_selector(".card--post", text: translated(new_post.title))
      expect(page).to have_selector(".card--post", text: translated(old_post.title))
    end

    it "shows comment counts" do
      visit_component
      expect(page).to have_selector('a[title="comments"]', text: "comment".pluralize(new_post.comments.count))
      expect(page).to have_selector('a[title="comments"]', text: "comment".pluralize(old_post.comments.count))
    end

    it "shows endorsement counts" do
      visit_component
      expect(page).to have_selector('a[title="endorsements"]', text: "endorsement".pluralize(new_post.endorsements.count))
      expect(page).to have_selector('a[title="endorsements"]', text: "endorsement".pluralize(old_post.endorsements.count))
    end

    it "shows images" do
      visit_component
      expect(page).to have_selector(".card--post img.card__image")
    end

    context "when paginating" do
      let(:collection_size) { 10 }
      let!(:collection) { create_list :post, collection_size, component: }
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
    let(:author) { organization }
    let!(:post) { create(:post, component:, author:) }

    before do
      visit resource_locator(post).path
    end

    context "when author is an organization" do
      it "shows 'Official' as the author" do
        within ".author__name" do
          expect(page).to have_content("Official")
        end
      end
    end

    context "when author is a user_group" do
      let(:author) { create(:user_group, :verified, organization:) }

      it "shows user group as the author" do
        within ".author__name" do
          expect(page).to have_content(author.name)
        end
      end
    end

    context "when author is a user" do
      let(:author) { user }

      it "shows user as the author" do
        within ".author__name" do
          expect(page).to have_content(user.name)
        end
      end
    end

    it "show post info" do
      expect(page).to have_i18n_content(post.title)
      expect(page).to have_i18n_content(post.body)
      expect(page).to have_content(post.author.name)
      expect(page).to have_content(post.created_at.strftime("%d/%m/%Y %H:%M "))
    end

    it "shows the back button" do
      expect(page).to have_link(href: "#{main_component_path(component)}posts")
    end

    context "when clicking the back button" do
      before do
        click_link(href: "#{main_component_path(component)}posts")
      end

      it "redirect the user to component index" do
        expect(page).to have_current_path("#{main_component_path(component)}posts")
      end
    end
  end

  describe "most commented" do
    context "when ordering by 'most_commented'" do
      let!(:post_more_comments) { create(:post, component:) }
      let!(:post_less_comments) { create(:post, component:) }
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
