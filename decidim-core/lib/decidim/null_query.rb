# frozen_string_literal: true
#
# This file has been copied from https://github.com/andypike/rectify/blob/master/lib/rectify/null_query.rb
# We have done this so we can decouple Decidim from any Virtus dependency, which is a dead project
# Please follow Decidim discussion to understand more https://github.com/decidim/decidim/discussions/7234
module Decidim
  class NullQuery < Query
    def merge(query)
      query
    end

    def query
      []
    end
  end
end
