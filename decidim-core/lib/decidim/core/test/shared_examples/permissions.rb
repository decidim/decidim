# frozen_string_literal: true

require "spec_helper"

shared_examples_for "general conversation permissions" do
  let(:context) { { conversation: conversation } }
  let(:another_user) { create :user }

  context "when the originator of the conversation is the user" do
    let!(:conversation) do
      Decidim::Messaging::Conversation.start!(
        originator: user,
        interlocutors: [another_user],
        body: "who wants apples?"
      )
    end

    it { is_expected.to eq true }
  end

  context "when the user is an interlocutor" do
    let!(:conversation) do
      Decidim::Messaging::Conversation.start!(
        originator: another_user,
        interlocutors: [user],
        body: "who wants apples?"
      )
    end

    it { is_expected.to eq true }
  end

  context "when the user is not in the conversation" do
    let!(:conversation) do
      Decidim::Messaging::Conversation.start!(
        originator: another_user,
        interlocutors: [create(:user)],
        body: "who wants apples?"
      )
    end

    it { is_expected.to eq false }
  end
end

shared_examples_for "restricted conversation permissions" do
  let(:context) { { conversation: conversation } }
  let(:user) { create :user }
  let(:interlocutor) { create :user, organization: user.organization }
  let!(:conversation) do
    Decidim::Messaging::Conversation.start(
      originator: user,
      interlocutors: [interlocutor],
      body: "who wants apples?"
    )
  end

  context "when interlocutor does not restrict communications" do
    it { is_expected.to eq true }
  end

  context "when interlocutor restricts communications" do
    let(:interlocutor) { create :user, direct_message_types: "followed-only" }

    context "and does not follow the user" do
      it { is_expected.to eq false }
    end

    context "and follows the user" do
      let!(:follow) { create :follow, user: interlocutor, followable: user }

      it { is_expected.to eq true }
    end
  end
end
