# frozen_string_literal: true

module Decidim
  #
  # Decorator for users
  #
  class HashtagPresenter < SimpleDelegator
    include Rails.application.routes.mounted_helpers
    include ActionView::Helpers::UrlHelper

    #
    # name presented in a twitter-like style
    #
    def name
      "##{super}"
    end

    delegate :url, to: :hashtag, prefix: true

    def hashtag_path
      decidim.hashtag_path(__getobj__.name)
    end

    def display_hashtag
      link_to name, decidim.search_path(term: name), target: "_blank", class: "hashtag-mention"
    end

    def display_hashtag_name
      name
    end
  end
end
