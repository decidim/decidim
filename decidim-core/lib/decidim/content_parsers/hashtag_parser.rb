# frozen_string_literal: true

module Decidim
  module ContentParsers
    # A parser that searches hashtags in content.
    #
    # A word starting with `#` will be considered as a hashtag if
    # it only contains letters, numbers or underscores. If the `#` is
    # followed with an underscore, then it is not considered.
    #
    # @see BaseParser Examples of how to use a content parser
    class HashtagParser < BaseParser
      # Class used as a container for metadata
      #
      # @!attribute hashtags
      #   @return [Array] an array of Decidim::Hashtag mentioned in content
      Metadata = Struct.new(:hashtags)

      # Matches a hashtag if it starts with a letter or number
      # and only contains letters, numbers or underscores.
      HASHTAG_REGEX = /\B#([[:alnum:]](?:[[:alnum:]]|_)*)\b/i

      # Replaces hashtags name with new or existing hashtags models global ids.
      #
      # @return [String] the content with the hashtags replaced by global ids
      def rewrite
        content.gsub(HASHTAG_REGEX) do |match|
          hashtags[match[1..-1]].to_global_id.to_s
        end
      end

      def metadata
        Metadata.new(content_hashtags.map { |content_hashtag| hashtags[content_hashtag] })
      end

      private

      def hashtags
        @hashtags ||= Hash.new do |hash, name|
          hash[name] = Decidim::Hashtag.create(organization: current_organization, name: name.downcase)
        end .merge(Hash[
          existing_hashtags.map do |hashtag|
            [hashtag.name, hashtag]
          end
        ])
      end

      def existing_hashtags
        @existing_hashtags ||= Decidim::Hashtag.where(organization: current_organization, name: content_hashtags)
      end

      def content_hashtags
        @content_hashtags ||= content.scan(HASHTAG_REGEX).flatten.uniq
      end

      def current_organization
        @current_organization ||= context[:current_organization]
      end
    end
  end
end
