# frozen_string_literal: true

require "spec_helper"

describe "Conversations", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create :user, :confirmed, organization: organization }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when user has no conversations" do
    before { visit_inbox }

    it "shows a notice informing about that" do
      expect(page).to have_content("You have no conversations yet")
    end

    it "shows the topbar button as inactive" do
      within ".topbar__user__logged" do
        expect(page).to have_no_selector("a.topbar__conversations.is-active")
        expect(page).to have_selector("a.topbar__conversations")
      end
    end
  end

  shared_examples "create new conversation" do
    it "allows sending an initial message", :slow do
      start_conversation("Is this a Ryanair style democracy?")
      expect(page).to have_selector(".conversation-chat:last-child", text: "Is this a Ryanair style democracy?")
    end

    it "redirects to an existing conversation if it exists already", :slow do
      start_conversation("Is this a Ryanair style democracy?")
      expect(page).to have_selector(".conversation-chat:last-child", text: "Is this a Ryanair style democracy?")

      visit decidim.new_conversation_path(recipient_id: recipient.id)
      expect(page).to have_selector(".conversation-chat:last-child", text: "Is this a Ryanair style democracy?")
    end
  end

  context "when starting a conversation" do
    let(:recipient) { create(:user, organization: organization) }

    before do
      visit decidim.new_conversation_path(recipient_id: recipient.id)
    end

    it "shows an empty conversation page" do
      expect(page).to have_no_selector(".card--list__item")
      expect(page).to have_current_path decidim.new_conversation_path(recipient_id: recipient.id)
    end

    it_behaves_like "create new conversation"

    context "and recipient has restricted communications" do
      let(:recipient) { create(:user, direct_message_types: "followed-only", organization: organization) }

      context "and recipient does not follow user" do
        it "redirects user with access error" do
          expect(page).not_to have_current_path decidim.new_conversation_path(recipient_id: recipient.id)
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
            expect(page).to have_selector(".conversation-chat:last-child", text: "Is this a Ryanair style democracy?")
          end
        end
      end

      context "and recipient follows user" do
        let!(:follow) { create :follow, user: recipient, followable: user }

        before do
          visit decidim.new_conversation_path(recipient_id: recipient.id)
        end

        it_behaves_like "create new conversation"
      end
    end
  end

  context "when user has conversations" do
    let(:interlocutor) { create(:user, :confirmed, organization: organization) }

    let!(:conversation) do
      Decidim::Messaging::Conversation.start!(
        originator: user,
        interlocutors: [interlocutor],
        body: "who wants apples?"
      )
    end

    it "shows user's conversation list" do
      visit_inbox

      within ".conversations" do
        expect(page).to have_selector(".card.card--widget", text: /#{interlocutor.name}/i)
        expect(page).to have_selector(".card.card--widget", text: "who wants apples?")
      end
    end

    it "allows entering a conversation" do
      visit_inbox
      click_link "conversation-#{conversation.id}"

      expect(page).to have_content("Conversation with #{interlocutor.name}")
      expect(page).to have_content("who wants apples?")
    end

    context "and some of them are unread" do
      before do
        conversation.add_message!(sender: interlocutor, body: "I want one")

        visit_inbox
      end

      it "shows the topbar button as active" do
        within ".topbar__user__logged" do
          expect(page).to have_selector("a.topbar__conversations.is-active")
        end
      end

      it "shows the number of unread messages per conversation" do
        expect(page).to have_selector(".card--list__item .unread_message__counter", text: "1")
      end
    end

    context "and they are read" do
      before { visit_inbox }

      it "shows the topbar button as inactive" do
        within ".topbar__user__logged" do
          expect(page).to have_no_selector("a.topbar__conversations.is-active")
          expect(page).to have_selector("a.topbar__conversations")
        end
      end

      it "does not show an unread count" do
        expect(page).to have_no_selector(".card--list__item .unread_message__counter")
      end
    end

    context "when a message is sent" do
      let(:message_body) { "Please reply!" }

      before do
        visit_inbox
        click_link "conversation-#{conversation.id}"
        expect(page).to have_content("Send")
        fill_in "message_body", with: message_body
        click_button "Send"
      end

      it "appears as the last message", :slow do
        click_button "Send"
        expect(page).to have_selector(".conversation-chat:last-child", text: message_body)
      end

      context "and interlocutor sees it" do
        before do
          click_button "Send"
          expect(page).to have_selector(".conversation-chat:last-child", text: message_body)
          relogin_as interlocutor
          visit_inbox
        end

        it "appears as unread", :slow do
          expect(page).to have_selector(".card--list__item .unread_message__counter", text: "2")
        end

        it "appears as read after it's seen", :slow do
          click_link "conversation-#{conversation.id}"
          expect(page).to have_content("Please reply!")

          find("a.card--list__data__icon--back").click
          expect(page).to have_no_selector(".card--list__item .unread_message__counter")
        end
      end

      context "and message is too long" do
        let(:message_body) { Faker::Lorem.paragraph_by_chars(max_length + 1) }
        let(:max_length) { Decidim.config.maximum_conversation_message_length }

        it "shows the error message modal", :slow do
          expect(page).to have_selector("#messageErrorModal .reveal__title", text: "Message was not sent due to an error")
          expect(page).to have_selector("#messageErrorModal .reveal__body", text: "Body is too long (maximum is #{max_length} characters)")
        end
      end
    end

    context "when interlocutor has restricted conversations" do
      let(:interlocutor) { create(:user, :confirmed, direct_message_types: "followed-only", organization: organization) }

      context "and interlocutor does not follow user" do
        before do
          visit_inbox
          click_link "conversation-#{conversation.id}"
        end

        it "allows user to see old messages" do
          expect(page).to have_content("Conversation with #{interlocutor.name}")
          expect(page).to have_content("who wants apples?")
        end

        it "does not show the sending form" do
          expect(page).not_to have_selector("textarea#message_body")
        end
      end

      context "and interlocutor follows user" do
        let!(:follow) { create :follow, user: interlocutor, followable: user }

        before do
          visit_inbox
          click_link "conversation-#{conversation.id}"
        end

        it "show the sending form" do
          expect(page).to have_selector("textarea#message_body")
        end

        it "sends a message", :slow do
          fill_in "message_body", with: "Please reply!"
          expect(page).to have_content("Send")
          click_button "Send"

          expect(page).to have_selector(".conversation-chat:last-child", text: "Please reply!")
        end
      end
    end

    context "when visiting recipient's profile page" do
      let(:recipient) { create(:user, :confirmed, organization: organization) }

      before do
        visit decidim.profile_path(recipient.nickname)
      end

      it "has a contact link" do
        expect(page).to have_link(title: "Contact", href: decidim.new_conversation_path(recipient_id: recipient.id))
      end

      context "and recipient has restricted communications" do
        let(:recipient) { create(:user, :confirmed, direct_message_types: "followed-only", organization: organization) }

        it "has contact muted" do
          expect(page).not_to have_link(href: decidim.new_conversation_path(recipient_id: recipient.id))
          expect(page).to have_selector("svg.icon--envelope-closed.muted")
        end
      end
    end

    describe "on mentioned list" do
      context "when someone direct messages disabled" do
        let!(:interlocutor2) { create(:user, :confirmed, organization: organization, direct_message_types: "followed-only") }

        it "can't be selected on the mentioned list", :slow do
          visit_inbox
          expect(page).to have_content("New conversation")
          click_button "New conversation"
          expect(page).to have_selector(".js-multiple-mentions")
          # The sleep function is called due to a setTimeout function in input_multiple_mentions
          sleep(2)
          find(".js-multiple-mentions").fill_in with: "@"
          page.execute_script('$(".js-multiple-mentions")[0].dispatchEvent(new Event("keydown"));$(".js-multiple-mentions")[0].dispatchEvent(new Event("keyup"));')
          expect(page).to have_selector(".tribute-container .disabled-tribute-element")
        end
      end
    end
  end

  context "when multiple participants conversation" do
    let(:user1) { create(:user, organization: organization) }
    let(:user2) { create(:user_group, organization: organization) }
    let(:user3) { create(:user, organization: organization) }
    let(:user4) { create(:user, organization: organization) }
    let(:user5) { create(:user, organization: organization) }
    let(:user6) { create(:user, organization: organization) }
    let(:user7) { create(:user, organization: organization) }
    let(:user8) { create(:user, organization: organization) }
    let(:user9) { create(:user, organization: organization) }
    let(:user10) { create(:user, organization: organization) }

    describe "GET conversations" do
      context "when 2 participants conversation" do
        let!(:conversation2) do
          Decidim::Messaging::Conversation.start!(
            originator: user,
            interlocutors: [user1],
            body: "Hi!"
          )
        end

        before do
          visit decidim.new_conversation_path(recipient_id: user1.id)
        end

        it "shows only 1 other participant name" do
          within ".conversation-header .ml-s" do
            expect(page).to have_content(user1.name)
            expect(page).not_to have_content(user.name)
          end
        end
      end
    end

    describe "GET conversations" do
      context "when 4 participants conversation" do
        let!(:conversation4) do
          Decidim::Messaging::Conversation.start!(
            originator: user,
            interlocutors: [user1, user2, user3],
            body: "Hi all 4 people!"
          )
        end

        before do
          visit decidim.new_conversation_path(recipient_id: [
                                                user1.id, user2.id, user3.id
                                              ])
        end

        it "shows the other 3 participant name" do
          within ".conversation-header .ml-s" do
            expect(page).to have_content(user1.name)
            expect(page).to have_content(user2.name)
            expect(page).to have_content(user3.name)
            expect(page).not_to have_content(user.name)
          end
        end
      end
    end

    describe "GET conversations" do
      context "when 10 participants conversation" do
        let!(:conversation10) do
          Decidim::Messaging::Conversation.start!(
            originator: user,
            interlocutors: [user1, user2, user3, user4, user5, user6, user7, user8, user9],
            body: "Hi all 10 people!"
          )
        end

        before do
          visit decidim.new_conversation_path(recipient_id: [
                                                user1.id, user2.id, user3.id,
                                                user4.id, user5.id, user6.id,
                                                user7.id, user8.id, user9.id
                                              ])
        end

        it "shows the other 9 participant name" do
          within ".conversation-header .ml-s" do
            expect(page).to have_content(user1.name)
            expect(page).to have_content(user2.name)
            expect(page).to have_content(user3.name)
            expect(page).to have_content(user4.name)
            expect(page).to have_content(user5.name)
            expect(page).to have_content(user6.name)
            expect(page).to have_content(user7.name)
            expect(page).to have_content(user8.name)
            expect(page).to have_content(user9.name)
            expect(page).not_to have_content(user.name)
          end
        end
      end
    end

    describe "GET existent conversation" do
      context "when 2 participants conversation" do
        let!(:conversation2) do
          Decidim::Messaging::Conversation.start!(
            originator: user,
            interlocutors: [user1],
            body: "Hi!"
          )
        end

        before do
          visit decidim.conversation_path(id: conversation2.id)
        end

        it "shows only 1 other participant name" do
          within ".conversation-header .ml-s" do
            expect(page).to have_content(user1.name)
          end
        end
      end
    end

    describe "GET existent conversation" do
      context "when 4 participants conversation" do
        let!(:conversation4) do
          Decidim::Messaging::Conversation.start!(
            originator: user,
            interlocutors: [user1, user2, user3],
            body: "Hi all 4 people!"
          )
        end

        before do
          visit decidim.conversation_path(id: conversation4.id)
        end

        it "shows the other 3 participant name" do
          within ".conversation-header .ml-s" do
            expect(page).to have_content(user1.name)
            expect(page).to have_content(user2.name)
            expect(page).to have_content(user3.name)
            expect(page).not_to have_content(user.name)
          end
        end
      end
    end

    describe "GET existent conversation" do
      context "when 10 participants conversation" do
        let!(:conversation10) do
          Decidim::Messaging::Conversation.start!(
            originator: user,
            interlocutors: [user1, user2, user3, user4, user5, user6, user7, user8, user9],
            body: "Hi all 10 people!"
          )
        end

        before do
          visit decidim.conversation_path(id: conversation10.id)
        end

        it "shows the other 9 participant name" do
          within ".conversation-header .ml-s" do
            expect(page).to have_content(user1.name)
            expect(page).to have_content(user2.name)
            expect(page).to have_content(user3.name)
            expect(page).to have_content(user4.name)
            expect(page).to have_content(user5.name)
            expect(page).to have_content(user6.name)
            expect(page).to have_content(user7.name)
            expect(page).to have_content(user8.name)
            expect(page).to have_content(user9.name)
            expect(page).not_to have_content(user.name)
          end
        end
      end
    end

    describe "GET conversations index" do
      context "when 2 participants conversation" do
        let!(:conversation2) do
          Decidim::Messaging::Conversation.start!(
            originator: user,
            interlocutors: [user1],
            body: "Hi!"
          )
        end

        before do
          visit decidim.conversations_path
        end

        it "shows only the other participant name" do
          within ".mr-s > strong" do
            expect(page).to have_content(user1.name)
            expect(page).not_to have_content(user.name)
          end
        end
      end
    end

    describe "GET conversations index" do
      context "when 4 participants conversation" do
        let!(:conversation4) do
          Decidim::Messaging::Conversation.start!(
            originator: user,
            interlocutors: [user1, user2, user3],
            body: "Hi all 4 people!"
          )
        end

        before do
          visit decidim.conversations_path
        end

        it "shows only the 3 other participant name" do
          within ".mr-s > strong" do
            expect(page).to have_content(user1.name)
            expect(page).to have_content(user2.name)
            expect(page).to have_content(user3.name)
            expect(page).not_to have_content(user.name)
          end
        end
      end
    end

    describe "GET conversations index" do
      context "when 10 participants conversation" do
        let!(:conversation10) do
          Decidim::Messaging::Conversation.start!(
            originator: user,
            interlocutors: [user1, user2, user3, user4, user5, user6, user7, user8, user9],
            body: "Hi all 10 people!"
          )
        end

        before do
          visit decidim.conversations_path
        end

        it "shows only the first 3 participant name plus the number of remaining participants" do
          within ".mr-s > strong" do
            expect(page).to have_content("+ 6")
            expect(page).not_to have_content(user.name.upcase)
          end
        end
      end
    end
  end

  private

  def start_conversation(message)
    fill_in "conversation_body", with: message
    click_button "Send"
  end

  def visit_inbox
    visit decidim.root_path

    within ".topbar__user__logged" do
      find(".icon--envelope-closed").click
    end
  end
end
