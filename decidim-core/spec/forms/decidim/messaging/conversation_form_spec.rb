# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Messaging
    describe ConversationForm do
      subject { form }

      let(:body) { "Hi!" }
      let(:recipient_id) { create(:user, organization: sender.organization).id }
      let(:sender) { create(:user) }
      let(:params) do
        {
          body:,
          recipient_id:
        }
      end
      let(:form) do
        described_class.from_params(params).with_context(sender:)
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when no body" do
        let(:body) { nil }

        it { is_expected.to be_invalid }
      end

      context "when body is too long" do
        let(:max_length) { Decidim.config.maximum_conversation_message_length }
        let(:body) { "c" * (max_length + 1) }

        it { is_expected.not_to be_valid }
      end

      context "when body has maximum length" do
        let(:max_length) { Decidim.config.maximum_conversation_message_length }
        let(:body) { "c" * max_length }

        it { is_expected.to be_valid }
      end

      context "when no recipient" do
        let(:recipient_id) { nil }

        it { is_expected.to be_invalid }
      end

      context "when the recipient and the user are the same" do
        let(:recipient_id) { sender.id }

        it { is_expected.to be_invalid }
      end

      context "when sender is a group" do
        let(:sender) { create(:user_group) }

        it { is_expected.to be_valid }
      end
    end
  end
end
