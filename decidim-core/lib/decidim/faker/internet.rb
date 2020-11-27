# frozen_string_literal: true

require "faker"

module Decidim
  module Faker
    # A Custom Faker wrapper to modify Faker::Internet#slug
    class Internet < ::Faker::Internet
      # Fakes a slug, using EN locale to allow ASCII only
      def self.slug(...)
        with_locale(:en) do
          ::Faker::Internet.slug(...)
        end
      end
    end
  end
end
