# frozen_string_literal: true

module Decidim
  # This concern contains the logic related to followable resources.
  module Hashtaggable
    extend ActiveSupport::Concern

    included do
      has_many :decidim_hashtaggings, as: :decidim_hashtaggable, dependent: :destroy, class_name: "Decidim::Hashtagging"
      has_many :decidim_hashtags, through: :decidim_hashtaggings, class_name: "Decidim::Hashtag"
    end

    def parsed_title
      
    end
  end
end
