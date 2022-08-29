# frozen_string_literal: true

require "spec_helper"

shared_examples_for "general conversation permissions" do
  let(:context) { { conversation: } }
  let(:another_user) { create :user }
  let(:group) { create :user_group }

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

  context "when the interlocutor is specified in the context" do
    let(:context) { { conversation:, interlocutor: } }
    let(:originator) { interlocutor }
    let(:interlocutor) { create :user }

    let!(:conversation) do
      Decidim::Messaging::Conversation.start!(
        originator:,
        interlocutors: [another_user],
        body: "who wants apples?"
      )
    end

    it { is_expected.to eq true }

    context "and accessing user's conversation" do
      let(:originator) { user }

      it { is_expected.to eq false }
    end
  end

  context "when the originator of the conversation is a group" do
    let(:context) { { conversation:, interlocutor: group } }
    let!(:conversation) do
      Decidim::Messaging::Conversation.start!(
        originator: group,
        interlocutors: [another_user],
        body: "who wants apples?"
      )
    end

    it { is_expected.to eq true }
  end

  context "when the group is an interlocutor" do
    let(:context) { { conversation:, interlocutor: group } }
    let!(:conversation) do
      Decidim::Messaging::Conversation.start!(
        originator: another_user,
        interlocutors: [group],
        body: "who wants apples?"
      )
    end

    it { is_expected.to eq true }

    context "and group is not specified as interlocutor" do
      let(:context) { { conversation: } }

      it { is_expected.to eq false }
    end
  end

  context "when the group is not in the conversation" do
    let(:context) { { conversation:, interlocutor: group } }
    let!(:conversation) do
      Decidim::Messaging::Conversation.start!(
        originator: another_user,
        interlocutors: [create(:user_group)],
        body: "who wants apples?"
      )
    end

    it { is_expected.to eq false }
  end
end

shared_examples_for "restricted conversation permissions" do
  let(:context) { { conversation: } }
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
