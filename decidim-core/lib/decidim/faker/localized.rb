# frozen_string_literal: true

begin
  require "faker"
rescue LoadError => e
  msg = <<~ERROR
    You're trying to use decidim's faker-based seeds but you're not using `faker`.
    Make sure you add the `faker` gem to your `Gemfile` and try again
  ERROR

  raise e, msg
end

module Decidim
  module Faker
    # A Custom Faker wrapper so we can easily generate fake data for each
    # locale in localized attributes.
    module Localized
      # Fakes a company name.
      #
      # Returns a Hash with a value for each locale.
      def self.company
        localized do
          ::Faker::Company.name
        end
      end

      # Fakes a person name.
      #
      # Returns a Hash with a value for each locale.
      def self.name
        localized do
          ::Faker::Name.name
        end
      end

      # Builds a Lorem Ipsum word.
      #
      # Returns a Hash with a value for each locale.
      def self.word
        localized do
          ::Faker::Lorem.word
        end
      end

      # Builds many Lorem Ipsum words. See Faker::Lorem for options.
      #
      # Returns a Hash with a value for each locale.
      def self.words(...)
        localized do
          ::Faker::Lorem.words(...)
        end
      end

      # Builds a Lorem Ipsum character.
      #
      # Returns a Hash with a value for each locale.
      def self.character
        localized do
          ::Faker::Lorem.character
        end
      end

      # Builds many Lorem Ipsum characters. See Faker::Lorem for options.
      #
      # Returns a Hash with a value for each locale.
      def self.characters(...)
        localized do
          ::Faker::Lorem.characters(...)
        end
      end

      # Builds a sentence with Lorem Ipsum words. See Faker::Lorem for options.
      #
      # Returns a Hash with a value for each locale.
      def self.sentence(...)
        localized do
          ::Faker::Lorem.sentence(...)
        end
      end

      # Builds many sentences with Lorem Ipsum words. See Faker::Lorem for options.
      #
      # Returns a Hash with a value for each locale.
      def self.sentences(...)
        localized do
          ::Faker::Lorem.sentences(...)
        end
      end

      # Builds a paragraph with Lorem Ipsum words. See Faker::Lorem for options.
      #
      # Returns a Hash with a value for each locale.
      def self.paragraph(...)
        localized do
          ::Faker::Lorem.paragraph(...)
        end
      end

      # Builds many paragraphs with Lorem Ipsum words. See Faker::Lorem for options.
      #
      # Returns a Hash with a value for each locale.
      def self.paragraphs(...)
        localized do
          ::Faker::Lorem.paragraphs(...)
        end
      end

      # Builds a question with Lorem Ipsum words. See Faker::Lorem for options.
      #
      # Returns a Hash with a value for each locale.
      def self.question(...)
        localized do
          ::Faker::Lorem.question(...)
        end
      end

      # Builds many questions with Lorem Ipsum words. See Faker::Lorem for options.
      #
      # Returns a Hash with a value for each locale.
      def self.questions(...)
        localized do
          ::Faker::Lorem.questions(...)
        end
      end

      # Sets the given text as the value for each locale.
      #
      # text - The String text to set for each locale.
      #
      # Returns a Hash with a value for each locale.
      def self.literal(text)
        Decidim.available_locales.inject({}) do |result, locale|
          result.update(locale => text)
        end.with_indifferent_access
      end

      # Wrapps a text build by the block with some other text.
      #
      # before - The String text to inject at the begining of each value.
      # after  - The String text to inject at the end of each value.
      # block  - A Block that generates a Hash with a text for each locale.
      #
      # Example:
      #
      #   Decidim::Faker::Localized.wrapped("<p>", "</p>") do
      #     Decidim::Faker::Localized.sentence(5)
      #   end
      #
      # Returns a Hash with a value for each locale.
      def self.wrapped(before, after)
        result = yield
        result.inject({}) do |wrapped, (locale, value)|
          if value.is_a?(Hash) && locale.to_s == "machine_translations"
            final_value = value.inject({}) do |new_wrapped, (new_locale, new_value)|
              new_wrapped.update(new_locale => [before, new_value, after].join)
            end

            wrapped.update(locale => final_value)
          else
            wrapped.update(locale => [before, value, after].join)
          end
        end
      end

      # Runs the given block for each of the available locales in Decidim,
      # momentarilly setting the locale to the current one.
      #
      # Returns a Hash with a value for each locale.
      def self.localized
        locales = Decidim.available_locales.dup
        last_locale = locales.pop if locales.length > 1

        value = locales.inject({}) do |result, locale|
          text = ::Faker::Base.with_locale(locale) do
            yield
          end

          if text.is_a?(Hash)
            result.merge!(text)
          else
            result.update(locale => text)
          end
        end.with_indifferent_access
        return value unless last_locale

        value.update(
          "machine_translations" => {
            last_locale => ::Faker::Base.with_locale(last_locale) { yield }
          }.with_indifferent_access
        )
      end

      # Prefixes the +msg+ for each available locale and returns as a Hash
      # of the form `locale => prefixed_msg`.
      #
      # Return a Hash with a value for each locale.
      def self.prefixed(msg, locales = Decidim.available_locales.dup)
        other_locales = locales
        last_locale = locales.pop if locales.length > 1

        value = other_locales.inject({}) do |result, locale|
          result.update(locale => "#{locale.to_s.upcase}: #{msg}")
        end.with_indifferent_access
        return value unless last_locale

        value.update(
          "machine_translations" => {
            last_locale => "#{last_locale.to_s.upcase}: #{msg}"
          }.with_indifferent_access
        )
      end
    end
  end
end
