# frozen_string_literal: true

shared_examples "comments" do
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, :confirmed, organization:) }
  let!(:comments) { create_list(:comment, 3, commentable:) }

  before do
    switch_to_host(organization.host)
  end

  after do
    expect_no_js_errors
  end

  it "shows the list of comments for the resource" do
    visit resource_path

    expect(page).to have_css("#comments")
    expect(page).to have_css(".comment", count: comments.length)

    within "#comments" do
      comments.each do |comment|
        expect(page).to have_content comment.author.name
        expect(page).to have_content comment.body.values.first
      end
    end
  end

  it "allows user to sort the comments", :slow do
    comment = create(:comment, commentable:, body: "Most Rated Comment")
    create(:comment_vote, comment:, author: user, weight: 1)

    visit resource_path

    expect(page).to have_no_content("Comments are disabled at this time")

    expect(page).to have_css(".comment", minimum: 1)

    within ".comment-order-by" do
      select "Best rated", from: "order"
    end

    expect(page).to have_css(".comments > div:nth-child(2)", text: "Most Rated Comment")
  end

  context "when there are comments and replies" do
    let!(:single_comment) { create(:comment, commentable:) }
    let!(:reply) { create(:comment, commentable: single_comment, root_commentable: commentable) }

    it "displays the show replies link on comment with reply" do
      visit resource_path
      expect(page).to have_no_content("Comments are disabled at this time")
      expect(page).to have_css(".comment", minimum: 1)

      within("#accordion-#{single_comment.id}") do
        expect(page).to have_content "1 answer"
      end
    end

    context "when there is a comment with the same parent id but different type with replies" do
      let!(:other_component) { create(:component, manifest_name: :dummy, organization:) }
      let!(:other_commentable) { create(:dummy_resource, component: other_component, author: user, id: single_comment.id) }
      let!(:reply) { create(:comment, commentable: other_commentable, root_commentable: other_commentable) }
      let!(:other_reply) { create(:comment, commentable: reply, root_commentable: other_commentable) }

      it "displays the show replies link on comment with reply" do
        visit resource_path
        expect(page).to have_no_content("Comments are disabled at this time")
        expect(page).to have_css(".comment", minimum: 1)

        within("#accordion-#{single_comment.id}") do
          expect(page).to have_no_content "Hide reply"
        end
      end
    end
  end

  context "when there are deleted comments" do
    let(:deleted_comment) { comments[0] }

    before do
      deleted_comment.delete!
      visit resource_path
    end

    it "shows only a deletion message for deleted comments" do
      expect(page).to have_css("#comment_#{deleted_comment.id}")

      expect(page).to have_no_content(deleted_comment.author.name)
      expect(page).to have_no_content(translated(deleted_comment.body))
      within "#comment_#{deleted_comment.id}" do
        expect(page).to have_content("Comment deleted on")
        expect(page).to have_no_css(".comment__header")
      end
    end

    it "counts only not deleted comments" do
      expect(page).to have_css("span.comments-count", text: "#{comments.length - 1} comments")
    end

    context "when deleted comment has replies, they are shown" do
      let!(:reply) { create(:comment, commentable: deleted_comment, root_commentable: commentable, body: "Please, delete your comment") }

      it "shows replies of deleted comments" do
        visit resource_path

        within "#comment_#{deleted_comment.id}" do
          expect(page).to have_css("#comment-#{deleted_comment.id}-replies")
          expect(page).to have_content(reply.author.name)
          expect(page).to have_content(reply.body.values.first)
        end
      end
    end
  end

  context "when not authenticated" do
    it "does not show form to add comments to user" do
      visit resource_path
      expect(page).to have_no_css(".add-comment form")
      expect(page).to have_css(".comment-thread")
    end

    context "when user visit a mobile browser" do
      before do
        driven_by(:iphone)
        switch_to_host(organization.host)
        visit decidim.root_path
        click_on "Accept all"
        visit resource_path
      end

      it "does not show the add comment button" do
        expect(page).to have_no_content("Add comment")
      end

      it "shows a message so user can Log in or create an account" do
        expect(page).to have_content("Log in or create an account to add your comment.")
      end
    end
  end

  context "when authenticated" do
    before do
      login_as user, scope: :user
      visit resource_path
    end

    it "shows form to add comments to user" do
      expect(page).to have_css(".add-comment form")
    end

    context "when user visit a computer browser" do
      before do
        switch_to_host(organization.host)
        visit decidim.root_path
        login_as user, scope: :user
        visit resource_path
      end

      it "does not show a modal with form to add comments" do
        expect(page).to have_no_css(".fullscreen")
      end

      it "does not show the add comment button" do
        expect(page).to have_no_content("Add comment")
      end

      it "allows user to comment" do
        find("textarea[name='comment[body]']").set("Test comment with a computer.")
        click_on "Publish comment"
        expect(page).to have_content("Test comment with a computer.")
      end
    end

    context "when user visit a mobile browser" do
      before do
        driven_by(:iphone)
        switch_to_host(organization.host)
        visit decidim.root_path
        click_on "Accept all"
        login_as user, scope: :user
        visit resource_path
      end

      it "shows the add comment button" do
        expect(page).to have_content("Add comment")
      end

      it "does not show a message so user can Log in or create an account" do
        expect(page).to have_no_content("Log in or create an account to add your comment.")
      end

      it "shows a modal with the comment form" do
        sleep 1
        click_on "Add comment"
        sleep 1
        expect(page).to have_content("Add comment")
        expect(page).to have_content("1000 characters left")
        expect(page).to have_css(".add-comment form")
        expect(page).to have_css(".fullscreen")

        find("textarea[name='comment[body]']").set("Test comment with a mobile phone.")
        click_on "Publish comment"
        expect(page).to have_content("Test comment with a mobile phone.")
      end
    end

    context "when user is not authorized to comment" do
      let(:permissions) do
        {
          comment: {
            authorization_handlers: {
              "dummy_authorization_handler" => { "options" => {} }
            }
          }
        }
      end

      before do
        organization.available_authorizations = ["dummy_authorization_handler"]
        organization.save!
        commentable.create_resource_permission(permissions:)
        allow(commentable).to receive(:user_allowed_to_comment?).with(user).and_return(false)
        allow(commentable).to receive(:user_authorized_to_comment?).with(user).and_return(true)
      end

      it "shows a message indicating that comments are restricted" do
        visit resource_path
        expect(page).to have_no_content("Comments are disabled at this time")
        expect(page).to have_content("You need to be verified to comment at this moment")
      end
    end

    describe "when using emojis" do
      before do
        within_language_menu do
          click_on "Castellano"
        end
      end
      shared_examples_for "allowing to select emojis" do
        it "allows selecting emojis" do
          within_language_menu do
            click_on locale
          end

          within ".add-comment form" do
            expect(page).to have_css(".emoji__container")
            expect(page).to have_css(".emoji__trigger .emoji__button")
            find(".emoji__trigger .emoji__button").click
          end

          within ".emoji__decidim" do
            expect(page).to have_content(phrase)
            # Since emoji-mart is a React component, we need to use JS to click on an emoji icon
            # as the emoji picker is a shadow DOM element.
            # The script below is trying to find the first emoji in the "Smileys & People" category and simulate
            # a click from the user on it.
            script = <<~JS
              var emoji_picker = document.getElementsByTagName("em-emoji-picker")[0];
              var category = emoji_picker.shadowRoot.querySelectorAll("div.category")[1]
              category.querySelectorAll("button")[0].click();
            JS
            execute_script(script)
          end

          within ".add-comment form" do
            expect(find("textarea").value.strip).to have_content("😀")
          end
        end
      end

      context "when the locale is supported" do
        let(:locale) { "English" }
        let(:phrase) { I18n.t("emojis.categories.people") }

        it_behaves_like "allowing to select emojis"
      end

      context "when the locale is not supported" do
        let(:locale) { "Català" }
        let(:phrase) { I18n.with_locale(:ca) { I18n.t("emojis.categories.people") } }

        it_behaves_like "allowing to select emojis"
      end
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
        within "form#new_comment_for_#{commentable.commentable_type.demodulize}_#{commentable.id}" do
          field = find("#add-comment-#{commentable.commentable_type.demodulize}-#{commentable.id}")
          field.set " "
          field.native.send_keys "This is a new comment."

          expect(page).to have_content("1977 characters left")
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
          within "form#new_comment_for_#{commentable.commentable_type.demodulize}_#{commentable.id}" do
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
            within "form#new_comment_for_#{commentable.commentable_type.demodulize}_#{commentable.id}" do
              # Test that when reaching the "announce after every" threshold, the
              # characters are announced after every keystroke.
              field = find("#add-comment-#{commentable.commentable_type.demodulize}-#{commentable.id}")
              field.set "a" * 1989
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

            within "form#new_comment_for_#{commentable.commentable_type.demodulize}_#{commentable.id}" do
              expect(page).to have_content("3000 characters left")
            end
          end
        end

        it "let the emoji button works properly when there are not too much characters" do
          if component.present?
            component.update!(settings: { comments_max_length: 100 })
            visit current_path

            within "form#new_comment_for_#{commentable.commentable_type.demodulize}_#{commentable.id}" do
              field = find("#add-comment-#{commentable.commentable_type.demodulize}-#{commentable.id}")
              field.set " "
              field.native.send_keys "toto"
            end

            expect(page).to have_no_css(".emoji__decidim")
            within "form#new_comment_for_#{commentable.commentable_type.demodulize}_#{commentable.id}" do
              find(".emoji__button").click
            end
            expect(page).to have_css(".emoji__decidim")
          end
        end

        it "deactivate the emoji button when there are less than 4 characters left" do
          if component.present?
            component.update!(settings: { comments_max_length: 30 })
            visit current_path

            within "form#new_comment_for_#{commentable.commentable_type.demodulize}_#{commentable.id}" do
              field = find("#add-comment-#{commentable.commentable_type.demodulize}-#{commentable.id}")
              field.set " "
              field.native.send_keys("0123456789012345678901234567")
              find(".emoji__button").click
            end
            expect(page).to have_no_css(".emoji-picker__picker.emoji-picker__picker")
          end
        end
      end
    end

    context "when user adds a new comment" do
      let(:content) { "This is a new comment" }

      before do
        within "form#new_comment_for_#{commentable.commentable_type.demodulize}_#{commentable.id}" do
          field = find("#add-comment-#{commentable.commentable_type.demodulize}-#{commentable.id}")
          field.set " "
          field.native.send_keys content
          click_on "Publish comment"
        end
      end

      it "shows comment to the user, updates the comments counter and clears the comment textarea" do
        expect(page).to have_comment_from(user, content, wait: 20)
        expect(page).to have_css("span.comments-count", text: "#{commentable.comments.count} comments")
        expect(page.find("#add-comment-#{commentable.commentable_type.demodulize}-#{commentable.id}").value).to be_empty
      end

      it "shows the entry in last activities" do
        visit decidim.last_activities_path
        expect(page).to have_content("New comment: #{content}")

        within "#filters" do
          find("a", class: "filter", text: "Comment", match: :first).click
        end
        expect(page).to have_content("New comment: #{content}")
      end
    end

    context "when user adds a new comment with a link" do
      let(:content) { "Very nice http://www.debian.org linux distro" }

      before do
        within "form#new_comment_for_#{commentable.commentable_type.demodulize}_#{commentable.id}" do
          field = find("#add-comment-#{commentable.commentable_type.demodulize}-#{commentable.id}")
          field.set " "
          field.native.send_keys content
          click_on "Publish comment"
        end
      end

      it "adds external link css" do
        expect(page).to have_css("a", text: "http://www.debian.org")
        within("a", text: "http://www.debian.org") do
          expect(page).to have_text "(External link)"
        end
      end

      it "changes link to point to /link" do
        expect(page).to have_link("http://www.debian.org", href: "/link?external_url=http%3A%2F%2Fwww.debian.org%2F")
      end
    end

    context "when the user is writing a new comment while someone else comments" do
      let(:new_comment_body) { "Hey, I just jumped in the conversation!" }
      let(:new_comment) { build(:comment, commentable:, body: new_comment_body) }
      let(:content) { "This is a new comment" }

      before do
        within "form#new_comment_for_#{commentable.commentable_type.demodulize}_#{commentable.id}" do
          field = find("#add-comment-#{commentable.commentable_type.demodulize}-#{commentable.id}")
          field.set " "
          field.native.send_keys content
        end
        new_comment.save!
      end

      it "does not clear the current user's comment" do
        expect(page).to have_content(new_comment.body.values.first, wait: 20)
        expect(page.find("#add-comment-#{commentable.commentable_type.demodulize}-#{commentable.id}").value).to include(content)
      end

      context "when user can hide replies on a thread" do
        let(:thread) { comments.first }
        let(:new_reply_body) { "Hey, I just jumped inside the thread!" }
        let!(:new_reply) { create(:comment, commentable: thread, root_commentable: commentable, body: new_reply_body) }

        it "displays a way to to display content" do
          visit current_path
          within "#comment_#{thread.id}" do
            expect(page).to have_content("1 answer")
            click_on "1 answer"
            expect(page).to have_content(new_reply_body)
            click_on "Reply", match: :first
            expect(page).to have_content("Publish reply")
            find("textarea[name='comment[body]']").set("Test reply comments.")
            click_on "Publish reply"
            expect(page).to have_content("Show 2 replies")
            click_on "Show 2 replies"
            expect(page).to have_content("Test reply comments.")
          end
        end

        it "displays a way hide content" do
          visit current_path
          within "#comment_#{thread.id}" do
            expect(page).to have_content("1 answer")
            click_on "1 answer"
            expect(page).to have_content("1 answer")
            click_on "1 answer"
            expect(page).to have_no_content(new_reply_body)
          end
        end

        context "when are more replies" do
          let!(:new_replies) { create_list(:comment, 2, commentable: thread, root_commentable: commentable, body: new_reply_body) }

          it "displays the show button" do
            visit current_path
            within "#comment_#{thread.id}" do
              expect(page).to have_content("3 answers")
              expect(page).to have_no_content(new_reply_body)
              click_on "3 answers"
              expect(page).to have_content(new_reply_body)
            end
          end
        end
      end

      context "when inside a thread reply form" do
        let(:thread) { comments.first }
        let(:new_reply_body) { "Hey, I just jumped inside the thread!" }
        let(:new_reply) { build(:comment, commentable: thread, root_commentable: commentable, body: new_reply_body) }
        let(:reply_content) { "This is a new reply" }

        before do
          within "div#comment_#{thread.id}" do
            find("span", text: "Reply").click
          end

          within "form#new_comment_for_#{thread.commentable_type.demodulize}_#{thread.id}" do
            field = find("#add-comment-#{thread.commentable_type.demodulize}-#{thread.id}")
            field.set " "
            field.native.send_keys reply_content
          end
          new_reply.save!
        end

        it "does not clear the current user's comment" do
          expect(page).to have_content(new_reply.body.values.first, wait: 20)
          expect(page.find("#add-comment-#{commentable.commentable_type.demodulize}-#{commentable.id}").value).to include(content)
          expect(page.find("#add-comment-#{thread.commentable_type.demodulize}-#{thread.id}").value).to include(reply_content)
        end
      end
    end

    context "when a user deletes a comment" do
      let(:comment_body) { "This comment is a mistake" }
      let!(:comment) { create(:comment, body: comment_body, commentable:, author: comment_author) }

      before do
        visit resource_path
      end

      context "when the comment is not authored by user" do
        let!(:comment_author) { create(:user, :confirmed, organization:) }

        it "the context menu of the comment does not show a delete link" do
          within "#comment_#{comment.id}" do
            page.find("[id^='dropdown-trigger']").click
            expect(page).to have_no_link("Delete")
          end
        end
      end

      context "when the comment is authored by user" do
        let(:comment_author) { user }

        it "the context menu of the comment shows a delete link" do
          within "#comment_#{comment.id}" do
            page.find("[id^='dropdown-trigger']").click
            expect(page).to have_link("Delete")
          end
        end

        it "the user can delete the comment and updates the comments counter" do
          expect(Decidim::Comments::Comment.not_deleted.count).to eq(4)

          within "#comment_#{comment.id}" do
            page.find("[id^='dropdown-trigger']").click
            click_on "Delete"
          end

          accept_confirm

          expect(page).to have_css("#comment_#{comment.id}")
          within "#comment_#{comment.id}" do
            expect(page).to have_content("Comment deleted on")
            expect(page).to have_no_content comment_author.name
            expect(page).to have_no_css(".comment__header")
          end
          expect(page).to have_css("span.comments-count", text: "3 comments")

          expect(Decidim::Comments::Comment.not_deleted.count).to eq(3)
        end
      end
    end

    context "when a user edits a comment" do
      let(:comment_body) { "This coment has a typo" }
      let!(:comment) { create(:comment, body: comment_body, commentable:, author: comment_author) }

      before do
        visit resource_path
      end

      context "when the comment is not authored by user" do
        let!(:comment_author) { create(:user, :confirmed, organization:) }

        it "the context menu of the comment does not show an edit button" do
          within "#comment_#{comment.id}" do
            # Toolbar
            page.find("[id^='dropdown-trigger']").click
            expect(page).to have_no_button("Edit")
          end
        end
      end

      context "when the comment is authored by user" do
        let!(:comment_author) { user }

        it "the context menu of the comment show an edit button" do
          within "#comment_#{comment.id}" do
            # Toolbar
            page.find("[id^='dropdown-trigger']").click
            expect(page).to have_button("Edit")
          end
        end

        context "when the user edits a comment" do
          before do
            within "#comment_#{comment.id}" do
              # Toolbar
              page.find("[id^='dropdown-trigger']").click
              click_on "Edit"
            end
            fill_in "edit_comment_#{comment.id}", with: " This comment has been fixed"
            click_on "Send"
          end

          it "the comment body changes" do
            within "#comment_#{comment.id}" do
              expect(page).to have_content("This comment has been fixed")
              expect(page).to have_no_content(comment_body)
            end
          end

          it "the header of the comment displays an edited message" do
            within "#comment_#{comment.id}" do
              expect(page).to have_content("Edited")
            end
          end

          it "has only one edit modal" do
            expect(page).to have_css("#editCommentModal#{comment.id}", visible: :hidden, count: 1)
            3.times do |index|
              sleep 2
              within "#comment_#{comment.id}" do
                page.find("[id^='dropdown-trigger']").click
                click_on "Edit"
              end
              fill_in "edit_comment_#{comment.id}", with: " This comment has been edited #{1 + index} times"
              click_on "Send"
            end
            expect(page).to have_css("#editCommentModal#{comment.id}", visible: :all, count: 1)
          end
        end
      end
    end

    context "when a user replies to a comment", :slow do
      let!(:comment_author) { create(:user, :confirmed, organization:) }
      let!(:comment) { create(:comment, commentable:, author: comment_author) }
      let(:content) { "This is a reply" }

      it "shows reply to the user" do
        visit resource_path

        within "#comments #comment_#{comment.id}" do
          click_on "Reply"
        end

        expect(page).to have_css("#comment_#{comment.id} .add-comment")

        within "form#new_comment_for_#{comment.commentable_type.demodulize}_#{comment.id}" do
          field = find("#add-comment-#{comment.commentable_type.demodulize}-#{comment.id}")
          field.set " "
          field.native.send_keys content
          click_on "Publish reply"
        end

        expect(page).to have_reply_to(comment, content)
        expect(page).to have_css("span.comments-count", text: "#{commentable.comments.count} comments")
        expect(page).to have_reply_to(comment, "This is a reply")
      end
    end

    context "when a comment has been moderated" do
      let!(:parent) { create(:comment, commentable:) }
      let!(:reply) { create(:comment, commentable: parent, root_commentable: commentable) }

      it "does not show additional reply" do
        Decidim::Moderation.create!(reportable: reply, participatory_space: reply.participatory_space, hidden_at: 1.day.ago)

        visit current_path

        within "#comments #comment_#{parent.id}" do
          expect(page).to have_css("#comment-#{parent.id}-replies")
          expect(page.find("#comment-#{parent.id}-replies").text).to be_blank
        end
      end
    end

    describe "arguable option" do
      context "when commenting with alignment" do
        before do
          visit resource_path

          expect(page).to have_css(".add-comment form")
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
              expect(page).to have_css(".js-comment__votes--up", text: /0/)
              page.find(".js-comment__votes--up").click
              expect(page).to have_css(".js-comment__votes--up", text: /1/)
            else
              expect(page).to have_no_css(".js-comment__votes--up", text: /0/)
            end
          end
        end

        context "when the comment has a thread" do
          let!(:comment_on_comment) { create(:comment, :comment_on_comment, commentable: comments[0], root_commentable: comments[0].commentable) }

          it "does not increase the votes for the children of the upvoting comment" do
            skip "Commentable comments has no votes" unless commentable.comments_have_votes?

            visit current_path
            expect(page).to have_css("#comment_#{comments[0].id} > [data-comment-footer] > .comment__footer-grid .comment__votes .js-comment__votes--up", text: /0/, visible: :all)
            page.find("#comment_#{comments[0].id} > [data-comment-footer] > .comment__footer-grid .comment__votes .js-comment__votes--up").click
            expect(page).to have_css("#comment_#{comments[0].id} > [data-comment-footer] > .comment__footer-grid .comment__votes .js-comment__votes--up", text: /1/, visible: :all)
            expect(page).to have_css("#comment_#{comment_on_comment.id} > [data-comment-footer] >.comment__footer-grid .comment__votes .js-comment__votes--up", text: /0/,
                                                                                                                                                                visible: :all)
          end
        end
      end

      context "when downvoting a comment" do
        it "works according to the setting in the commentable" do
          within "#comment_#{comments[0].id}" do
            if commentable.comments_have_votes?
              expect(page).to have_css(".js-comment__votes--down", text: /0/)
              page.find(".js-comment__votes--down").click
              expect(page).to have_css(".js-comment__votes--down", text: /1/)
            else
              expect(page).to have_no_css(".js-comment__votes--down", text: /0/)
            end
          end
        end
      end
    end

    describe "mentions drop-down", :slow do
      before do
        visit resource_path

        within "form#new_comment_for_#{commentable.commentable_type.demodulize}_#{commentable.id}" do
          field = find("#add-comment-#{commentable.commentable_type.demodulize}-#{commentable.id}")
          field.set " "
          field.native.send_keys content
        end
      end

      context "when mentioning a valid user" do
        let!(:mentioned_user) { create(:user, :confirmed, organization:) }
        let(:content) { "A valid user mention: @#{mentioned_user.nickname}" }

        context "when text finish with a mention" do
          it "shows the tribute container" do
            expect(page).to have_css(".tribute-container", text: mentioned_user.name, wait: 10)
          end
        end

        context "when text contains a mention" do
          let(:content) { "A valid user mention: @#{mentioned_user.nickname}." }

          it "shows the tribute container" do
            expect(page).to have_no_css(".tribute-container", text: mentioned_user.name)
          end
        end
      end

      context "when mentioning a non valid user" do
        let!(:mentioned_user) { create(:user, organization:) }
        let(:content) { "A unconfirmed user mention: @#{mentioned_user.nickname}" }

        it "do not show the tribute container" do
          expect(page).to have_no_css(".tribute-container", text: mentioned_user.name)
        end
      end
    end

    describe "mentions", :slow do
      before do
        visit resource_path

        within "form#new_comment_for_#{commentable.commentable_type.demodulize}_#{commentable.id}" do
          field = find("#add-comment-#{commentable.commentable_type.demodulize}-#{commentable.id}")
          field.set " "
          field.native.send_keys content
          click_on "Publish comment"
        end
      end

      context "when mentioning a valid user" do
        let!(:mentioned_user) { create(:user, :confirmed, organization:) }
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
          expect(page).to have_no_link "@#{mentioned_user.nickname}"
        end
      end

      context "when mentioning a non valid user" do
        let(:content) { "This text mentions a @nonexistent user" }

        it "ignores the mention" do
          expect(page).to have_comment_from(user, "This text mentions a @nonexistent user", wait: 20)
          expect(page).to have_no_link "@nonexistent"
        end
      end
    end

    describe "hashtags", :slow do
      let(:content) { "A comment with a hashtag #decidim" }

      before do
        visit resource_path

        within "form#new_comment_for_#{commentable.commentable_type.demodulize}_#{commentable.id}" do
          field = find("#add-comment-#{commentable.commentable_type.demodulize}-#{commentable.id}")
          field.set " "
          field.native.send_keys content
          click_on "Publish comment"
        end
      end

      it "replaces the hashtag with a link to the hashtag search" do
        expect(page).to have_comment_from(user, "A comment with a hashtag #decidim", wait: 20)
        expect(page).to have_link "#decidim", href: "/search?term=%23decidim"
      end
    end

    describe "export_serializer" do
      let(:comment) { comments.first }

      it "returns the serializer for the comment" do
        expect(comment.class.export_serializer).to eq(Decidim::Comments::CommentSerializer)
      end

      context "with instance" do
        subject { comment.class.export_serializer.new(comment).serialize }

        it { is_expected.to have_key(:id) }
        it { is_expected.to have_key(:created_at) }
        it { is_expected.to have_key(:body) }
        it { is_expected.to have_key(:locale) }
        it { is_expected.to have_key(:author) }
        it { is_expected.to have_key(:alignment) }
        it { is_expected.to have_key(:depth) }
        it { is_expected.to have_key(:commentable_id) }
        it { is_expected.to have_key(:commentable_type) }
        it { is_expected.to have_key(:root_commentable_url) }
      end
    end
  end
