# frozen_string_literal: true

require "spec_helper"

describe "Search posts" do
  include ActionView::Helpers::SanitizeHelper

  include_context "with a component"
  let(:manifest_name) { "blogs" }
  let!(:searchables) { create_list(:post, 3, component:) }
  let!(:term) { strip_tags(translated(searchables.first.title)).split.last }

  before do
    searchables << create(:post, component:, title: { en: "A post with a title" })
  end

  include_examples "searchable results"

  context "when rendering the results in the search page" do
    let(:search_term) { "doggo" }
    let(:post_taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:, skip_injection: true) }
    let(:child_post_taxonomy) { create(:taxonomy, parent: post_taxonomy, organization:, skip_injection: true) }
    let!(:post_taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: post_taxonomy) }
    let!(:child_post_taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: child_post_taxonomy) }
    let!(:posts) do
      create_list(
        :post,
        5,
        component:,
        author:,
        taxonomies: [post_taxonomy, child_post_taxonomy],
        title: { en: "A doggo post with metadata" }
      )
    end

    before do
      visit decidim.search_path(term: search_term, filter: { with_resource_type: "Decidim::Blogs::Post" })
    end

    context "when official" do
      let(:author) { organization }

      it "renders the post title as a link to the post page" do
        posts.each do |post|
          expect(page).to have_link(translated(post.title), href: Decidim::ResourceLocatorPresenter.new(post).path)
        end
      end

      it "renders the taxonomies of the post" do
        posts.each do |post|
          within "div.card__search#post_#{post.id}" do
            expect(page).to have_css(".card__search-metadata", text: translated(post_taxonomy.name))
            expect(page).to have_css(".card__search-metadata", text: translated(child_post_taxonomy.name))
          end
        end
      end

      it "renders the official author of the post" do
        posts.each do |post|
          within "div.card__search#post_#{post.id}" do
            expect(page).to have_css(".author__name", text: I18n.t("decidim.author.official_author"))
          end
        end
      end
    end

    context "when has an author" do
      let(:author) { create(:user, :confirmed, organization:) }

      it "renders the post title as a link to the post page" do
        posts.each do |post|
          expect(page).to have_link(translated(post.title), href: Decidim::ResourceLocatorPresenter.new(post).path)
        end
      end

      it "renders the taxonomies of the post" do
        posts.each do |post|
          within "div.card__search#post_#{post.id}" do
            expect(page).to have_css(".card__search-metadata", text: translated(post_taxonomy.name))
            expect(page).to have_css(".card__search-metadata", text: translated(child_post_taxonomy.name))
          end
        end
      end

      it "renders the author of the post" do
        posts.each do |post|
          within "div.card__search#post_#{post.id}" do
            expect(page).to have_css(".author__name", text: author.name)
          end
        end
      end
    end
  end

  context "when a post title contains HTML" do
    let(:search_term) { "doggo" }
    let!(:malicious) { create(:post, component:, title: { en: 'A doggo <script>alert("XSS")</script> post' }) }

    before do
      visit decidim.search_path(term: search_term, filter: { with_resource_type: "Decidim::Blogs::Post" })
    end

    it "escapes the title instead of rendering it" do
      expect(page).to have_css(".card__search-title", text: '<script>alert("XSS")</script>')
      expect(page).to have_no_css(".card__search-title script")
    end
  end
end
