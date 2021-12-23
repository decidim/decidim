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

      describe "#conversation_label_for" do
        let(:user) { create :user, :confirmed }
        let(:participants) { [user] }

        before do
          helper.instance_variable_set(:@virtual_path, "decidim.messaging.conversations.show")
        end

        it "includes the user name" do
          expect(helper.conversation_label_for(participants)).to eq "Conversation with #{user.name} (@#{user.nickname})"
        end

        context "when user is deleted" do
          let(:user) { create :user, :deleted }

          it "doesn't include the user name" do
            expect(helper.conversation_label_for(participants)).to eq "Conversation with Participant deleted"
          end
        end
      end

      describe "#username_list" do
        let(:user) { create :user, :confirmed }
        let(:participants) { [user] }

        before do
          helper.instance_variable_set(:@virtual_path, "decidim.messaging.conversations.show")
        end

        it "includes the user name" do
          expect(helper.username_list(participants)).to eq "<strong>#{user.name}</strong>"
        end

        context "when user is deleted" do
          let(:user) { create :user, :deleted }

          it "doesn't include the user name" do
            expect(helper.username_list(participants)).to eq "<span class=\"label label--small label--basic\">Participant deleted</span>"
          end
        end
      end

      describe "#conversation_name_for" do
        let(:user) { create :user, :confirmed }
        let(:participants) { [user] }

        before do
          helper.instance_variable_set(:@virtual_path, "decidim.messaging.conversations.show")
        end

        it "includes the user name" do
          expect(helper.conversation_name_for(participants)).to eq "<strong>#{user.name}</strong><br><span class=\"muted\">@#{user.nickname}</span>"
        end

        context "when user is deleted" do
          let(:user) { create :user, :deleted }

          it "doesn't include the user name" do
            expect(helper.conversation_name_for(participants)).to eq "<span class=\"label label--small label--basic\">Participant deleted</span>"
          end
        end
      end
    end
  end
end
