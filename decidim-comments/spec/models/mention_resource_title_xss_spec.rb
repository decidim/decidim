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
        expect(comment.formatted_body).not_to include(%(<img src="x" onerror="alert(document.cookie)">))
      end
    end
  end
end
