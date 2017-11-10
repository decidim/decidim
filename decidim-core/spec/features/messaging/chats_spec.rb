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
    let(:interlocutor) { create(:user) }

    let!(:chat) do
      Decidim::Messaging::Chat.start!(
        originator: user,
        interlocutors: [interlocutor],
        body: "who wants apples?"
      )
    end

    before { visit_inbox }

    it "shows user's chat list" do
      within ".chats" do
        expect(page).to have_selector(".card--list__item", text: /#{interlocutor.name}/i)
        expect(page).to have_selector(".card--list__item", text: "who wants apples?")
        expect(page).to have_selector(".card--list__item", text: /\d{2}:\d{2}/)
      end
    end

    it "allows entering a chat" do
      click_link interlocutor.name

      expect(page).to have_content("Chat with #{interlocutor.name}")
      expect(page).to have_content("who wants apples?")
    end

    context "when a message is sent" do
      before do
        click_link interlocutor.name
        fill_in "message_body", with: "Please reply!"
        click_button "Send"
      end

      it "appears as the last message" do
        expect(page).to have_selector(".message:last-child", text: "Please reply!")
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
