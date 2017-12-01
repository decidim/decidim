# frozen_string_literal: true

require "spec_helper"

describe "Chats", type: :feature do
  let(:organization) { create(:organization) }
  let(:user) { create :user, :confirmed, organization: organization }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when user has no chats" do
    before { visit_inbox }

    it "shows a notice informing about that" do
      expect(page).to have_content("You have no chats yet")
    end

    it "shows the topbar button as inactive" do
      within ".topbar__user__logged" do
        expect(page).to have_no_selector("a.topbar__chats.is-active")
        expect(page).to have_selector("a.topbar__chats")
      end
    end
  end

  context "when starting a chat" do
    let(:recipient) { create(:user) }

    before do
      visit decidim.new_chat_path(recipient_id: recipient.id)
    end

    it "shows an empty conversation page" do
      expect(page).to have_no_selector(".card--list__item")
    end

    it "allows sending an initial message" do
      fill_in "chat_body", with: "Is this a Ryanair style democracy?"
      click_button "Send"

      expect(page).to have_selector(".message:last-child", text: "Is this a Ryanair style democracy?")
    end
  end

  context "when user has chats" do
    let(:interlocutor) { create(:user, :confirmed) }

    let!(:chat) do
      Decidim::Messaging::Chat.start!(
        originator: user,
        interlocutors: [interlocutor],
        body: "who wants apples?"
      )
    end

    it "shows user's chat list" do
      visit_inbox

      within ".chats" do
        expect(page).to have_selector(".card--list__item", text: /#{interlocutor.name}/i)
        expect(page).to have_selector(".card--list__item", text: "who wants apples?")
        expect(page).to have_selector(".card--list__item", text: /\d{2}:\d{2}/)
      end
    end

    it "allows entering a chat" do
      visit_inbox
      click_link interlocutor.name

      expect(page).to have_content("Chat with #{interlocutor.name}")
      expect(page).to have_content("who wants apples?")
    end

    context "and some of them are unread" do
      before do
        chat.add_message(sender: interlocutor, body: "I want one")
        chat.save!

        visit_inbox
      end

      it "shows the topbar button as active" do
        within ".topbar__user__logged" do
          expect(page).to have_selector("a.topbar__chats.is-active")
        end
      end

      it "shows the number of unread messages per chat" do
        expect(page).to have_selector(".card--list__item .card--list__counter", text: "1")
      end
    end

    context "and they are read" do
      before { visit_inbox }

      it "shows the topbar button as inactive" do
        within ".topbar__user__logged" do
          expect(page).to have_no_selector("a.topbar__chats.is-active")
          expect(page).to have_selector("a.topbar__chats")
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

      it "appears as the last message" do
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
  end

  def visit_inbox
    visit decidim.root_path

    within ".topbar__user__logged" do
      find(".icon--envelope-closed").click
    end
  end
end
