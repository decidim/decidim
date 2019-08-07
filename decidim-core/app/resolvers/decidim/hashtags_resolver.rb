# frozen_string_literal: true

module Decidim
  # A GraphQL resolver to handle `hashtags'
  class HashtagsResolver
    def initialize(organization, term)
      @organization = organization
      @term = term
    end

    def hashtags
      Decidim::Hashtag.where(organization: @organization).where("name like ?", "#{@term}%")
    end
  end
end
