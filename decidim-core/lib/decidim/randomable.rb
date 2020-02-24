# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A concern with the components needed when you want a model to have a component.
  module Randomable
    extend ActiveSupport::Concern

    class_methods do
      # Public: Randomly orders a collection given a seed.
      def order_randomly(seed)
        transaction do
          connection.execute("SELECT setseed(#{connection.quote(seed)})")
          order(Arel.sql("RANDOM()")).load
        end
      end
    end
  end
end
