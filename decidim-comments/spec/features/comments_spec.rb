# frozen_string_literal: true
require "spec_helper"

describe "Comments", type: :feature do
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, :confirmed, organization: organization) }
  let!(:participatory_process) { create(:participatory_process, organization: organization) }
  let!(:comments) {
    3.times.map do
      create(:comment, commentable: participatory_process)
    end
  }

  before do
    switch_to_host(organization.host)
  end

  it "user should see a list of comments" do
    visit decidim.dummy_path(participatory_process)

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
    comment = create(:comment, commentable: participatory_process, body: "Most Rated Comment")
    create(:comment_vote, comment: comment, author: user, weight: 1)

    visit decidim.dummy_path(participatory_process)
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
      visit decidim.dummy_path(participatory_process)
      expect(page).not_to have_selector(".add-comment form")
    end
  end

  context "when authenticated" do
    before do
      login_as user, scope: :user
    end

    it "user should not see the form to add comments" do
      visit decidim.dummy_path(participatory_process)
      expect(page).to have_selector(".add-comment form")
    end

    it "user can add a new comment" do
      visit decidim.dummy_path(participatory_process)
      expect(page).to have_selector(".add-comment form")

      within ".add-comment form" do
        fill_in "add-comment-#{participatory_process.class.name}-#{participatory_process.id}", with: "This is a new comment"
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
      end

      it "user can add a new comment as a user group" do
        visit decidim.dummy_path(participatory_process)
        expect(page).to have_selector(".add-comment form")

        within ".add-comment form" do
          fill_in "add-comment-#{participatory_process.class.name}-#{participatory_process.id}", with: "This is a new comment"
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
      comment = create(:comment, commentable: participatory_process)
      visit decidim.dummy_path(participatory_process)

      expect(page).to have_selector(".comment__reply")
 
      within "#comments #comment_#{comment.id}" do
        click_button "Reply"
        find("textarea").set("This is a reply")
        click_button "Send"

        expect(page).to have_content "This is a reply"
      end
    end

    context "when arguable option is enabled" do
      it "user can comment in favor" do
        visit decidim.dummy_path(participatory_process, arguable: true)
        expect(page).to have_selector(".add-comment form")

        click_button "I am in favor"

        within ".add-comment form" do
          fill_in "add-comment-#{participatory_process.class.name}-#{participatory_process.id}", with: "I am in favor about this!"
          click_button "Send"
        end

        within "#comments" do
          expect(page).to have_selector 'span.success.label', text: "In favor"
        end
      end
    end

    context "when votable option is enabled" do
      before do
        visit decidim.dummy_path(participatory_process, votable: true)
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