end

shared_examples "comments blocked" do
  context "when not authenticated" do
    context "when comments are blocked" do
      let(:active_step_id) { component.participatory_space.active_step.id }

      before do
        component.update!(step_settings: { active_step_id => { comments_blocked: true } })
      end

      it "shows a message indicating that comments are disabled" do
        visit resource_path
        expect(page).to have_content("Comments are currently disabled, only administrators can reply or post new ones.")
        expect(page).to have_no_content("You need to be verified to comment at this moment")
      end
    end
  end

  context "when authenticated" do
    let!(:user) { create(:user, :confirmed, organization:) }
    let!(:comments) { create_list(:comment, 3, commentable:) }

    before do
      login_as user, scope: :user
      visit resource_path
    end

    shared_examples "can answer comments" do
      it "can answer" do
        visit resource_path
        expect(page).to have_link("Comment")
        page.find("a", text: "Comment").click
        find("textarea[name='comment[body]']").set("Test admin commenting in a closed comment.")
        click_on "Publish comment"
        expect(page).to have_content("Test admin commenting in a closed comment.")

        expect(page).to have_button("Reply")
        first("button", text: "Reply").click
        expect(page).to have_css(".comment-thread")
        within first(".comment-thread") do
          find("textarea[name='comment[body]']").set("Test admin replying a closed comment.")
          click_on "Publish reply"
        end
        expect(page).to have_content("Test admin replying a closed comment.")
      end
    end

    context "when comments are blocked" do
      let(:active_step_id) { component.participatory_space.active_step.id }

      before do
        component.update!(step_settings: { active_step_id => { comments_blocked: true } })
      end

      it "shows a message indicating that comments are disabled" do
        visit resource_path
        expect(page).to have_content("Comments are currently disabled, only administrators can reply or post new ones.")
        expect(page).to have_no_content("You need to be verified to comment at this moment")
      end

      context "when the user is an administrator" do
        let!(:user) { create(:user, :admin, :confirmed, organization:) }

        it_behaves_like "can answer comments"
      end

      context "when the user has a role of user manager" do
        let!(:user) { create(:user, :user_manager, :confirmed, organization:) }

        it_behaves_like "can answer comments"
      end

      context "when the user has an evaluator role in the same participatory space" do
        let!(:evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user:, participatory_process: participatory_space) }

        it_behaves_like "can answer comments"
      end

      shared_examples "evaluator role in different participatory space" do |space_type|
        let!(:another_space_evaluator_role) do
          create(:"#{space_type}_user_role", role: :evaluator, user:, "#{space_type}": create(space_type, organization:))
        end

        it "cannot answer" do
          visit resource_path
          expect(page).to have_content("Comments are currently disabled, only administrators can reply or post new ones.")
          expect(page).to have_no_content("You need to be verified to comment at this moment")
          expect(page).to have_no_css("textarea#add-comment-Proposal-1")
        end
      end

      context "when the user has an evaluator role in a different participatory space" do
        include_examples "evaluator role in different participatory space", :participatory_process
        include_examples "evaluator role in different participatory space", :conference
        include_examples "evaluator role in different participatory space", :assembly
      end
    end
  end
