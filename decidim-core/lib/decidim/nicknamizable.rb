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
      def nicknamize(name)
        return unless name
        disambiguate(name.parameterize(separator: "_")[nickname_length_range])
      end

      private

      def nickname_length_range
        (0...nickname_max_length)
      end

      def disambiguate(name)
        candidate = name

        2.step do |n|
          return candidate unless exists?(nickname: candidate)

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
