# frozen_string_literal: true

require "spec_helper"

describe Decidim::Messaging::Message do
  let!(:originator) { create(:user) }
  let!(:recipient) { create(:user) }

  context "when sender is not a participant" do
    subject do
      conversation = Decidim::Messaging::Conversation.start(
        originator:,
        interlocutors: [recipient],
        body: "Hei!"
      )

      conversation.add_message(sender: create(:user), body: "sneaking in")
    end

    it { is_expected.not_to be_valid }
  end

  context "when the body contains urls" do
    subject(:conversation) do
      Decidim::Messaging::Conversation.start(
        originator:,
        interlocutors: [recipient],
        body: "Hei!"
      )
    end

    before { allow(Decidim).to receive(:content_processors).and_return([:link]) }

    let(:body) do
      %(Content with <a href="http://urls.net">URLs</a> of anchor type and text urls like https://decidim.org.)
    end

    let(:result) do
      %(Content with <a href="http://urls.net">URLs</a> of anchor type and text urls like <a href="https://decidim.org" target="_blank" rel="nofollow noopener noreferrer ugc">https://decidim.org</a>.)
    end

    it "converts all URLs to links" do
      conversation.add_message(sender: create(:user), body:)
      expect(conversation.messages.last.body_with_links).to eq(result)
    end
  end
end
