# frozen_string_literal: true

require "spec_helper"

describe "ProfileConversations", type: :system do
  let(:organization) { create(:organization) }
  let(:user) { create :user, :confirmed, organization: organization }
  let(:another_user) { create(:user, :confirmed, organization: organization) }
  let(:extra_user) { create(:user, :confirmed, organization: organization) }
  let(:user_group) { create(:user_group, :confirmed, organization: organization, users: [user, extra_user]) }

  let(:profile) { user_group }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when user has no conversations" do
    before { visit_inbox }

    it "shows a notice informing about that" do
      expect(page).to have_content("There are no conversations yet")
    end
  end

  shared_examples "create new conversation" do
    it "allows sending an initial message", :slow do
      start_conversation("Is this a Ryanair style democracy?")
      within ".conversations" do
        expect(page).to have_selector(".text-small", text: "Is this a Ryanair style democracy?")
      end
    end

    it "redirects to an existing conversation if it exists already", :slow do
      start_conversation("Is this a Ryanair style democracy?")

      visit decidim.new_profile_conversation_path(nickname: profile.nickname, recipient_id: recipient.id)
      expect(page).to have_selector(".message:last-child", text: "Is this a Ryanair style democracy?")
    end
  end

  context "when starting a conversation" do
    let(:recipient) { create(:user, organization: organization) }

    before do
      visit decidim.new_profile_conversation_path(nickname: profile.nickname, recipient_id: recipient.id)
    end

    it "shows an empty conversation page" do
      expect(page).to have_no_selector(".card--list__item")
      expect(page).to have_current_path decidim.new_profile_conversation_path(nickname: profile.nickname, recipient_id: recipient.id)
    end

    it_behaves_like "create new conversation"

    # context "and recipient has restricted communications" do
    #   let(:recipient) { create(:user, direct_message_types: "followed-only", organization: organization) }

    #   context "and recipient does not follow user" do
    #     it "redirects user with access error" do
    #       expect(page).not_to have_current_path decidim.new_conversation_path(recipient_id: recipient.id)
    #       expect(page).to have_content("You are not authorized to perform this action")
    #     end

    #     context "and a conversation exists already" do
    #       let!(:conversation) do
    #         Decidim::Messaging::Conversation.start!(
    #           originator: user,
    #           interlocutors: [recipient],
    #           body: "Is this a Ryanair style democracy?"
    #         )
    #       end

    #       it "redirects to the existing conversation" do
    #         visit decidim.new_conversation_path(recipient_id: recipient.id)
    #         expect(page).to have_selector(".message:last-child", text: "Is this a Ryanair style democracy?")
    #       end
    #     end
    #   end

    #   context "and recipient follows user" do
    #     let!(:follow) { create :follow, user: recipient, followable: user }

    #     before do
    #       visit decidim.new_conversation_path(recipient_id: recipient.id)
    #     end

    #     it_behaves_like "create new conversation"
    #   end
    # end
  end

  private

  def start_conversation(message)
    fill_in "conversation_body", with: message
    click_button "Send"
  end

  def visit_inbox
    visit decidim.profile_path(nickname: profile.nickname)

    within "#profile-tabs" do
      click_link "Conversations"
    end
  end
end
