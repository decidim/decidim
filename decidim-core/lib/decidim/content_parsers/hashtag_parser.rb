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
    class HashtagParser < TagParser
      # Class used as a container for metadata
      #
      # @!attribute hashtags
      #   @return [Array] an array of Decidim::Hashtag mentioned in content
      Metadata = Struct.new(:hashtags)

      # Matches a hashtag if it starts with a letter or number
      # and only contains letters, numbers or underscores.
      HASHTAG_REGEX = /(?:\A|\s\K)\B#([[:alnum:]](?:[[:alnum:]]|_)*)\b/i

      def metadata
        Metadata.new(content_tags.map { |content_hashtag| hashtag(content_hashtag) }.uniq)
      end

      private

      def tag_data_type
        "hashtag"
      end

      def replace_tags(text)
        text.gsub(HASHTAG_REGEX) do |match|
          "#{hashtag(match[1..-1]).to_global_id}/#{extra_hashtags? ? "_" : ""}#{match[1..-1]}"
        end
      end

      def scan_tags(text)
        text.scan(HASHTAG_REGEX)
      end

      def hashtag(name)
        hashtags[name.downcase] ||= Decidim::Hashtag.create(organization: current_organization, name: name.downcase)
      end

      def hashtags
        @hashtags ||= existing_hashtags.index_by(&:name)
      end

      def existing_hashtags
        @existing_hashtags ||= Decidim::Hashtag.where(organization: current_organization, name: content_tags.map(&:downcase))
      end

      def current_organization
        @current_organization ||= context[:current_organization]
      end

      def extra_hashtags?
        return @extra_hashtags if defined?(@extra_hashtags)

        @extra_hashtags = context[:extra_hashtags]
      end
    end
  end
end
