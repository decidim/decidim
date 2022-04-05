# frozen_string_literal: true

# Copyright (c) 2016 Andy Pike - The MIT license
#
# This file has been copied from https://github.com/andypike/rectify/blob/master/lib/rectify/query.rb
# We have done this so we can decouple Decidim from any Virtus dependency, which is a dead project
# Please follow Decidim discussion to understand more https://github.com/decidim/decidim/discussions/7234
module Decidim
  class Query
    include Enumerable

    def self.merge(*queries)
      queries.reduce(Decidim::Query.new(nil)) { |a, e| a.merge(e) }
    end

    def initialize(scope = ActiveRecord::NullRelation)
      @scope = scope
    end

    def query
      return [] if @scope.nil?

      @scope
    end

    def |(other)
      return Decidim::Query.new(other.cached_query) if @scope.nil?

      if relation? && other.relation?
        Decidim::Query.new(cached_query.merge(other.cached_query))
      elsif eager? && other.eager?
        Decidim::Query.new(cached_query | other.cached_query)
      else
        raise Decidim::UnableToComposeQueriesException.new(self, other)
      end
    end

    alias merge |

    delegate :count, to: :cached_query

    alias size count

    delegate :first, to: :cached_query

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

    delegate :to_a, to: :cached_query

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
