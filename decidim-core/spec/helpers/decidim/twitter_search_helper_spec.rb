# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe TwitterSearchHelper do
    describe "twitter_hashtag_url" do
      it "returns the correct URL" do
        expect(helper.twitter_hashtag_url("Decidim")).to eq("https://twitter.com/hashtag/Decidim?src=hash")
      end

      context "when the hashtag starts with has a number" do
        it "returns the correct URL" do
          expect(helper.twitter_hashtag_url("93Oscars")).to eq("https://twitter.com/hashtag/93Oscars?src=hash")
        end
      end
    end
  end
end
