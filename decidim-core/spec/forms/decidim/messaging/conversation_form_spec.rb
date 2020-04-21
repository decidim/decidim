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
          body: body,
          recipient_id: recipient_id
        }
      end
      let(:form) do
        described_class.from_params(params).with_context(sender: sender)
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when no body" do
        let(:body) { nil }

        it { is_expected.to be_invalid }
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
