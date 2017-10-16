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
      def self.words(*args)
        localized do
          ::Faker::Lorem.words(*args)
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
      def self.characters(*args)
        localized do
          ::Faker::Lorem.characters(*args)
        end
      end

      # Builds a sentence with Lorem Ipsum words. See Faker::Lorem for options.
      #
      # Returns a Hash with a value for each locale.
      def self.sentence(*args)
        localized do
          ::Faker::Lorem.sentence(*args)
        end
      end

      # Builds many sentences with Lorem Ipsum words. See Faker::Lorem for options.
      #
      # Returns a Hash with a value for each locale.
      def self.sentences(*args)
        localized do
          ::Faker::Lorem.sentences(*args)
        end
      end

      # Builds a paragraph with Lorem Ipsum words. See Faker::Lorem for options.
      #
      # Returns a Hash with a value for each locale.
      def self.paragraph(*args)
        localized do
          ::Faker::Lorem.paragraph(*args)
        end
      end

      # Builds many paragraphs with Lorem Ipsum words. See Faker::Lorem for options.
      #
      # Returns a Hash with a value for each locale.
      def self.paragraphs(*args)
        localized do
          ::Faker::Lorem.paragraphs(*args)
        end
      end

      # Builds a question with Lorem Ipsum words. See Faker::Lorem for options.
      #
      # Returns a Hash with a value for each locale.
      def self.question(*args)
        localized do
          ::Faker::Lorem.question(*args)
        end
      end

      # Builds many questions with Lorem Ipsum words. See Faker::Lorem for options.
      #
      # Returns a Hash with a value for each locale.
      def self.questions(*args)
        localized do
          ::Faker::Lorem.questions(*args)
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

      # Wrapps a text build by the block with some other text.o
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
        result.inject({}) do |wrapped, (locale, text)|
          wrapped.update(locale => [before, text, after].join)
        end
      end

      # nodoc
      def self.localized
        Decidim.available_locales.inject({}) do |result, locale|
          text = ::Faker::Base.with_locale(locale) do
            yield
          end

          result.update(locale => text)
        end.with_indifferent_access
      end

      private_class_method :localized
    end
  end
end
