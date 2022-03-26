# frozen_string_literal: true
#
# This file has been copied from https://github.com/andypike/rectify/blob/master/lib/rectify/query.rb
# We have done this so we can decouple Decidim from any Virtus dependency, which is a dead project
# Please follow Decidim discussion to understand more https://github.com/decidim/decidim/discussions/7234
module Decidim
  class Query
    include Enumerable

    def self.merge(*queries)
      queries.reduce(Decidim::NullQuery.new) { |a, e| a.merge(e) }
    end

    def initialize(scope = ActiveRecord::NullRelation)
      @scope = scope
    end

    def query
      @scope
    end

    def |(other)
      if relation? && other.relation?
        Decidim::Query.new(cached_query.merge(other.cached_query))
      elsif eager? && other.eager?
        Decidim::Query.new(cached_query | other.cached_query)
      else
        raise Decidim::UnableToComposeQueriesException.new(self, other)
      end
    end

    alias merge |

    def count
      cached_query.count
    end

    alias size count

    def first
      cached_query.first
    end

    def each(&block)
      cached_query.each(&block)
    end

    def exists?
      return cached_query.exists? if relation?

      cached_query.present?
    end

    def none?
      !exists?
    end

    def to_a
      cached_query.to_a
    end

    alias to_ary to_a

    def relation?
      cached_query.is_a?(ActiveRecord::Relation)
    end

    def eager?
      cached_query.is_a?(Array)
    end

    def cached_query
      @cached_query ||= query
    end
  end
end
