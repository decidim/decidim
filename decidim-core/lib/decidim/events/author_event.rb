# frozen_string_literal: true

module Decidim
  module Events
    # This module is used to be included in event classes inheriting from SimpleEvent
    # whose resource has an author.
    #
    # It adds the author_name, author_nickname, author_path and author_url to the i18n interpolations.
    module AuthorEvent
      extend ActiveSupport::Concern

      included do
        i18n_attributes :author_name, :author_nickname, :author_path, :author_url

        def author_nickname
          author_presenter&.nickname.to_s
        end

        def author_name
          author_presenter&.name.to_s
        end

        def author_path
          author_presenter&.profile_path.to_s
        end

        def author_url
          author_presenter&.profile_url.to_s
        end

        def author_presenter
          return unless author

          @author_presenter ||= Decidim::UserPresenter.new(author)
        end

        def author
          return unless resource.respond_to?(:author)
          return unless resource.author.is_a?(Decidim::UserBaseEntity)

          resource.author
        end
      end
    end
  end
end
