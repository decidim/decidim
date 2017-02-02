# frozen_string_literal: true
require "spec_helper"

describe "Comments", type: :feature do
  let!(:organization) { create(:organization) }
  let!(:feature) { create(:feature, organization: organization) }
  let!(:user) { create(:user, :confirmed, organization: organization) }
  let!(:commentable) { create(:dummy_resource, feature: feature) }
  let!(:comments) {
    3.times.map do
      create(:comment, commentable: commentable)
    end
  }

  def visit_commentable_path(options = {})
    visit decidim_dummy.dummy_resource_path(commentable, feature_id: commentable.feature, participatory_process_id: commentable.feature.participatory_process, arguable: options[:arguable], votable: options[:votable])
  end

  before do
    switch_to_host(organization.host)
    visit_commentable_path
  end

  it "user should see a list of comments" do
    expect(page).to have_selector("#comments")
    expect(page).to have_selector("article.comment", count: comments.length)

    within "#comments" do
      comments.each do |comment|
        expect(page).to have_content comment.author.name
        expect(page).to have_content comment.body
      end
    end
  end

  it "user should be able to sort the comments" do
    comment = create(:comment, commentable: commentable, body: "Most Rated Comment")
    create(:comment_vote, comment: comment, author: user, weight: 1)

    visit_commentable_path

    page.find("div.order-by__dropdown.order-by__dropdown--right").hover
    within "div.order-by__dropdown.order-by__dropdown--right" do
      click_link "Best rated"
    end

    within "#comments" do
      expect(page.find('.comment', match: :first)).to have_content "Most Rated Comment"
    end
  end

  context "when not authenticated" do
    it "user should not see the form to add comments" do
      expect(page).not_to have_selector(".add-comment form")
    end
  end

  context "when authenticated" do
    before do
      login_as user, scope: :user
      visit_commentable_path
    end

    it "user should not see the form to add comments" do
      expect(page).to have_selector(".add-comment form")
    end

    it "user can add a new comment" do
      expect(page).to have_selector(".add-comment form")

      within ".add-comment form" do
        fill_in "add-comment-#{commentable.class.name}-#{commentable.id}", with: "This is a new comment"
        click_button "Send"
      end

      within "#comments" do
        expect(page).to have_content user.name
        expect(page).to have_content "This is a new comment"
      end
    end

    context "when the user has verified organizations" do
      let(:user_group) { create(:user_group, :verified) }

      before do
        create(:user_group_membership, user: user, user_group: user_group)
        visit_commentable_path
      end

      it "user can add a new comment as a user group" do
        expect(page).to have_selector(".add-comment form")

        within ".add-comment form" do
          fill_in "add-comment-#{commentable.class.name}-#{commentable.id}", with: "This is a new comment"
          select user_group.name, from: "Comment as"
          click_button "Send"
        end

        within "#comments" do
          expect(page).to have_content user_group.name
          expect(page).to have_content "This is a new comment"
        end
      end
    end

    it "user can reply a comment" do
      comment = create(:comment, commentable: commentable)

      visit_commentable_path

      expect(page).to have_selector(".comment__reply")

      within "#comments #comment_#{comment.id}" do
        click_button "Reply"
        find("textarea").set("This is a reply")
        click_button "Send"

        expect(page).to have_content "This is a reply"
      end
    end

    context "when arguable option is enabled" do
      before do
        visit_commentable_path arguable: true
      end

      it "user can comment in favor" do
        expect(page).to have_selector(".add-comment form")

        click_button "I am in favor"

        within ".add-comment form" do
          fill_in "add-comment-#{commentable.class.name}-#{commentable.id}", with: "I am in favor about this!"
          click_button "Send"
        end

        within "#comments" do
          expect(page).to have_selector 'span.success.label', text: "In favor"
        end
      end
    end

    context "when votable option is enabled" do
      before do
        visit_commentable_path votable: true
      end

      it "user can upvote a comment" do
        within "#comment_#{comments[0].id}" do
          expect(page).to have_selector('.comment__votes--up', text: /0/)
          page.find('.comment__votes--up').click
          expect(page).to have_selector('.comment__votes--up', text: /1/)
        end
      end

      it "user can downvote a comment" do
        within "#comment_#{comments[0].id}" do
          expect(page).to have_selector('.comment__votes--down', text: /0/)
          page.find('.comment__votes--down').click
          expect(page).to have_selector('.comment__votes--down', text: /1/)
        end
      end
    end
  end
end
