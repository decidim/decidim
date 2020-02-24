# frozen_string_literal: true

module Decidim
  module Core
    # A GraphQL resolver to handle `user` queries
    class UserResolver
      #
      # - organization: Decidim::Organization scoping
      # - filters: hash of attr - value to filter results
      #
      def initialize(organization, filters = {})
        @organization = organization
        if filters.include? :wildcard
          filters.delete(:name)
          filters.delete(:nickname)
        end
        @filters = filters
      end

      def users
        resolve
      end

      private

      def resolve
        return @records if @records

        scope
        global_filter
        filter
        @records.limit(50)
      end

      def scope
        @records = Decidim::User
                   .where(organization: organization)
                   .confirmed
      end

      # Only key name attributes in Decidim::User will be applied
      def filter
        @filters.each do |key, value|
          next unless Decidim::User.column_names.include? key.to_s

          @records = @records.where("#{key} ilike ?", "%#{value}%")
        end
      end

      # Special search key ":wildcard"
      def global_filter
        return unless @filters.include? :wildcard

        term = "%#{@filters[:wildcard]}%"
        @records = @records.where("name ilike ? or nickname ilike ?", term, term)
      end

      attr_reader :organization, :filters
    end
  end
end
