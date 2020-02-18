# frozen_string_literal: true

require "spec_helper"

describe Decidim::Messaging::Message do
  describe "#formatted_body" do
    let!(:originator) { create(:user) }
    let!(:recipient) { create(:user) }

    context "when sender is not a participant" do
      subject do
        conversation = Decidim::Messaging::Conversation.start(
          originator: originator,
          interlocutors: [recipient],
          body: "Hei!"
        )

        conversation.add_message(sender: create(:user), body: "sneaking in")
      end

      it { is_expected.not_to be_valid }
    end

    context "when the body contains urls" do
      before { allow(Decidim).to receive(:content_processors).and_return([:link]) }
      subject(:conversation) do
        Decidim::Messaging::Conversation.start(
          originator: originator,
          interlocutors: [recipient],
          body: "Hei!"
        )
      end

      let(:body) do
        %(Content with <a href="http://urls.net" onmouseover="alert('hello')">URLs</a> of anchor type and text urls like https://decidim.org. And a malicous <a href="javascript:document.cookies">click me</a>)
      end

      let(:result) do
        %(<div><p>Content with URLs of anchor type and text urls like <a href="https://decidim.org" target="_blank" rel="nofollow noopener">https://decidim.org</a>. And a malicous click me</p></div>)
      end

      it "converts all URLs to links and strips attributes in anchors" do
        conversation.add_message(sender: create(:user), body: body)
        expect(conversation.messages.last.formatted_body).to eq(result)
      end
    end
  end
end
