# -*- coding: utf-8 -*-
# frozen_string_literal: true
RSpec.shared_examples "comments" do
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, :confirmed, organization: organization) }
  let!(:comments) do
    Array.new(3) do
      create(:comment, commentable: commentable)
    end
  end
  let(:authenticated) { false }

  def visit_commentable_path
    login_as user, scope: :user if authenticated
    visit resource_path
  end

  before do
    switch_to_host(organization.host)
  end

  it "user should see a list of comments" do
    visit_commentable_path

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

    within ".order-by" do
      page.find(".dropdown.menu .is-dropdown-submenu-parent").hover
    end

    click_link "Best rated"

    within "#comments" do
      expect(page.find(".comment", match: :first)).to have_content "Most Rated Comment"
    end
  end

  context "when not authenticated" do
    it "user should not see the form to add comments" do
      visit_commentable_path
      expect(page).not_to have_selector(".add-comment form")
    end
  end

  context "when authenticated" do
    let(:authenticated) { true }

    it "user sees the form to add comments" do
      visit_commentable_path

      expect(page).to have_selector(".add-comment form")
    end

    context "when user adds a new comment" do
      before do
        visit_commentable_path

        expect(page).to have_selector(".add-comment form")

        within ".add-comment form" do
          fill_in "add-comment-#{commentable.commentable_type}-#{commentable.id}", with: "This is a new comment"
          click_button "Send"
        end
      end

      it "user visualize the comment" do
        within "#comments" do
          expect(page).to have_content user.name
          expect(page).to have_content "This is a new comment"
        end
      end

      it "commentable's author receives notificatione" do
        if commentable.respond_to? :author
          wait_for_email subject: "new comment"
          login_as commentable.author, scope: :user
          visit last_email_first_link

          within "#comments" do
            expect(page).to have_content user.name
            expect(page).to have_content "This is a new comment"
          end
        else
          expect do
            wait_for_email subject: "new comment"
          end.to raise_error StandardError
        end
      end
    end

    context "when the user has verified organizations" do
      let(:user_group) { create(:user_group, :verified) }

      before do
        create(:user_group_membership, user: user, user_group: user_group)
      end

      it "user can add a new comment as a user group" do
        visit_commentable_path

        expect(page).to have_selector(".add-comment form")

        within ".add-comment form" do
          fill_in "add-comment-#{commentable.commentable_type}-#{commentable.id}", with: "This is a new comment"
          select user_group.name, from: "Comment as"
          click_button "Send"
        end

        within "#comments" do
          expect(page).to have_content user_group.name
          expect(page).to have_content "This is a new comment"
        end
      end
    end

    context "when a user replies a coment" do
      let!(:comment_author) { create(:user, :confirmed, organization: organization) }
      let!(:comment) { create(:comment, commentable: commentable, author: comment_author) }

      before do
        visit_commentable_path

        expect(page).to have_selector(".comment__reply")

        within "#comments #comment_#{comment.id}" do
          click_button "Reply"
          find("textarea").set("This is a reply")
          click_button "Send"
        end
      end

      it "user visualize the reply" do
        within "#comments #comment_#{comment.id}" do
          expect(page).to have_content "This is a reply"
        end
      end

      it "comment's author receives notification" do
        wait_for_email subject: "new reply"
        login_as comment.author, scope: :user
        visit last_email_first_link

        within "#comments #comment_#{comment.id}" do
          expect(page).to have_content "This is a reply"
        end
      end
    end

    context "when arguable option is enabled" do
      before do
        expect_any_instance_of(commentable.class).to receive(:comments_have_alignment?).and_return(true)
      end

      it "user can comment in favor" do
        visit_commentable_path

        expect(page).to have_selector(".add-comment form")

        page.find(".opinion-toggle--ok").click

        within ".add-comment form" do
          fill_in "add-comment-#{commentable.commentable_type}-#{commentable.id}", with: "I am in favor about this!"
          click_button "Send"
        end

        within "#comments" do
          expect(page).to have_selector "span.success.label", text: "In favor"
        end
      end
    end

    context "when votable option is enabled" do
      before do
        expect_any_instance_of(commentable.class).to receive(:comments_have_votes?).and_return(true)
      end

      it "user can upvote a comment" do
        visit_commentable_path

        within "#comment_#{comments[0].id}" do
          expect(page).to have_selector(".comment__votes--up", text: /0/)
          page.find(".comment__votes--up").click
          expect(page).to have_selector(".comment__votes--up", text: /1/)
        end
      end

      it "user can downvote a comment" do
        visit_commentable_path

        within "#comment_#{comments[0].id}" do
          expect(page).to have_selector(".comment__votes--down", text: /0/)
          page.find(".comment__votes--down").click
          expect(page).to have_selector(".comment__votes--down", text: /1/)
        end
      end
    end
  end
end
