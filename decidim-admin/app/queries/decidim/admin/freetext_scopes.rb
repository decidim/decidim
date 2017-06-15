# frozen_string_literal: true

module Decidim
  module Admin
    # This query searches scopes by name.
    class FreetextScopes < Rectify::Query
      def self.for(organization, lang, name)
        new(organization, lang, name).query
      end

      def initialize(organization, lang, name)
        @organization = organization
        @lang = lang
        @name = name
      end

      def query
        @organization.scopes.where("name->>? ilike ?", @lang, @name + "%")
      end
    end
  end
end
