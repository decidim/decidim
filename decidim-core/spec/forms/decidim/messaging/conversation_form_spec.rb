# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Messaging
    describe ConversationForm do
      subject { form }

      let(:body) { "Hi!" }
      let(:recipient_id) { create(:user, organization: current_user.organization).id }
      let(:current_user) { create(:user) }
      let(:params) do
        {
          body: body,
          recipient_id: recipient_id
        }
      end
      let(:form) do
        described_class.from_params(params).with_context(current_user: current_user)
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
        let(:recipient_id) { current_user.id }

        it { is_expected.to be_invalid }
      end
    end
  end
end
