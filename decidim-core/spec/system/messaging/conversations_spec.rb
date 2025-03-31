# frozen_string_literal: true

require "spec_helper"

describe "Conversations" do
  let!(:organization) { create(:organization, twitter_handler: "organization") }
  let(:user) { create(:user, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when user has no conversations" do
    before { visit_inbox }

    it_behaves_like "accessible page"

    it "shows a notice informing about that" do
      expect(page).to have_content("You have no conversations yet")
    end

    it "shows the topbar button as inactive" do
      within "#trigger-dropdown-account" do
        expect(page).to have_no_selector("span[data-unread-items]")
      end
    end
  end

  shared_examples "create new conversation" do
    it "allows sending an initial message", :slow do
      start_conversation("Is this a Ryanair style democracy?")
      expect(page).to have_css(".conversation__message:last-child", text: "Is this a Ryanair style democracy?")
    end

    it "redirects to an existing conversation if it exists already", :slow do
      start_conversation("Is this a Ryanair style democracy?")
      expect(page).to have_css(".conversation__message:last-child", text: "Is this a Ryanair style democracy?")

      visit decidim.new_conversation_path(recipient_id: recipient.id)
      expect(page).to have_css(".conversation__message:last-child", text: "Is this a Ryanair style democracy?")
    end
  end

  context "when starting a conversation" do
    let(:recipient) { create(:user, organization:) }

    before do
      visit decidim.new_conversation_path(recipient_id: recipient.id)
    end

    it_behaves_like "accessible page"

    it "shows an empty conversation page" do
      expect(page).to have_no_selector(".card--list__item")
      expect(page).to have_current_path decidim.new_conversation_path(recipient_id: recipient.id)
    end

    it_behaves_like "conversation field with maximum length", "conversation_body"

    it_behaves_like "create new conversation"

    context "and recipient has restricted communications" do
      let(:recipient) { create(:user, direct_message_types: "followed-only", organization:) }

      context "and recipient does not follow user" do
        it "redirects user with access error" do
          expect(page).to have_no_current_path decidim.new_conversation_path(recipient_id: recipient.id)
          expect(page).to have_content("You are not authorized to perform this action")
        end

        context "and a conversation exists already" do
          let!(:conversation) do
            Decidim::Messaging::Conversation.start!(
              originator: user,
              interlocutors: [recipient],
              body: "Is this a Ryanair style democracy?"
            )
          end

          it "redirects to the existing conversation" do
            visit decidim.new_conversation_path(recipient_id: recipient.id)
            expect(page).to have_css(".conversation__message:last-child", text: "Is this a Ryanair style democracy?")
          end
        end
      end

      context "and recipient follows user" do
        let!(:follow) { create(:follow, user: recipient, followable: user) }

        before do
          visit decidim.new_conversation_path(recipient_id: recipient.id)
        end

        it_behaves_like "create new conversation"
      end
    end
  end

  context "when user has conversations" do
    let(:interlocutor) { create(:user, :confirmed, organization:) }

    let!(:conversation) do
      Decidim::Messaging::Conversation.start!(
        originator: user,
        interlocutors: [interlocutor],
        body: "who wants apples?"
      )
    end

    it_behaves_like "accessible page" do
      before { visit_inbox }
    end

    it "shows user's conversation list" do
      visit_inbox

      expect(page).to have_css(".conversation__item img[alt='Avatar: #{interlocutor.name}']")
      expect(page).to have_css(".conversation__item", text: "who wants apples?")
    end

    it "allows entering a conversation" do
      visit_inbox
      click_on "conversation-#{conversation.id}"

      expect(page).to have_content("Conversation with\n#{interlocutor.name}")
      expect(page).to have_content("who wants apples?")
    end

    context "and some of them are unread" do
      before do
        conversation.add_message!(sender: interlocutor, body: "I want one")

        visit_inbox
      end

      it "shows the topbar button as active" do
        within "#trigger-dropdown-account" do
          expect(page).to have_css("span[data-unread-items]")
        end
      end

      it "shows the number of unread messages per conversation" do
        expect(page).to have_css(".conversation__item-unread", text: "1")
      end
    end

    context "and they are read" do
      before { visit_inbox }

      it "shows the topbar button as inactive" do
        within "#trigger-dropdown-account" do
          expect(page).to have_no_selector("span[data-unread-items]")
        end
      end

      it "does not show an unread count" do
        expect(page).to have_css(".conversation__item-unread", text: "")
      end
    end

    context "when a message is sent" do
      let(:message_body) { "Please reply!" }

      before do
        visit_inbox
        click_on "conversation-#{conversation.id}"
        expect(page).to have_content("Send")
        field = find_field("message_body")
        field.native.send_keys message_body
      end

      it "appears as the last message", :slow do
        click_on "Send"
        expect(page).to have_css(".conversation__message:last-child", text: message_body)
      end

      context "and interlocutor sees it" do
        before do
          click_on "Send"
          expect(page).to have_css(".conversation__message:last-child", text: message_body)
          relogin_as interlocutor, scope: :user
          visit_inbox
        end

        it "appears as unread", :slow do
          expect(page).to have_css(".conversation__item-unread", text: "2")
        end

        it "appears as read after it is seen", :slow do
          click_on "conversation-#{conversation.id}"
          expect(page).to have_content("Please reply!")

          visit_inbox
          expect(page).to have_css(".conversation__item-unread", text: "")
        end
      end
    end

    context "when message is too long" do
      let(:message_body) { message + overflow }
      let(:message) { Faker::Lorem.paragraph_by_chars(number: max_length) }
      let(:overflow) { "This should not be included in the message" }
      let(:max_length) { Decidim.config.maximum_conversation_message_length }

      it "shows the error message modal", :slow do
        visit_inbox
        click_on "conversation-#{conversation.id}"
        expect(page).to have_content("Send")
        field = find_field("message_body")
        field.native.send_keys message_body
        expect(page).to have_content("0 characters left")
        click_on "Send"
        expect(page).to have_content(message)
        expect(page).to have_no_content(overflow)
      end
    end

    context "when interlocutor has restricted conversations" do
      let(:interlocutor) { create(:user, :confirmed, direct_message_types: "followed-only", organization:) }

      context "and interlocutor does not follow user" do
        before do
          visit_inbox
          click_on "conversation-#{conversation.id}"
        end

        it "allows user to see old messages" do
          expect(page).to have_content("Conversation with\n#{interlocutor.name}")
          expect(page).to have_content("who wants apples?")
        end

        it "does not show the sending form" do
          expect(page).to have_no_selector("textarea#message_body")
        end
      end

      context "and interlocutor follows user" do
        let!(:follow) { create(:follow, user: interlocutor, followable: user) }

        before do
          visit_inbox
          click_on "conversation-#{conversation.id}"
        end

        it "show the sending form" do
          expect(page).to have_css("textarea#message_body")
        end

        it "sends a message", :slow do
          field = find_field("message_body")
          field.native.send_keys "Please reply!"

          expect(page).to have_content("Send")
          click_on "Send"

          expect(page).to have_css(".conversation__message:last-child", text: "Please reply!")
        end
      end
    end

    context "when visiting recipient's profile page" do
      let(:recipient) { create(:user, :confirmed, organization:) }

      before do
        visit decidim.profile_path(recipient.nickname)
      end

      it "has a contact link" do
        expect(page).to have_link(title: "Message", href: decidim.new_conversation_path(recipient_id: recipient.id))
      end

      context "and recipient has restricted communications" do
        let(:recipient) { create(:user, :confirmed, direct_message_types: "followed-only", organization:) }

        it "has contact muted" do
          expect(page).to have_no_link(href: decidim.new_conversation_path(recipient_id: recipient.id))
        end
      end
    end

    describe "on mentioned list" do
      context "when someone direct messages disabled" do
        let!(:interlocutor2) { create(:user, :confirmed, organization:, direct_message_types: "followed-only") }

        it "cannot be selected on the mentioned list", :slow do
          visit_inbox
          expect(page).to have_content("New conversation")
          click_on "New conversation"
          expect(page).to have_css("#add_conversation_users")
          field = find_by_id("add_conversation_users")
          field.set ""
          field.native.send_keys "@#{interlocutor2.nickname.slice(0, 3)}"
          expect(page).to have_css("#autoComplete_list_1 li.disabled", wait: 5)
        end
      end
    end
  end

  describe "when having a conversation with multiple participants" do
    context "and it is with only one participant" do
      let(:user1) { create(:user, organization:) }
      let!(:conversation2) do
        Decidim::Messaging::Conversation.start!(
          originator: user,
          interlocutors: [user1],
          body: "Hi!"
        )
      end

      context "when starting the conversation" do
        before do
          visit decidim.new_conversation_path(recipient_id: user1.id)
        end

        it "shows only the other participant name" do
          within ".conversation__participants" do
            expect(page).to have_content(user1.name)
            expect(page).to have_no_content(user.name)
          end
        end
      end

      context "when going to the conversation" do
        before do
          visit decidim.conversation_path(id: conversation2.id)
        end

        it "shows only the other participant name" do
          within ".conversation__participants" do
            expect(page).to have_content(user1.name)
          end
        end
      end

      context "when listing the conversations" do
        before do
          visit decidim.conversations_path
        end

        it "shows only the other participant name" do
          within "[data-interlocutors-list]" do
            expect(page).to have_content(user1.name)
            expect(page).to have_no_content(user.name)
          end
        end
      end
    end

    context "and it is with four participants" do
      let(:user1) { create(:user, organization:) }
      let(:user2) { create(:user, organization:) }
      let(:user3) { create(:user, organization:) }
      let!(:conversation4) do
        Decidim::Messaging::Conversation.start!(
          originator: user,
          interlocutors: [user1, user2, user3],
          body: "Hi all 4 people!"
        )
      end

      context "when starting the conversation" do
        before do
          visit decidim.new_conversation_path(recipient_id: [
                                                user1.id, user2.id, user3.id
                                              ])
        end

        it "shows the other three participants names" do
          within ".conversation__participants" do
            expect(page).to have_content(user1.name)
            expect(page).to have_content(user2.name)
            expect(page).to have_content(user3.name)
            expect(page).to have_no_content(user.name)
          end
        end
      end

      context "when going to the conversation" do
        before do
          visit decidim.conversation_path(id: conversation4.id)
        end

        it "shows the other three participants names" do
          within ".conversation__participants" do
            expect(page).to have_content(user1.name)
            expect(page).to have_content(user2.name)
            expect(page).to have_content(user3.name)
            expect(page).to have_no_content(user.name)
          end
        end
      end

      context "when listing the conversations" do
        before do
          visit decidim.conversations_path
        end

        it "shows only the 3 other participant avatars" do
          within "[data-interlocutors-list]" do
            expect(page).to have_css("img[alt='Avatar: #{user1.name}']")
            expect(page).to have_css("img[alt='Avatar: #{user2.name}']")
            expect(page).to have_css("img[alt='Avatar: #{user3.name}']")
            expect(page).to have_no_css("img[alt='Avatar: #{user.name}']")
          end
        end
      end
    end

    context "and it is with ten participants" do
      let(:user1) { create(:user, organization:) }
      let(:user2) { create(:user, organization:) }
      let(:user3) { create(:user, organization:) }
      let(:user4) { create(:user, organization:) }
      let(:user5) { create(:user, organization:) }
      let(:user6) { create(:user, organization:) }
      let(:user7) { create(:user, organization:) }
      let(:user8) { create(:user, organization:) }
      let(:user9) { create(:user, organization:) }
      let!(:conversation10) do
        Decidim::Messaging::Conversation.start!(
          originator: user,
          interlocutors: [user1, user2, user3, user4, user5, user6, user7, user8, user9],
          body: "Hi all 10 people!"
        )
      end

      context "when starting the conversation" do
        before do
          visit decidim.new_conversation_path(recipient_id: [
                                                user1.id, user2.id, user3.id,
                                                user4.id, user5.id, user6.id,
                                                user7.id, user8.id, user9.id
                                              ])
        end

        it_behaves_like "accessible page"

        it "shows the other nine participants names" do
          within ".conversation__participants" do
            expect(page).to have_content(user1.name)
            expect(page).to have_content(user2.name)
            expect(page).to have_content(user3.name)
            expect(page).to have_content(user4.name)
            expect(page).to have_content(user5.name)
            expect(page).to have_content(user6.name)
            expect(page).to have_content(user7.name)
            expect(page).to have_content(user8.name)
            expect(page).to have_content(user9.name)
            expect(page).to have_no_content(user.name)
          end
        end
      end

      context "when going to the conversation" do
        before do
          visit decidim.conversation_path(id: conversation10.id)
        end

        it "shows the other nine participants names" do
          within ".conversation__participants" do
            expect(page).to have_content(user1.name)
            expect(page).to have_content(user2.name)
            expect(page).to have_content(user3.name)
            expect(page).to have_content(user4.name)
            expect(page).to have_content(user5.name)
            expect(page).to have_content(user6.name)
            expect(page).to have_content(user7.name)
            expect(page).to have_content(user8.name)
            expect(page).to have_content(user9.name)
            expect(page).to have_no_content(user.name)
          end
        end
      end
    end
  end

  context "when user is deleted" do
    let(:interlocutor) { create(:user, :confirmed, organization:) }

    let!(:conversation) do
      Decidim::Messaging::Conversation.start!(
        originator: interlocutor,
        interlocutors: [user],
        body: "who wants apples?"
      )
    end

    before do
      Decidim::DestroyAccount.call(Decidim::DeleteAccountForm.from_params({}).with_context(current_user: interlocutor))
      interlocutor.reload
    end

    it "shows user's conversation list" do
      visit_inbox

      expect(page).to have_css(".conversation__item img[alt='Avatar: Deleted participant']")
      expect(page).to have_css(".conversation__item", text: "who wants apples?")
    end

    it "allows entering a conversation" do
      visit_inbox
      click_on "conversation-#{conversation.id}"

      expect(page).to have_content("Conversation with\nDeleted participant")
      expect(page).to have_content("who wants apples?")
    end
  end

  private

  def start_conversation(message)
    field = find_field("conversation_body")
    field.native.send_keys message

    click_on "Send"
  end

  def visit_inbox
    visit decidim.root_path

    find_by_id("trigger-dropdown-account").click
    within "#dropdown-menu-account" do
      click_on("Conversations")
    end
  end
end
