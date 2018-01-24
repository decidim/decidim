# frozen_string_literal: true

module Decidim
  module Events
    # This module is used to be included in event classes inheriting from ExtendedEvent
    # whose resource has an author.
    #
    # It adds the author_name, author_nickname, author_path and author_url to the i18n interpolations.
    module AuthorEvent
      extend ActiveSupport::Concern

      included do
        i18n_attributes :author_name, :author_nickname, :author_path, :author_url

        def author_nickname
          author_presenter.nickname
        end

        def author_name
          author_presenter.name
        end

        def author_path
          author_presenter.profile_path
        end

        def author_url
          author_presenter.profile_url
        end

        def author_presenter
          @author ||= Decidim::UserPresenter.new(author)
        end

        def author
          resource.author if resource.respond_to?(:author)
        end
      end
    end
  end
end
