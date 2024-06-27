# frozen_string_literal: true

module Decidim
  #
  # This class handles all logic regarding registering filters
  #
  class AdminFilter
    attr_accessor :filters, :filters_with_values

    def initialize(name)
      @name = name
      @filters = []
      @filters_with_values = {}
    end

    def add_filters(*filters)
      @filters += filters
    end

    def add_filters_with_values(**items)
      @filters_with_values.merge!(items)
    end

    def build_for(context)
      raise "Filter #{@name} is not registered" if registry.blank?

      registry.configurations.each do |configuration|
        context.instance_exec(self, &configuration)
      end
      self
    end

    private

    def registry
      @registry ||= AdminFiltersRegistry.find(@name)
    end
  end
end
