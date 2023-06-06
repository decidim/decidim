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
      expect(page).to have_selector("div[data-post]", count: 2)
      expect(page).to have_selector("div[data-post]", text: translated(new_post.title))
      expect(page).to have_selector("div[data-post]", text: translated(old_post.title))
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
      expect(page).to have_selector("div[data-post] img")
    end

    context "when paginating" do
      let(:collection_size) { 15 }
      let!(:collection) { create_list(:post, collection_size, component:) }
      let!(:resource_selector) { "div[data-post]" }

      before do
        visit_component
      end

      it "lists 10 resources per page by default" do
        expect(page).to have_css(resource_selector, count: 10)
        expect(page).to have_css("[data-pages] [data-page]", count: 2)
      end
    end

    context "with some unpublished posts" do
      let!(:unpublished) { create(:post, component:, published_at: 2.days.from_now) }
      let!(:resource_selector) { "div[data-post]" }

      before { visit_component }

      it "shows only published blogs" do
        expect(Decidim::Blogs::Post.count).to eq(3)
        expect(page).to have_css(resource_selector, count: 2)
      end
    end
  end

  describe "show" do
    let(:posts_count) { 1 }
    let(:author) { organization }
    let(:body) { { en: "Short description", ca: "Descripció curta", es: "Descripción corta" } }
    let!(:post) { create(:post, component:, author:, body:) }

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

    it_behaves_like "has embedded video in description", :body
  end
end
