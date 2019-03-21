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

    context "when a user replies to a comment", :slow do
      let!(:comment_author) { create(:user, :confirmed, organization: organization) }
      let!(:comment) { create(:comment, commentable: commentable, author: comment_author) }

      it "shows reply to the user" do
        visit resource_path

        expect(page).to have_selector(".comment__reply")

        within "#comments #comment_#{comment.id}" do
          click_button "Reply"
        end

        expect(page).to have_selector("#comment_#{comment.id} .add-comment")
        fill_in "add-comment-Decidim::Comments::Comment-#{comment.id}", with: "This is a reply"
        within ".comment-thread .add-comment" do
          click_button "Send"
        end

        expect(page).to have_selector(".comment-thread .comment--nested")
        expect(page).to have_reply_to(comment, "This is a reply")
      end
    end

    describe "arguable option" do
      context "when commenting with alignment" do
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

      context "when upvoting a comment" do
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

      context "when downvoting a comment" do
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

    describe "mentions" do
      before do
        visit resource_path

        within ".add-comment form" do
          fill_in "add-comment-#{commentable.commentable_type}-#{commentable.id}", with: content
          click_button "Send"
        end
      end

      context "when mentioning a valid user" do
        let!(:mentioned_user) { create(:user, :confirmed, organization: organization) }
        let(:content) { "A valid user mention: @#{mentioned_user.nickname}" }

        it "replaces the mention with a link to the user's profile" do
          expect(page).to have_comment_from(user, "A valid user mention: @#{mentioned_user.nickname}")
          expect(page).to have_link "@#{mentioned_user.nickname}", href: "/profiles/#{mentioned_user.nickname}"
        end
      end

      context "when mentioning an existing user outside current organization" do
        let!(:mentioned_user) { create(:user, :confirmed, organization: create(:organization)) }
        let(:content) { "This text mentions a user outside current organization: @#{mentioned_user.nickname}" }

        it "ignores the mention" do
          expect(page).to have_comment_from(user, "This text mentions a user outside current organization: @#{mentioned_user.nickname}")
          expect(page).not_to have_link "@#{mentioned_user.nickname}"
        end
      end

      context "when mentioning a non valid user" do
        let(:content) { "This text mentions a @nonexistent user" }

        it "ignores the mention" do
          expect(page).to have_comment_from(user, "This text mentions a @nonexistent user")
          expect(page).not_to have_link "@nonexistent"
        end
      end
    end
  end

  describe "when participatory space is private" do
    context "when user want to create a comment" do
      before do
        component.participatory_space.private_space = true
        login_as user, scope: :user
      end

      it "shows the form to add comments or not" do
        Rails.logger.debug "11111 ==========="
        Rails.logger.debug "user: #{user.as_json}"
        Rails.logger.debug "--------------------"
        Rails.logger.debug "user is admin?: #{user.admin?}"
        Rails.logger.debug "--------------------"
        Rails.logger.debug "participatory space private: #{component.participatory_space.private_space}"
        Rails.logger.debug "--------------------"
        Rails.logger.debug "commentable: #{commentable.as_json}"
        Rails.logger.debug "--------------------"
        Rails.logger.debug "have votes: #{commentable.comments_have_votes?}"
        Rails.logger.debug "--------------------"
        Rails.logger.debug "allowed?: #{commentable.user_allowed_to_comment?(user)}"
        Rails.logger.debug "--------------------"
        Rails.logger.debug "resource_path: #{resource_path}"
        Rails.logger.debug "11111 ==========="

        visit resource_path
        if commentable.user_allowed_to_comment?(user)
          expect(page).to have_selector(".add-comment form")
        else
          expect(page).to have_no_selector(".add-comment form")
        end
      end
    end

    context "when a user replies to a comment", :slow do
      let!(:comment_author) { create(:user, :confirmed, organization: organization) }
      let!(:comment) { create(:comment, commentable: commentable, author: comment_author) }

      before do
        component.participatory_space.private_space = true
        login_as user, scope: :user
      end

      it "shows reply to the user or not" do
        Rails.logger.debug "2222222 ==========="
        Rails.logger.debug "user: #{user.as_json}"
        Rails.logger.debug "--------------------"
        Rails.logger.debug "user is admin?: #{user.admin?}"
        Rails.logger.debug "--------------------"
        Rails.logger.debug "participatory space private: #{component.participatory_space.private_space}"
        Rails.logger.debug "--------------------"
        Rails.logger.debug "commentable: #{commentable.as_json}"
        Rails.logger.debug "--------------------"
        Rails.logger.debug "have votes: #{commentable.comments_have_votes?}"
        Rails.logger.debug "--------------------"
        Rails.logger.debug "allowed?: #{commentable.user_allowed_to_comment?(user)}"
        Rails.logger.debug "--------------------"
        Rails.logger.debug "resource_path: #{resource_path}"
        Rails.logger.debug "2222 ==========="

        visit resource_path
        if commentable.user_allowed_to_comment?(user)
          expect(page).to have_selector(".comment__reply")
        else
          expect(page).to have_no_selector(".comment__reply")
        end
      end
    end

    context "when a user votes to a comment" do
      before do
        component.participatory_space.private_space = true
        login_as user, scope: :user
      end

      it "shows the vote block or not" do
        Rails.logger.debug "333333 ==========="
        Rails.logger.debug "user: #{user.as_json}"
        Rails.logger.debug "--------------------"
        Rails.logger.debug "user is admin?: #{user.admin?}"
        Rails.logger.debug "--------------------"
        Rails.logger.debug "participatory space private: #{component.participatory_space.private_space}"
        Rails.logger.debug "--------------------"
        Rails.logger.debug "commentable: #{commentable.as_json}"
        Rails.logger.debug "--------------------"
        Rails.logger.debug "have votes: #{commentable.comments_have_votes?}"
        Rails.logger.debug "--------------------"
        Rails.logger.debug "allowed?: #{commentable.user_allowed_to_comment?(user)}"
        Rails.logger.debug "--------------------"
        Rails.logger.debug "resource_path: #{resource_path}"
        Rails.logger.debug "333333 ==========="

        visit resource_path
        if commentable.user_allowed_to_comment?(user) && commentable.comments_have_votes?
          expect(page).to have_selector(".comment__votes--up")
          expect(page).to have_selector(".comment__votes--down")
        else
          expect(page).to have_no_selector(".comment__votes--up")
          expect(page).to have_no_selector(".comment__votes--down")
        end
      end
    end
  end
end
