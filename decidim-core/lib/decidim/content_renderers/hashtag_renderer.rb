# frozen_string_literal: true

module Decidim
  module ContentRenderers
    # A renderer that searches Global IDs representing hashtags in content
    # and replaces it with a link to their detail page with the name.
    #
    # e.g. gid://<APP_NAME>/Decidim::Hashtag/1
    #
    # @see BaseRenderer Examples of how to use a content renderer
    class HashtagRenderer < BaseRenderer
      # Matches a global id representing a Decidim::Hashtag
      GLOBAL_ID_REGEX = %r{gid://[\w-]*/Decidim::Hashtag/(\d+)/?(_?)([[:alnum:]](?:[[:alnum:]]|_)*)?\b}

      # Replaces found Global IDs matching an existing hashtag with
      # a link to their detail page. The Global IDs representing an
      # invalid Decidim::Hashtag are replaced with an empty string.
      #
      # links - should render hashtags as links?
      # extras - should include extra hashtags?
      #
      # @return [String] the content ready to display (contains HTML)
      def render(links: true, extras: true)
        return content unless content.respond_to?(:gsub)

        content.gsub(GLOBAL_ID_REGEX) do |hashtag_gid|
          id, extra, cased_name = hashtag_gid.scan(GLOBAL_ID_REGEX).flatten
          hashtag = hashtags[id.to_i]

          next "" if hashtag.nil? || (!extras && extra.present?)

          presenter = Decidim::HashtagPresenter.new(hashtag, cased_name: cased_name)

          if links
            presenter.display_hashtag
          else
            presenter.display_hashtag_name
          end
        end
      end

      # Returns all the extra hashtags found in the content
      def extra_hashtags
        @extra_hashtags ||= existing_hashtags.select { |hashtag| content_extra_hashtags_ids.member?(hashtag.id) }
      end

      private

      def hashtags
        @hashtags ||=
          existing_hashtags.index_by(&:id)
      end

      def existing_hashtags
        @existing_hashtags ||= Decidim::Hashtag.where(id: content_hashtags_ids)
      end

      def content_hashtags_ids
        @content_hashtags_ids ||= ids_from_matches(content_matches)
      end

      def content_extra_hashtags_ids
        @content_extra_hashtags_ids ||= ids_from_matches(content_matches.select { |match| match[1].present? })
      end

      def content_matches
        @content_matches ||= content.scan(GLOBAL_ID_REGEX)
      end

      def ids_from_matches(matches)
        matches.map(&:first).map(&:to_i).uniq
      end
    end
  end
end
