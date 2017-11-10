# frozen_string_literal: true

require "spec_helper"

describe Decidim::Messaging::Message do
  context "when sender is not a participant" do
    subject do
      chat = Decidim::Messaging::Chat.start(
        originator: originator,
        interlocutors: [recipient],
        body: "Hei!"
      )

      chat.add_message(sender: create(:user), body: "sneaking in")
    end

    let(:originator) { create(:user) }
    let(:recipient) { create(:user) }

    it { is_expected.not_to be_valid }
  end
end
