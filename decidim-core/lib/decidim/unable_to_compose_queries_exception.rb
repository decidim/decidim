# frozen_string_literal: true

#
# This file has been copied from https://github.com/andypike/rectify/blob/master/lib/rectify/errors.rb
# We have done this so we can decouple Decidim from any Virtus dependency, which is a dead project
# Please follow Decidim discussion to understand more https://github.com/decidim/decidim/discussions/7234
module Decidim
  class UnableToComposeQueriesException < StandardError
    def initialize(query, other)
      super(
        "Unable to composite queries #{query.class.name} and " \
        "#{other.class.name}. You cannot compose queries where #query " \
        "returns an ActiveRecord::Relation in one and an array in the other."
      )
    end
  end
end
