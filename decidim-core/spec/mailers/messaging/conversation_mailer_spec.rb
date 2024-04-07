# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Messaging
    describe ConversationMailer do
      let(:organization) { create(:organization) }
      let(:conversation) { create(:conversation) }
      let(:group) { create(:user_group, organization:, users: [manager]) }
      let(:manager) { create(:user, organization:) }
      let(:message) { create(:message) }
      let(:originator) { create(:user, organization:) }
      let(:sender) { create(:user, organization:) }
      let(:user) { create(:user, organization:) }
      let(:router) { Decidim::Core::Engine.routes.url_helpers }

      shared_examples "conversation mail" do
        it "gets the subject" do
          expect(subject.subject).to eq(mail_subject)
        end

        it "delivers the email to the user" do
          expect(subject.to).to eq(recipient)
        end

        it "includes the organization data" do
          expect(subject.body).to include(translated(user.organization.name))
        end

        it "includes the message" do
          expect(subject.body).to include(mail_message_body)
        end

        it "includes the conversation link" do
          expect(subject.body).to include(router.conversation_path(conversation))
        end
      end

      describe ".new_conversation" do
        subject { described_class.new_conversation(originator, user, conversation) }
        let(:mail_subject) { "#{originator.name} has started a conversation with you" }
        let(:mail_message_body) { conversation.messages.first.body }
        let(:recipient) { [user.email] }

        it_behaves_like "conversation mail"
      end

      describe ".new_group_conversation" do
        subject { described_class.new_group_conversation(originator, manager, conversation, group) }
        let(:mail_subject) { "#{originator.name} has started a conversation with #{group.name}" }
        let(:mail_message_body) { conversation.messages.first.body }
        let(:recipient) { [manager.email] }

        it_behaves_like "conversation mail"
      end

      describe ".comanagers_new_conversation" do
        subject { described_class.comanagers_new_conversation(group, user, conversation, manager) }
        let(:mail_subject) { "#{manager.name} has started a new conversation as a #{manager.name}" }
        let(:mail_message_body) { conversation.messages.first.body }
        let(:recipient) { [user.email] }

        it_behaves_like "conversation mail"
      end

      describe ".new_message" do
        subject { described_class.new_message(sender, user, conversation, message) }
        let(:mail_subject) { "You have new messages from #{sender.name}" }
        let(:mail_message_body) { decidim_escape_translated(message.body) }
        let(:recipient) { [user.email] }

        it_behaves_like "conversation mail"
      end

      describe ".new_group_message" do
        subject { described_class.new_group_message(sender, user, conversation, message, group) }
        let(:mail_subject) { "#{group.name} have new messages from #{sender.name}" }
        let(:mail_message_body) { decidim_escape_translated(message.body) }
        let(:recipient) { [user.email] }

        it_behaves_like "conversation mail"
      end

      describe ".comanagers_new_message" do
        subject { described_class.comanagers_new_message(sender, user, conversation, message, manager) }
        let(:mail_subject) { "#{manager.name} has send new messages as a #{manager.name}" }
        let(:mail_message_body) { decidim_escape_translated(message.body) }
        let(:recipient) { [user.email] }

        it_behaves_like "conversation mail"
      end
    end
  end
end
