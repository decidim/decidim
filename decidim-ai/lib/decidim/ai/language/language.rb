# frozen_string_literal: true

module Decidim
  module Ai
    module Language
      autoload :Formatter, "decidim/ai/language/formatter"
      include ActiveSupport::Configurable

      # Text cleanup service
      #
      # If you want to implement your own text formatter, you can use a class having the following contract
      #
      # class Formatter
      #   def cleanup(text)
      #     # your code
      #   end
      # end
      config_accessor :formatter do
        "Decidim::Ai::Language::Formatter"
      end
    end
  end
end
