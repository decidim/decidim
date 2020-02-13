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
      expect(page).to have_selector(".message:last-child", text: "Is this a Ryanair style democracy?")
    end

    it "redirects to an existing conversation if it exists already", :slow do
      start_conversation("Is this a Ryanair style democracy?")
      expect(page).to have_selector(".message:last-child", text: "Is this a Ryanair style democracy?")

      visit decidim.new_conversation_path(recipient_id: recipient.id)
      expect(page).to have_selector(".message:last-child", text: "Is this a Ryanair style democracy?")
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
            expect(page).to have_selector(".message:last-child", text: "Is this a Ryanair style democracy?")
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
        expect(page).to have_selector(".card--list__item", text: /#{interlocutor.name}/i)
        expect(page).to have_selector(".card--list__item", text: "who wants apples?")
        expect(page).to have_selector(".card--list__item", text: /\d{2}:\d{2}/)
      end
    end

    it "allows entering a conversation" do
      visit_inbox
      click_link interlocutor.name

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
        expect(page).to have_selector(".card--list__item .card--list__counter", text: "1")
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
        expect(page).to have_no_selector(".card--list__item .card--list__counter")
      end
    end

    context "when a message is sent" do
      before do
        visit_inbox
        click_link interlocutor.name
        fill_in "message_body", with: "Please reply!"
        click_button "Send"
      end

      it "appears as the last message", :slow do
        expect(page).to have_selector(".message:last-child", text: "Please reply!")
      end

      context "and interlocutor sees it" do
        before do
          expect(page).to have_selector(".message:last-child", text: "Please reply!")
          relogin_as interlocutor
          visit_inbox
        end

        it "appears as unread" do
          expect(page).to have_selector(".card--list__item .card--list__counter", text: "2")
        end

        it "appears as read after it's seen" do
          click_link user.name
          expect(page).to have_content("Please reply!")

          find("a.card--list__data__icon--back").click
          expect(page).to have_no_selector(".card--list__item .card--list__counter")
        end
      end
    end

    context "when interlocutor has restricted conversations" do
      let(:interlocutor) { create(:user, :confirmed, direct_message_types: "followed-only", organization: organization) }

      context "and interlocutor does not follow user" do
        before do
          visit_inbox
          click_link interlocutor.name
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
          click_link interlocutor.name
        end

        it "show the sending form" do
          expect(page).to have_selector("textarea#message_body")
        end

        it "sends a message" do
          visit_inbox
          click_link interlocutor.name
          fill_in "message_body", with: "Please reply!"
          click_button "Send"

          expect(page).to have_selector(".message:last-child", text: "Please reply!")
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
