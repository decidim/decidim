# frozen_string_literal: true

module Decidim
  module Ai
    module Language
      autoload :Formatter, "decidim/ai/language/formatter"

      class << self
        def config = self

        def configure
          yield self
        end
      end

      # Text cleanup service
      #
      # If you want to implement your own text formatter, you can use a class having the following contract
      #
      # class Formatter
      #   def cleanup(text)
      #     # your code
      #   end
      # end
      mattr_accessor :formatter, default: Decidim::Env.new("DECIDIM_AI_LANGUAGE_FORMATTER", "Decidim::Ai::Language::Formatter").value
    end
  end
end
