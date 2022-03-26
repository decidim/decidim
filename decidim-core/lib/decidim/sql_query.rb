# frozen_string_literal: true

#
# This file has been copied from https://github.com/andypike/rectify/blob/master/lib/rectify/sql_query.rb
# We have done this so we can decouple Decidim from any Virtus dependency, which is a dead project
# Please follow Decidim discussion to understand more https://github.com/decidim/decidim/discussions/7234
#
module Decidim
  class SqlQuery < Query
    def query
      model.find_by_sql([sql, params])
    end
  end
end
