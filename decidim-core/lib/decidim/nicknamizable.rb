# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # This concern contains the logic related to nicknames.
  module Nicknamizable
    extend ActiveSupport::Concern

    included do
      validates :nickname, length: { in: nickname_length_range }, allow_blank: true
    end

    class_methods do
      #
      # Allowed range for nickname length
      #
      def nickname_length_range
        (0..(nickname_max_length - 1))
      end

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
      def nicknamize(name)
        disambiguate(name.parameterize(separator: "_")[nickname_length_range])
      end

      private

      def disambiguate(name)
        candidate = name

        2.step do |n|
          return candidate unless exists?(nickname: candidate)

          candidate = numbered_variation_of(candidate, n)
        end
      end

      def numbered_variation_of(name, number)
        appendix = "_#{number}"

        "#{name[0..(nickname_max_length - 1 - appendix.length)]}#{appendix}"
      end
    end
  end
end
