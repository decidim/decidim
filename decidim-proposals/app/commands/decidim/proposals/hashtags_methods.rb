# frozen_string_literal: true

module Decidim
  module Proposals
    # A module with all the hash tags common methods for proposals
    # and collaborative draft commands.
    module HashtagsMethods
      private

      def title_with_hashtags
        @title_with_hashtags ||= Decidim::ContentProcessor.parse_with_processor(:hashtag, form.title, current_organization: form.current_organization).rewrite
      end

      def body_with_hashtags
        @body_with_hashtags ||= begin
          ret = Decidim::ContentProcessor.parse(form.body, current_organization: form.current_organization).rewrite.strip
          ret += "\n#{body_extra_hashtags.strip}" unless body_extra_hashtags.empty?
          ret
        end
      end

      def body_extra_hashtags
        @body_extra_hashtags ||= if form.respond_to?(:extra_hashtags)
                                   Decidim::ContentProcessor.parse_with_processor(
                                     :hashtag,
                                     form.extra_hashtags.map { |hashtag| "##{hashtag}" }.join(" "),
                                     current_organization: form.current_organization,
                                     extra_hashtags: true
                                   ).rewrite
                                 else
                                   ""
                                 end
      end
    end
  end
end