end

shared_examples "comments with two columns" do
  let!(:user) { create(:user, :confirmed, organization:) }

  before do
    login_as user, scope: :user
  end

  context "displays comments list in two columns" do
    let!(:comments_in_favor) { create_list(:comment, 2, :in_favor, commentable:) }
    let!(:comments_against) { create_list(:comment, 1, :against, commentable:) }

    it "shows the list of comments for the resource" do
      visit resource_path

      expect(page).to have_css("#comments")
      expect(page).to have_css(".comment", count: comments.length)

      within(".comments-two-columns") do
        check_comments_order(".comments-section__in-favor", comments_in_favor)
        check_comments_order(".comments-section__against", comments_against)
      end
    end
  end

  context "in mobile view" do
    it "shows kebab menu functionality" do
      resize_window_to_mobile
      visit resource_path

      within "#comment_#{comments.first.id}" do
        page.find("[id^='dropdown-trigger']").click
        expect(page).to have_css("ul.dropdown.dropdown__bottom", visible: :visible)
      end

      resize_window_to_desktop
    end

    context "when commentable is closed" do
      let!(:commentable) { closed_commentable }
      let!(:highest_voted_comment_in_favor) { create(:comment, :in_favor, commentable:, created_at: 2.days.ago, up_votes_count: 15) }
      let!(:high_voted_comment_in_favor) { create(:comment, :in_favor, commentable:, created_at: 4.days.ago, up_votes_count: 10) }
      let!(:older_comment_in_favor) { create(:comment, :in_favor, commentable:, created_at: 3.days.ago, up_votes_count: 5) }

      let!(:highest_voted_comment_against) { create(:comment, :against, commentable:, created_at: 2.days.ago, up_votes_count: 12) }
      let!(:high_voted_comment_against) { create(:comment, :against, commentable:, created_at: 5.days.ago, up_votes_count: 8) }
      let!(:older_comment_against) { create(:comment, :against, commentable:, created_at: 3.days.ago, up_votes_count: 4) }

      it "shows comments with top comments at the beginning and interleaved order after" do
        resize_window_to_mobile
        visit resource_path

        within(".comment-threads") do
          interleaved_comments = [
            highest_voted_comment_in_favor,
            highest_voted_comment_against,
            high_voted_comment_in_favor,
            high_voted_comment_against,
            older_comment_in_favor,
            older_comment_against
          ]

          all_comments = all(".comment-thread")

          interleaved_comments.each_with_index do |comment, index|
            expect(all_comments[index]).to have_content(comment.body["en"])
          end

          expect(page).to have_css(".most-upvoted-label", text: "Most upvoted", count: 2)
        end

        resize_window_to_desktop
      end
    end
  end

  context "when viewing a single comment" do
    let!(:single_comment) { create(:comment, commentable:, body: { "en" => "This is a single comment" }) }

    before do
      visit "#{resource_locator(commentable).path}?commentId=#{single_comment.id}"
    end

    it "displays only the single comment without columns" do
      expect(page).to have_css("#comments")
      expect(page).to have_css(".comment-thread", count: 1)
      expect(page).to have_content("This is a single comment")
      expect(page).to have_no_css(".comments-two-columns")
      expect(page).to have_no_content("In Favor")
      expect(page).to have_no_content("Against")
      expect(page).to have_no_content("You are viewing only one comment")
    end
  end

  context "when commentable is not closed" do
    let!(:oldest_in_favor_comment) { create(:comment, :in_favor, commentable:, created_at: 3.days.ago) }
    let!(:older_in_favor_comment) { create(:comment, :in_favor, commentable:, created_at: 2.days.ago) }
    let!(:oldest_against_comment) { create(:comment, :against, commentable:, created_at: 4.days.ago) }
    let!(:newer_against_comment) { create(:comment, :against, commentable:, created_at: 1.day.ago) }

    it "shows the comments in two columns sorted by creation date in ascending order" do
      visit resource_path

      within(".comments-two-columns") do
        check_comments_order(".comments-section__in-favor", [oldest_in_favor_comment, older_in_favor_comment])
        check_comments_order(".comments-section__against", [oldest_against_comment, newer_against_comment])
      end
    end

    it "allows the user to add a new comment at the end of the respective column" do
      visit resource_path

      add_new_comment("In favor", "This is a new comment in favor")

      within(".comments-section__in-favor") do
        expect(page).to have_content("This is a new comment in favor")
      end
    end

    it "disables the publish button until 'in favor' or 'against' is selected" do
      visit resource_path

      expect(page).to have_button("Publish comment", disabled: true)

      within(".comment__opinion-container") do
        click_on "In favor"
      end

      within "form#new_comment_for_#{commentable.commentable_type.demodulize}_#{commentable.id}" do
        fill_in_comment_field("This is a new comment in favor")
        click_on "Publish comment"
      end
    end

    it "shows comments sorted by creation date when viewed on a small screen" do
      resize_window_to_mobile
      visit resource_path

      within(".comment-threads") do
        comments = all(".comment-thread")

        expect(comments[0]).to have_content(oldest_in_favor_comment.body["en"])
        expect(comments[1]).to have_content(oldest_against_comment.body["en"])
        expect(comments[2]).to have_content(older_in_favor_comment.body["en"])
        expect(comments[3]).to have_content(newer_against_comment.body["en"])
      end

      resize_window_to_desktop
    end
  end

  context "when commentable is closed" do
    let!(:commentable) { closed_commentable }
    let!(:highest_voted_comment_in_favor) { create(:comment, :in_favor, commentable:, created_at: 2.days.ago, up_votes_count: 15) }
    let!(:high_voted_comment_in_favor) { create(:comment, :in_favor, commentable:, created_at: 4.days.ago, up_votes_count: 10) }
    let!(:older_comment_in_favor) { create(:comment, :in_favor, commentable:, created_at: 3.days.ago, up_votes_count: 5) }
    let!(:recent_comment_in_favor) { create(:comment, :in_favor, commentable:, created_at: 2.days.ago, up_votes_count: 3) }
    let!(:latest_comment_in_favor) { create(:comment, :in_favor, commentable:, created_at: 1.day.ago, up_votes_count: 1) }

    let!(:highest_voted_comment_against) { create(:comment, :against, commentable:, created_at: 2.days.ago, up_votes_count: 12) }
    let!(:high_voted_comment_against) { create(:comment, :against, commentable:, created_at: 5.days.ago, up_votes_count: 8) }
    let!(:older_comment_against) { create(:comment, :against, commentable:, created_at: 3.days.ago, up_votes_count: 4) }
    let!(:recent_comment_against) { create(:comment, :against, commentable:, created_at: 2.days.ago, up_votes_count: 2) }
    let!(:latest_comment_against) { create(:comment, :against, commentable:, created_at: 1.day.ago, up_votes_count: 1) }

    before do
      visit resource_path
    end

    it "shows the top voted comments at the top of each column, followed by comments in ascending chronological order" do
      within(".comments-two-columns") do
        check_comments_order(".comments-section__in-favor", [
                               highest_voted_comment_in_favor,
                               high_voted_comment_in_favor,
                               older_comment_in_favor,
                               recent_comment_in_favor,
                               latest_comment_in_favor
                             ])

        check_comments_order(".comments-section__against", [
                               highest_voted_comment_against,
                               high_voted_comment_against,
                               older_comment_against,
                               recent_comment_against,
                               latest_comment_against
                             ])
      end
    end

    it "shows the top voted comments with label at the top of each column" do
      within(".comments-two-columns") do
        within(".comments-section__in-favor") do
          expect(page).to have_css(".most-upvoted-label", text: "Most upvoted")
          expect(page).to have_content(highest_voted_comment_in_favor.body["en"])
        end

        within(".comments-section__against") do
          expect(page).to have_css(".most-upvoted-label", text: "Most upvoted")
          expect(page).to have_content(highest_voted_comment_against.body["en"])
        end
      end
    end
  end

  def check_comments_order(section_selector, comments)
    comments_section = all("#{section_selector} .comment-thread")
    comments.each_with_index do |comment, index|
      expect(comments_section[index]).to have_content(comment.body["en"])
    end
  end

  def add_new_comment(opinion, comment_text)
    within(".comment__opinion-container") do
      click_on opinion
    end

    within "form#new_comment_for_#{commentable.commentable_type.demodulize}_#{commentable.id}" do
      fill_in_comment_field(comment_text)
      click_on "Publish comment"
    end
  end

  def fill_in_comment_field(comment_text)
    field = find("#add-comment-#{commentable.commentable_type.demodulize}-#{commentable.id}")
    field.set " "
    field.native.send_keys comment_text
  end

  def resize_window_to_mobile
    page.driver.browser.manage.window.resize_to(375, 667)
  end

  def resize_window_to_desktop
    page.driver.browser.manage.window.resize_to(1920, 1080)
  end
end
