# frozen_string_literal: true

module Decidim
  #
  # Decorator for users
  #
  class HashtagPresenter < SimpleDelegator
    include Rails.application.routes.mounted_helpers
    include ActionView::Helpers::UrlHelper

    def initialize(hashtag, cased_name: nil)
      super(hashtag)
      @cased_name = cased_name if cased_name&.downcase == hashtag.name
    end

    #
    # hashtag presented in a twitter-like style
    #
    def name
      "##{@cased_name || super}"
    end

    delegate :url, to: :hashtag, prefix: true

    def hashtag_path
      decidim.hashtag_path(__getobj__.name)
    end

    def display_hashtag
      link_to name, decidim.search_path(term: name), target: "_blank", class: "hashtag-mention", rel: "noopener"
    end

    def display_hashtag_name
      name
    end
  end
end
