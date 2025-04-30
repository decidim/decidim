# frozen_string_literal: true

module Decidim
  # This concern contains the logic related to single authorship.
  #
  # Sometimes authorship may belong to a single user or be shared among coauthors, in
  # this latest case the Coauthorable concern should be used instead of Authorable.
  module Authorable
    extend ActiveSupport::Concern
    include Decidim::TranslatableAttributes

    included do
      belongs_to :author, polymorphic: true, foreign_key: "decidim_author_id", foreign_type: "decidim_author_type"

      scope :with_official_origin, lambda {
        where(decidim_author_type: "Decidim::Organization")
      }

      scope :with_participants_origin, lambda {
        where(decidim_author_type: "Decidim::UserBaseEntity")
      }

      scope :with_any_origin, lambda { |*origin_keys|
        search_values = origin_keys.compact.compact_blank

        conditions = [:official, :participants].map do |key|
          search_values.member?(key.to_s) ? try("with_#{key}_origin") : nil
        end.compact
        return self unless conditions.any?

        scoped_query = where(id: conditions.shift)
        conditions.each do |condition|
          scoped_query = scoped_query.or(where(id: condition))
        end

        scoped_query
      }

      validate :author_belongs_to_organization

      # Checks whether the user is author of the given resource
      #
      # user - the user to check for authorship
      def authored_by?(user)
        user == author
      end

      # Public: Checks whether the resource is official or not.
      #
      # Returns a boolean.
      def official?
        decidim_author_type == Decidim::Organization.name
      end

      def author_name
        translated_attribute(author.name)
      end

      private

      def author_belongs_to_organization
        return if !author || !organization

        errors.add(:author, :invalid) unless author == organization || (author.respond_to?(:organization) && author.organization == organization)
      end
    end
  end
end
