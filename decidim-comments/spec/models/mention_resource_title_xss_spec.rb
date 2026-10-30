# frozen_string_literal: true

require "spec_helper"
require "decidim/proposals/test/factories"

module Decidim
  module Comments
    # Regression test for the stored XSS in MentionResourceRenderer#mention_title.
    describe "Comment rendering of mentioned resource titles" do
      let(:payload) { %(Check this proposal"><img src=x onerror="alert(document.cookie)">) }
      let(:proposal) { create(:proposal, title: { en: payload }) }
      let(:comment) { create(:comment, commentable: proposal, body: { en: "See #{proposal.to_global_id}" }) }

      it "escapes the title of the mentioned proposal" do
        fragment = Loofah.fragment(comment.formatted_body)
        mention = fragment.at_css(".editor-mention")

        expect(mention.at_css("span").text).to eq(payload)
        expect(fragment.css("img[onerror]")).to be_empty
      end
    end
  end
end
