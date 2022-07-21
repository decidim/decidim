# frozen_string_literal: true

shared_examples "comments" do
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, :confirmed, organization: organization) }
  let!(:comments) { create_list(:comment, 3, commentable: commentable) }

  before do
    switch_to_host(organization.host)
  end

  after do
    expect_no_js_errors
  end

  it "shows the list of comments for the resource" do
    visit resource_path

    expect(page).to have_selector("#comments")
    expect(page).to have_selector(".comment", count: comments.length)

    within "#comments" do
      comments.each do |comment|
        expect(page).to have_content comment.author.name
        expect(page).to have_content comment.body.values.first
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

    within ".comments" do
      within ".order-by__dropdown" do
        click_link "Older" # Opens the dropdown
        click_link "Best rated"
      end
    end

    expect(page).to have_css(".comments > div:nth-child(2)", text: "Most Rated Comment")
  end

  context "when there are deleted comments" do
    let(:deleted_comment) { comments[0] }

    before do
      deleted_comment.delete!
      visit resource_path
    end

    it "shows only a deletion message for deleted comments" do
      expect(page).to have_selector("#comment_#{deleted_comment.id}")

      expect(page).to have_no_content(deleted_comment.author.name)
      expect(page).to have_no_content(deleted_comment.body.values.first)
      within "#comment_#{deleted_comment.id}" do
        expect(page).to have_content("Comment deleted on")
        expect(page).to have_no_selector("comment__header")
        expect(page).to have_no_selector("comment__footer")
      end
    end

    it "counts only not deleted comments" do
      expect(page).to have_selector("span.comments-count", text: "#{comments.length - 1} COMMENTS")
    end

    context "when deleted comment has replies, they are shown" do
      let!(:reply) { create(:comment, commentable: deleted_comment, root_commentable: commentable, body: "Please, delete your comment") }

      it "shows replies of deleted comments" do
        visit resource_path

        within "#comment_#{deleted_comment.id}" do
          expect(page).to have_selector("#comment-#{deleted_comment.id}-replies")
          expect(page).to have_content(reply.author.name)
          expect(page).to have_content(reply.body.values.first)
        end
      end
    end
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

    context "when no default comments length specified" do
      it "displays the numbers of characters left" do
        within ".add-comment form" do
          expect(page).to have_content("1000 characters left")
        end
      end
    end

    context "when organization has a default comments length params" do
      let!(:organization) { create(:organization, comments_max_length: 2000) }

      it "displays the numbers of characters left" do
        within ".add-comment form" do
          expect(page).to have_content("2000 characters left")
        end
      end

      it "updates the numbers of characters left correctly" do
        within ".add-comment form" do
          fill_in "add-comment-#{commentable.commentable_type.demodulize}-#{commentable.id}", with: "This is a new comment."
          expect(page).to have_content("1978 characters left")
        end
      end

      context "when working with the screen reader character counter" do
        let(:field_id) { "add-comment-#{commentable.commentable_type.demodulize}-#{commentable.id}" }
        let(:field) { page.find("##{field_id}") }

        before do
          # Make sure the focus stays in the comment form during these tests
          # because only then the screen reader
          page.execute_script("document.getElementById('#{field_id}').focus()")
        end

        it "updates the numbers of characters left correctly for screen reader" do
          within ".add-comment form" do
            fill_in field_id, with: "This is a new comment."

            # The screen reader character counter should update only when the user
            # reaches 10% interval of the total characters available not to
            # announce the remaining characters after every keystroke.
            field.native.send_keys " Sending some new text."
            within ".remaining-character-count" do
              expect(page).to have_content("1955 characters left") # Normal
            end
            within ".remaining-character-count-sr" do
              expect(page).to have_content("2000 characters left") # Screen reader
            end

            # After 10% of the total characters is reached, it should be updated
            # to the screen reader section to announce it.
            field.native.send_keys "a" * 155
            within ".remaining-character-count" do
              expect(page).to have_content("1800 characters left") # Normal
            end
            within ".remaining-character-count-sr" do
              expect(page).to have_content("1800 characters left") # Screen reader
            end

            # After continuing typing after the announcement, the screen reader
            # characters should stay the same (announced on the next 10%
            # interval).
            field.native.send_keys "b"
            within ".remaining-character-count" do
              expect(page).to have_content("1799 characters left") # Normal
            end
            within ".remaining-character-count-sr" do
              expect(page).to have_content("1800 characters left") # Screen reader
            end

            # When text is removed at the interval, the screen reader should
            # update back to the previous interval.
            field.native.send_keys [:backspace, :backspace, :backspace, :backspace]
            within ".remaining-character-count" do
              expect(page).to have_content("1803 characters left") # Normal
            end
            within ".remaining-character-count-sr" do
              expect(page).to have_content("1800 characters left") # Screen reader
            end

            # After continuing typing after the removal of characters, we should
            # stay in the "latest announcement" not to confuse the user as
            # - "1800 characters left" (actual 1803)
            # - Type in one character
            # - "1900 characters left" (actual 1802)
            field.native.send_keys "b"
            within ".remaining-character-count" do
              expect(page).to have_content("1802 characters left") # Normal
            end
            within ".remaining-character-count-sr" do
              expect(page).to have_content("1800 characters left") # Screen reader
            end

            # After the input is blurred, the screen reader character counter
            # should show the actual amount of characters left.
            page.execute_script("document.getElementById('#{field_id}').blur()")
            within ".remaining-character-count" do
              expect(page).to have_content("1802 characters left") # Normal
            end
            within ".remaining-character-count-sr" do
              expect(page).to have_content("1802 characters left") # Screen reader
            end
          end
        end

        context "when reaching the announce after every threshold" do
          it "updates the numbers of characters left correctly for screen reader" do
            within ".add-comment form" do
              # Test that when reaching the "announce after every" threshold, the
              # characters are announced after every keystroke.
              fill_in field_id, with: "a" * 1989
              within ".remaining-character-count" do
                expect(page).to have_content("11 characters left") # Normal
              end
              within ".remaining-character-count-sr" do
                expect(page).to have_content("200 characters left") # Screen reader
              end

              (2..10).reverse_each do |remaining|
                field.native.send_keys "b"
                within ".remaining-character-count-sr" do
                  expect(page).to have_content("#{remaining} characters left")
                end
              end

              field.native.send_keys "b"
              within ".remaining-character-count-sr" do
                expect(page).to have_content("1 character left")
              end

              field.native.send_keys "c"
              within ".remaining-character-count-sr" do
                expect(page).to have_content("0 characters left")
              end

              # Test that the SR counter will stick at the last announced
              # threshold if the next threshold is not hit and text is removed.
              # This prevents weird announcements such as:
              # - 0 characters left
              # - Remove 10 characters
              # - 10 characters left
              # - Remove 1 character
              # - 200 characters left
              page.execute_script("document.getElementById('#{field_id}').setSelectionRange(1850, 2000)")
              field.native.send_keys [:backspace]
              within ".remaining-character-count" do
                expect(page).to have_content("150 characters left") # Normal
              end
              within ".remaining-character-count-sr" do
                expect(page).to have_content("0 characters left") # Screen reader
              end

              field.native.send_keys "d"
              within ".remaining-character-count-sr" do
                expect(page).to have_content("0 characters left")
              end
            end
          end
        end

        context "when deleting text the announce after every threshold" do
          it "updates the numbers of characters left correctly for screen reader" do
            within ".add-comment form" do
              fill_in field_id, with: "a" * 2000
              within ".remaining-character-count" do
                expect(page).to have_content("0 characters left") # Normal
              end
              within ".remaining-character-count-sr" do
                expect(page).to have_content("0 characters left") # Screen reader
              end

              # Test that the SR counter updates correctly after hitting the
              # next threshold.
              page.execute_script("document.getElementById('#{field_id}').setSelectionRange(1800, 2000)")
              field.native.send_keys [:backspace]
              within ".remaining-character-count" do
                expect(page).to have_content("200 characters left") # Normal
              end
              within ".remaining-character-count-sr" do
                expect(page).to have_content("200 characters left") # Screen reader
              end

              # The SR counter should stay at the correct boundary.
              field.native.send_keys [:backspace, :backspace]
              within ".remaining-character-count" do
                expect(page).to have_content("202 characters left") # Normal
              end
              within ".remaining-character-count-sr" do
                expect(page).to have_content("200 characters left") # Screen reader
              end

              # It stays at the correct boundary when starting to type again.
              field.native.send_keys "b"
              within ".remaining-character-count" do
                expect(page).to have_content("201 characters left") # Normal
              end
              within ".remaining-character-count-sr" do
                expect(page).to have_content("200 characters left") # Screen reader
              end

              field.native.send_keys "c"
              within ".remaining-character-count" do
                expect(page).to have_content("200 characters left") # Normal
              end
              within ".remaining-character-count-sr" do
                expect(page).to have_content("200 characters left") # Screen reader
              end

              field.native.send_keys "d"
              within ".remaining-character-count" do
                expect(page).to have_content("199 characters left") # Normal
              end
              within ".remaining-character-count-sr" do
                expect(page).to have_content("200 characters left") # Screen reader
              end
            end
          end
        end
      end

      context "when component is present and has a default comments length params" do
        it "displays the numbers of characters left" do
          if component.present?
            component.update!(settings: { comments_max_length: 3000 })
            visit current_path

            within ".add-comment form" do
              expect(page).to have_content("3000 characters left")
            end
          end
        end

        it "let the emoji button works properly when there are not too much characters" do
          if component.present?
            component.update!(settings: { comments_max_length: 100 })
            visit current_path

            within ".add-comment form" do
              find(:css, "textarea:enabled").set("toto")
              expect(page).not_to have_selector(".emoji-picker__wrapper")
              find("svg").click
            end
            expect(page).to have_selector(".emoji-picker__wrapper")
          end
        end

        it "deactivate the emoji button when there are less than 4 characters left" do
          if component.present?
            component.update!(settings: { comments_max_length: 30 })
            visit current_path

            within ".add-comment form" do
              find(:css, "textarea:enabled").set("0123456789012345678901234567")
              find("svg").click
              expect(page).not_to have_selector(".emoji-picker__wrapper")
            end
          end
        end
      end
    end

    context "when user adds a new comment" do
      before do
        within ".add-comment form" do
          fill_in "add-comment-#{commentable.commentable_type.demodulize}-#{commentable.id}", with: "This is a new comment"
          click_button "Send"
        end
      end

      it "shows comment to the user, updates the comments counter and clears the comment textarea" do
        expect(page).to have_comment_from(user, "This is a new comment", wait: 20)
        expect(page).to have_selector("span.comments-count", text: "#{commentable.comments.count} COMMENTS")
        expect(page).to have_field("add-comment-#{commentable.commentable_type.demodulize}-#{commentable.id}", with: "")
      end
    end

    context "when user adds a new comment with a link" do
      before do
        within ".add-comment form" do
          fill_in "add-comment-#{commentable.commentable_type.demodulize}-#{commentable.id}", with: "Very nice http://www.debian.org linux distro"
          click_button "Send"
        end
      end

      it "adds external link css" do
        expect(page).to have_css("a", text: "http://www.debian.org")
        within("a", text: "http://www.debian.org") do
          expect(page).to have_text "External link"
        end
      end

      it "changes link to point to /link" do
        expect(page).to have_link("http://www.debian.org", href: "/link?external_url=http%3A%2F%2Fwww.debian.org")
      end
    end

    context "when the user is writing a new comment while someone else comments" do
      let(:new_comment_body) { "Hey, I just jumped in the conversation!" }
      let(:new_comment) { build(:comment, commentable: commentable, body: new_comment_body) }

      before do
        within ".add-comment form" do
          fill_in "add-comment-#{commentable.commentable_type.demodulize}-#{commentable.id}", with: "This is a new comment"
        end
        new_comment.save!
      end

      it "does not clear the current user's comment" do
        expect(page).to have_content(new_comment.body.values.first, wait: 20)
        expect(page).to have_field(
          "add-comment-#{commentable.commentable_type.demodulize}-#{commentable.id}",
          with: "This is a new comment"
        )
      end

      context "when inside a thread reply form" do
        let(:thread) { comments.first }
        let(:new_reply_body) { "Hey, I just jumped inside the thread!" }
        let(:new_reply) { build(:comment, commentable: thread, root_commentable: commentable, body: new_reply_body) }

        before do
          within "#comment_#{thread.id}" do
            click_button "Reply"

            within ".add-comment form" do
              fill_in "add-comment-#{thread.commentable_type.demodulize}-#{thread.id}", with: "This is a new reply"
            end
          end
          new_reply.save!
        end

        it "does not clear the current user's comment" do
          expect(page).to have_content(new_reply.body.values.first, wait: 20)
          expect(page).to have_field(
            "add-comment-#{commentable.commentable_type.demodulize}-#{commentable.id}",
            with: "This is a new comment"
          )
          expect(page).to have_field(
            "add-comment-#{thread.commentable_type.demodulize}-#{thread.id}",
            with: "This is a new reply"
          )
        end
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
          fill_in "add-comment-#{commentable.commentable_type.demodulize}-#{commentable.id}", with: "This is a new comment"
          select user_group.name, from: "Comment as"
          click_button "Send"
        end

        expect(page).to have_comment_from(user_group, "This is a new comment", wait: 20)
      end
    end

    context "when a user deletes a comment" do
      let(:comment_body) { "This comment is a mistake" }
      let!(:comment) { create(:comment, body: comment_body, commentable: commentable, author: comment_author) }

      before do
        visit resource_path
      end

      context "when the comment is not authored by user" do
        let!(:comment_author) { create(:user, :confirmed, organization: organization) }

        it "the context menu of the comment doesn't show a delete link" do
          within "#comment_#{comment.id}" do
            within ".comment__header__context-menu" do
              page.find("label").click
              expect(page).to have_no_link("Delete")
            end
          end
        end
      end

      context "when the comment is authored by user" do
        let(:comment_author) { user }

        it "the context menu of the comment shows a delete link" do
          within "#comment_#{comment.id}" do
            within ".comment__header__context-menu" do
              page.find("label").click
              expect(page).to have_link("Delete")
            end
          end
        end

        it "the user can delete the comment and updates the comments counter" do
          expect(Decidim::Comments::Comment.not_deleted.count).to eq(4)

          within "#comment_#{comment.id}" do
            within ".comment__header__context-menu" do
              page.find("label").click
              click_link "Delete"
            end
          end

          within "div.confirm-reveal" do
            click_link "OK"
          end

          expect(page).to have_selector("#comment_#{comment.id}")
          expect(page).to have_no_content(comment_body)
          within "#comment_#{comment.id}" do
            expect(page).to have_content("Comment deleted on")
            expect(page).to have_no_content comment_author.name
            expect(page).to have_no_selector("comment__header")
            expect(page).to have_no_selector("comment__footer")
          end
          expect(page).to have_selector("span.comments-count", text: "3 COMMENTS")

          expect(Decidim::Comments::Comment.not_deleted.count).to eq(3)
        end
      end
    end

    context "when a user edits a comment" do
      let(:comment_body) { "This coment has a typo" }
      let!(:comment) { create(:comment, body: comment_body, commentable: commentable, author: comment_author) }

      before do
        visit resource_path
      end

      context "when the comment is not authored by user" do
        let!(:comment_author) { create(:user, :confirmed, organization: organization) }

        it "the context menu of the comment doesn't show an edit button" do
          within "#comment_#{comment.id}" do
            within ".comment__header__context-menu" do
              page.find("label").click
              expect(page).to have_no_button("Edit")
            end
          end
        end
      end

      context "when the comment is authored by user" do
        let!(:comment_author) { user }

        it "the context menu of the comment show an edit button" do
          within "#comment_#{comment.id}" do
            within ".comment__header__context-menu" do
              page.find("label").click
              expect(page).to have_button("Edit")
            end
          end
        end

        context "when the user edits a comment" do
          before do
            within "#comment_#{comment.id} .comment__header__context-menu" do
              page.find("label").click
              click_button "Edit"
            end
            fill_in "edit_comment_#{comment.id}", with: "This comment has been fixed"
            click_button "Send"
          end

          it "the comment body changes" do
            within "#comment_#{comment.id}" do
              expect(page).to have_content("This comment has been fixed")
              expect(page).to have_no_content(comment_body)
            end
          end

          it "the header of the comment displays an edited message" do
            within "#comment_#{comment.id} .comment__header" do
              expect(page).to have_content("Edited")
            end
          end
        end
      end
    end

    context "when a user replies to a comment", :slow do
      let!(:comment_author) { create(:user, :confirmed, organization: organization) }
      let!(:comment) { create(:comment, commentable: commentable, author: comment_author) }

      it "shows reply to the user" do
        visit resource_path

        expect(page).to have_selector(".comment__reply")
        expect(page).not_to have_selector(".comment__additionalreply")

        within "#comments #comment_#{comment.id}" do
          click_button "Reply"
        end

        expect(page).to have_selector("#comment_#{comment.id} .add-comment")
        fill_in "add-comment-Comment-#{comment.id}", with: "This is a reply"
        within ".comment-thread .add-comment" do
          click_button "Send"
        end

        expect(page).to have_selector(".comment-thread .comment--nested", wait: 20)
        expect(page).to have_selector(".comment__additionalreply")
        expect(page).to have_reply_to(comment, "This is a reply")
        expect(page).to have_selector("span.comments-count", text: "#{commentable.comments.count} COMMENTS")
      end
    end

    context "when a comment has been moderated" do
      let!(:parent) { create(:comment, commentable: commentable) }
      let!(:reply) { create(:comment, commentable: parent, root_commentable: commentable) }

      it "doesn't show additional reply" do
        Decidim::Moderation.create!(reportable: reply, participatory_space: reply.participatory_space, hidden_at: 1.day.ago)

        visit current_path

        within "#comments #comment_#{parent.id}" do
          expect(page).to have_selector(".comment__reply")
          expect(page).not_to have_selector(".comment__additionalreply")
        end
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
            expect(page.find(".opinion-toggle--ok")["aria-pressed"]).to eq("true")
            expect(page.find(".opinion-toggle--meh")["aria-pressed"]).to eq("false")
            expect(page.find(".opinion-toggle--ko")["aria-pressed"]).to eq("false")
            expect(page.find(".opinion-toggle .selected-state", visible: false)).to have_content("Your opinion about this topic is positive")

            within ".add-comment form" do
              fill_in "add-comment-#{commentable.commentable_type.demodulize}-#{commentable.id}", with: "I am in favor about this!"
              click_button "Send"
            end

            within "#comments" do
              expect(page).to have_selector "span.success.label", text: "In favor", wait: 20
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

    describe "mentions drop-down", :slow do
      before do
        visit resource_path

        within ".add-comment form" do
          fill_in "add-comment-#{commentable.commentable_type.demodulize}-#{commentable.id}", with: content
        end
      end

      context "when mentioning a valid user" do
        let!(:mentioned_user) { create(:user, :confirmed, organization: organization) }
        let(:content) { "A valid user mention: @#{mentioned_user.nickname}" }

        context "when text finish with a mention" do
          it "shows the tribute container" do
            expect(page).to have_selector(".tribute-container", text: mentioned_user.name)
          end
        end

        context "when text contains a mention" do
          let(:content) { "A valid user mention: @#{mentioned_user.nickname}." }

          it "shows the tribute container" do
            expect(page).not_to have_selector(".tribute-container", text: mentioned_user.name)
          end
        end
      end

      context "when mentioning a non valid user" do
        let!(:mentioned_user) { create(:user, organization: organization) }
        let(:content) { "A unconfirmed user mention: @#{mentioned_user.nickname}" }

        it "do not show the tribute container" do
          expect(page).not_to have_selector(".tribute-container", text: mentioned_user.name)
        end
      end

      context "when mentioning a group" do
        let!(:mentioned_group) { create(:user_group, :confirmed, organization: organization) }
        let(:content) { "A confirmed user group mention: @#{mentioned_group.nickname}" }

        it "shows the tribute container" do
          expect(page).to have_selector(".tribute-container")
        end
      end
    end

    describe "mentions", :slow do
      before do
        visit resource_path

        within ".add-comment form" do
          fill_in "add-comment-#{commentable.commentable_type.demodulize.demodulize}-#{commentable.id}", with: content
          click_button "Send"
        end
      end

      context "when mentioning a valid user" do
        let!(:mentioned_user) { create(:user, :confirmed, organization: organization) }
        # do not finish with the mention to avoid trigger the drop-down
        let(:content) { "A valid user mention: @#{mentioned_user.nickname}." }

        it "replaces the mention with a link to the user's profile" do
          expect(page).to have_comment_from(user, "A valid user mention: @#{mentioned_user.nickname}", wait: 20)
          expect(page).to have_link "@#{mentioned_user.nickname}", href: "http://#{mentioned_user.organization.host}:#{Capybara.server_port}/profiles/#{mentioned_user.nickname}"
        end
      end

      context "when mentioning an existing user outside current organization" do
        let!(:mentioned_user) { create(:user, :confirmed, organization: create(:organization)) }
        let(:content) { "This text mentions a user outside current organization: @#{mentioned_user.nickname}" }

        it "ignores the mention" do
          expect(page).to have_comment_from(user, "This text mentions a user outside current organization: @#{mentioned_user.nickname}", wait: 20)
          expect(page).not_to have_link "@#{mentioned_user.nickname}"
        end
      end

      context "when mentioning a non valid user" do
        let(:content) { "This text mentions a @nonexistent user" }

        it "ignores the mention" do
          expect(page).to have_comment_from(user, "This text mentions a @nonexistent user", wait: 20)
          expect(page).not_to have_link "@nonexistent"
        end
      end
    end

    describe "hashtags", :slow do
      let(:content) { "A comment with a hashtag #decidim" }

      before do
        visit resource_path

        within ".add-comment form" do
          fill_in "add-comment-#{commentable.commentable_type.demodulize}-#{commentable.id}", with: content
          click_button "Send"
        end
      end

      it "replaces the hashtag with a link to the hashtag search" do
        expect(page).to have_comment_from(user, "A comment with a hashtag #decidim", wait: 20)
        expect(page).to have_link "#decidim", href: "/search?term=%23decidim"
      end
    end
  end
end
