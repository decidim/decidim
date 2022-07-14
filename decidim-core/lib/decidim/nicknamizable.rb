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
      # * Parameterizes it so it's valid as a URL.
      # * Trims length so it fits validation constraints.
      # * Disambiguates it so it's unique.
      #
      # name - the String to nicknamize
      # scope - a Hash with extra values to scope the nickname to
      #
      # Example to nicknamize a user name, scoped to the organization:
      #
      #    nicknamize(user_name, organization: current_organization)
      #
      def nicknamize(name, scope = {})
        return unless name

        disambiguate(
          name.parameterize(separator: "_")[nickname_length_range],
          scope
        )
      end

      private

      def nickname_length_range
        (0...nickname_max_length)
      end

      def disambiguate(name, scope)
        candidate = name

        2.step do |n|
          return candidate if Decidim::UserBaseEntity.where("nickname ILIKE ?", candidate.downcase).where(scope).empty?

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
