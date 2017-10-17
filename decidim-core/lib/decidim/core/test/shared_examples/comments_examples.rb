# frozen_string_literal: true

shared_examples "comments" do
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, :confirmed, organization: organization) }
  let!(:comments) { create_list(:comment, 3, commentable: commentable) }

  before do
    switch_to_host(organization.host)
  end

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

  it "allows user to sort the comments" do
    comment = create(:comment, commentable: commentable, body: "Most Rated Comment")
    create(:comment_vote, comment: comment, author: user, weight: 1)

    visit resource_path

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

  context "when authenticated" do
    before do
      login_as user, scope: :user
      visit resource_path
    end

    it "shows form to add comments to user" do
      expect(page).to have_selector(".add-comment form")
    end

    context "when user adds a new comment" do
      before do
        within ".add-comment form" do
          fill_in "add-comment-#{commentable.commentable_type}-#{commentable.id}", with: "This is a new comment"
          click_button "Send"
        end
      end

      it "shows comment to the user" do
        expect(page).to have_comment_from(user, "This is a new comment")
      end
    end

    context "when the user has verified organizations" do
      let(:user_group) { create(:user_group, :verified) }

      before do
        create(:user_group_membership, user: user, user_group: user_group)
      end

      it "adds new comment as a user group" do
        visit resource_path

        expect(page).to have_selector(".add-comment form")

        within ".add-comment form" do
          fill_in "add-comment-#{commentable.commentable_type}-#{commentable.id}", with: "This is a new comment"
          select user_group.name, from: "Comment as"
          click_button "Send"
        end

        expect(page).to have_comment_from(user_group, "This is a new comment")
      end
    end

    context "when a user replies to a comment" do
      let!(:comment_author) { create(:user, :confirmed, organization: organization) }
      let!(:comment) { create(:comment, commentable: commentable, author: comment_author) }

      before do
        visit resource_path

        expect(page).to have_selector(".comment__reply")

        within "#comments #comment_#{comment.id}" do
          click_button "Reply"
          fill_in "add-comment-Decidim::Comments::Comment-#{comment.id}", with: "This is a reply"
          click_button "Send"
        end
      end

      it "shows reply to the user" do
        expect(page).to have_reply_to(comment, "This is a reply")
      end
    end

    describe "arguable option" do
      context "commenting with alignment" do
        before do
          visit resource_path

          expect(page).to have_selector(".add-comment form")
        end

        it "works according to the setting in the commentable" do
          if commentable.comments_have_alignment?
            page.find(".opinion-toggle--ok").click

            within ".add-comment form" do
              fill_in "add-comment-#{commentable.commentable_type}-#{commentable.id}", with: "I am in favor about this!"
              click_button "Send"
            end

            within "#comments" do
              expect(page).to have_selector "span.success.label", text: "In favor"
            end
          else
            expect(page).to have_no_selector(".opinion-toggle--ok")
          end
        end
      end
    end

    describe "votable option" do
      before do
        visit resource_path
      end

      context "upvoting a comment" do
        it "works according to the setting in the commentable" do
          within "#comment_#{comments[0].id}" do
            if commentable.comments_have_votes?
              expect(page).to have_selector(".comment__votes--up", text: /0/)
              page.find(".comment__votes--up").click
              expect(page).to have_selector(".comment__votes--up", text: /1/)
            else
              expect(page).to have_no_selector(".comment__votes--up", text: /0/)
            end
          end
        end
      end

      context "downvoting a comment" do
        it "works according to the setting in the commentable" do
          within "#comment_#{comments[0].id}" do
            if commentable.comments_have_votes?
              expect(page).to have_selector(".comment__votes--down", text: /0/)
              page.find(".comment__votes--down").click
              expect(page).to have_selector(".comment__votes--down", text: /1/)
            else
              expect(page).to have_no_selector(".comment__votes--down", text: /0/)
            end
          end
        end
      end
    end
  end
end
