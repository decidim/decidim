# frozen_string_literal: true

module Decidim
  class MutationRegistry
    include Singleton

    attr_reader :mutation_types

    def initialize
      @mutation_types = []
    end

    def register(type_class)
      mutation_types << type_class unless mutation_types.include?(type_class)
    end
  end
end
