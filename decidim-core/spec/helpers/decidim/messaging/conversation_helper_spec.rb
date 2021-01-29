# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Messaging
    describe ConversationHelper do
      describe "#text_link_to_current_or_new_conversation_with" do
        let(:current_user) { create(:user, :confirmed) }

        before do
          allow(helper).to receive(:current_user).and_return current_user
          allow(helper).to receive(:user_signed_in?).and_return true
        end

        context "when user restricts private messaging to people they follow" do
          let(:user) { create(:user, :confirmed, direct_message_types: "followed-only") }

          it "returns nil" do
            expect(helper.text_link_to_current_or_new_conversation_with(user)).to be_nil
          end
        end

        context "when user doesn't restrict private messaging" do
          let(:user) { create(:user, :confirmed) }
          let(:message_link) do
            "<a title=\"Send private message\" href=\"/conversations/new?recipient_id=#{user.id}\">Send private message</a>"
          end

          it "returns private message link" do
            expect(helper.text_link_to_current_or_new_conversation_with(user)).to eql message_link
          end
        end
      end
    end
  end
end
