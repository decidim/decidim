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
          # Include the record IDs as a base number for the order calculation
          # in order to avoid PostgreSQL random ordering when the records are
          # updated. PostgreSQL can randomly change the base ordering in case
          # the records are changed which is not desired as we want consistent
          # orders for the records.
          order(arel_table[primary_key] * Arel.sql("RANDOM()")).load
        end
      end
    end
  end
end
