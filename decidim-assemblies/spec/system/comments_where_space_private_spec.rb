# frozen_string_literal: true

require "spec_helper"

describe "Comments", type: :system do
  let!(:organization) { create(:organization) }
  let!(:private_assembly) { create :assembly, :published, organization: organization, private_space: true, is_transparent: true }
  let!(:user) { create :user, :confirmed, organization: organization }
  let!(:other_user) { create :user, :confirmed, organization: organization }
  let!(:assembly_private_user) { create :assembly_private_user, user: other_user, privatable_to: private_assembly }

  let!(:author) { create(:user, :confirmed, organization: organization) }
  let!(:component) { create(:component, manifest_name: :dummy, organization: organization) }
  let!(:commentable) { create(:dummy_resource, component: component, author: author) }

  let!(:comments) { create_list(:comment, 3, commentable: commentable) }
  let(:resource_path) { resource_locator(commentable).path }

  before do
    switch_to_host(organization.host)
  end

  describe "when participatory space is private and transparent" do
    context "and no user is loged in" do
      it "shows the list of comments for the resorce" do
        visit resource_path

        expect(page).to have_selector("#comments")
        expect(page).to have_selector("article.comment", count: comments.length)

        within "#comments" do
          comments.each do |comment|
            expect(page).to have_content comment.author.name
            expect(page).to have_content comment.body
          end
        end
      end

      it "allows user to sort the comments", :slow do
        comment = create(:comment, commentable: commentable, body: "Most Rated Comment")
        create(:comment_vote, comment: comment, author: user, weight: 1)

        visit resource_path

        expect(page).to have_no_content("Comments are disabled at this time")

        expect(page).to have_css(".comment", minimum: 1)
        page.find(".order-by .dropdown.menu .is-dropdown-submenu-parent").hover

        click_link "Best rated"
        expect(page).to have_css(".comments > div:nth-child(2)", text: "Most Rated Comment")
      end

      context "when not authenticated" do
        it "does not show form to add comments to user" do
          visit resource_path
          expect(page).to have_no_selector(".add-comment form")
        end
      end
    end

    context "when user is loged in and is not a assembly private user" do
      before do
        login_as user, scope: :user
        visit resource_path
      end

      context "when user want to create a comment" do
        it "not shows the form to add comments", :slow do
          expect(page).to have_no_selector(".add-comment form")
        end
      end

      context "when a user replies to a comment" do
        let!(:comment_author) { create(:user, :confirmed, organization: organization) }
        let!(:comment) { create(:comment, commentable: commentable, author: comment_author) }

        it "not shows reply to the user" do
          expect(page).to have_no_selector(".comment__reply")
        end
      end

      context "when a user votes to a comment" do
        it "not shows the vote block" do
          expect(page).to have_no_selector(".comment__votes--up")
          expect(page).to have_no_selector(".comment__votes--down")
        end
      end
    end

    context "when user is loged in and is assembly private user" do
      before do
        login_as other_user, scope: :user
        visit resource_path
      end

      context "when user want to create a comment" do
        it "shows the form to add comments", :slow do
          expect(page).to have_selector(".add-comment form")
        end
      end

      context "when a user replies to a comment" do
        let!(:comment_author) { create(:user, :confirmed, organization: organization) }
        let!(:comment) { create(:comment, commentable: commentable, author: comment_author) }

        it "shows reply to the user or not" do
          expect(page).to have_selector(".comment__reply")
        end
      end
    end
  end
end
