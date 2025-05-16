# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # This concern contains the logic related to nicknames.
  module Nicknamizable
    extend ActiveSupport::Concern

    included do
      validates :nickname, length: { maximum: nickname_max_length }, allow_blank: true
    end

    class_methods do
      #
      # Maximum allowed nickname length
      #
      def nickname_max_length
        20
      end

      #
      # Converts any string into a valid nickname
      #
      # * Parameterizes it so it is valid as a URL.
      # * Trims length so it fits validation constraints.
      # * Disambiguates it so it is unique.
      #
      # name - the String to nicknamize
      # organization_id - the organization id we are using as scope for the uniqueness
      #
      # Example to nicknamize a user name, scoped to the organization:
      #
      #    nicknamize(user_name, organization_id)
      #
      def nicknamize(name, organization_id)
        return unless name

        disambiguate(name.parameterize(separator: "_")[nickname_length_range], organization_id)
      end

      private

      def nickname_length_range
        (0...nickname_max_length)
      end

      def disambiguate(name, organization_id)
        candidate = name

        2.step do |n|
          return candidate if Decidim::UserBaseEntity.where(nickname: candidate.downcase).where(decidim_organization_id: organization_id).empty?

          candidate = numbered_variation_of(name, n)
        end
      end

      def numbered_variation_of(name, number)
        appendix = "_#{number}"

        "#{name[0...(nickname_max_length - appendix.length)]}#{appendix}"
      end
    end
  end
end
