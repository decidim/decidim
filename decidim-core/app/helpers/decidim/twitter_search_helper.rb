# frozen_string_literal: true

module Decidim
  module TwitterSearchHelper
    # Builds the URL for Twitter's hashtag search.
    #
    # @param hashtag [String] The hasthag to search
    #
    # @return [String]
    def twitter_hashtag_url(hashtag)
      format("https://twitter.com/hashtag/%{hashtag}?src=hash", hashtag:)
    end
  end
end
