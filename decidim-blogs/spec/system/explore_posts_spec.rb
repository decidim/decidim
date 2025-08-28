# frozen_string_literal: true

require "spec_helper"

describe "Explore posts" do
  include_context "with a component"
  let(:manifest_name) { "blogs" }

  context "when there are no posts" do
    describe "index" do
      before do
        visit_component
      end

      it "shows an empty page with a message" do
        within "main" do
          expect(page).to have_content "There are no posts yet"
        end
      end
    end
  end

  context "when there are posts" do
    let!(:old_post) { create(:post, component:, created_at: 2.days.ago) }
    let!(:new_post) { create(:post, component:, created_at: Time.current) }

    let!(:image) { create(:attachment, attached_to: old_post) }

    describe "index" do
      let!(:old_post_id) { "[id$='#{old_post.id}']" }
      let!(:new_post_id) { "[id$='#{new_post.id}']" }

      before do
        create(:comment, commentable: old_post)
        create(:like, resource: old_post, author: build(:user, organization: old_post.participatory_space.organization))

        visit_component
      end

      it "shows the component name in the sidebar" do
        within("aside") do
          expect(page).to have_content(translated(component.name))
        end
      end

      it "shows all posts for the given process" do
        expect(page).to have_css("#blogs > a", count: 2)
      end

      context "when paginating" do
        let(:collection_size) { 25 }
        let!(:collection) { create_list(:post, collection_size, component:) }

        before do
          visit_component
        end

        it "lists 25 resources per page by default" do
          expect(page).to have_css("#blogs > a", count: 25)
          expect(page).to have_css("[data-pages] [data-page]", count: 2)
        end
      end

      context "with some unpublished posts" do
        let!(:unpublished) { create(:post, component:, published_at: 2.days.from_now) }

        it "shows only published blogs" do
          expect(Decidim::Blogs::Post.count).to eq(3)
          expect(page).to have_css("#blogs > a", count: 2)
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

      context "when author is a user" do
        let(:author) { user }

        it "shows user as the author" do
          within ".author__name" do
            expect(page).to have_content(user.name)
          end
        end

        context "when participant is deleted" do
          let(:author) { create(:user, :deleted, organization: component.organization) }

          it "successfully shows the page" do
            expect(page).to have_content("Deleted participant")
          end
        end
      end

      it "show post info" do
        expect(page).to have_i18n_content(post.title)
        expect(page).to have_i18n_content(post.body)
        expect(page).to have_content(translated(post.author.name))
        expect(page).to have_content(post.created_at.strftime("%d/%m/%Y %H:%M"))
      end

      it_behaves_like "has embedded video in description", :body
    end
  end
end
