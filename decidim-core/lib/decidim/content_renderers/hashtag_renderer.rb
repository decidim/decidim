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
      GLOBAL_ID_REGEX = %r{(gid:\/\/[\w-]*\/Decidim::Hashtag\/(?:\d+))\/?([[:alnum:]](?:[[:alnum:]]|_)*)?\b}

      # Replaces found Global IDs matching an existing hashtag with
      # a link to their detail page. The Global IDs representing an
      # invalid Decidim::Hashtag are replaced with an empty string.
      #
      # @return [String] the content ready to display (contains HTML)
      def render(with_link: true)
        if content.is_a?(Hash)
          content.each_with_object({}) do |(locale, string), parsed_content|
            parsed_content[locale] = replace_hashtags(string, with_link)
          end
        else
          replace_hashtags(content, with_link)
        end
      end

      def render_without_link
        render(with_link: false)
      end

      private

      def replace_hashtags(content, with_link)
        content.gsub(GLOBAL_ID_REGEX) do |hashtag_gid|
          begin
            gid, cased_name = hashtag_gid.scan(GLOBAL_ID_REGEX).flatten
            hashtag = GlobalID::Locator.locate(gid)
            presenter = Decidim::HashtagPresenter.new(hashtag, cased_name: cased_name)
            if with_link
              presenter.display_hashtag
            else
              presenter.display_hashtag_name
            end
          rescue ActiveRecord::RecordNotFound => _ex
            ""
          end
        end
      end
    end
  end
end
