# frozen_string_literal: true

module Decidim
  # This class stores different stats computations and resolves them given a context.
  class StatsRegistry
    HIGH_PRIORITY = 1 # The priority of the stat used for render organization level stats.
    MEDIUM_PRIORITY = 2 # The priority of the stat used for render participatory space level stats.
    LOW_PRIORITY = 3

    attr_reader :stats

    # Public: Initializes the object with an optional stats array
    #
    # stats - An array of Hashes to represent a stat object
    def initialize(stats = [])
      @stats = stats
    end

    # Public: Register a stat
    #
    # name - The name of the stat
    # options - A hash of options
    #         * primary: Whether the stat is primary or not.
    #         * priority: The priority of the stat used for render issues.
    # block - A block that receive the components to filter out the stat.
    def register(name, options = {}, &block)
      stat = @stats.detect { |s| s[:name] == name }
      raise StandardError, "Stats '#{name}' is already registered." if stat.present?

      options[:primary] ||= false
      options[:admin] = true unless options.has_key?(:admin)
      options[:priority] ||= LOW_PRIORITY

      @stats.push(name:,
                  primary: options[:primary],
                  priority: options[:priority],
                  tag: options[:tag],
                  icon_name: options[:icon_name],
                  tooltip_key: options[:tooltip_key],
                  sub_title: options[:sub_title],
                  admin: options[:admin],
                  block:)
    end

    # Public: Returns a number returned by executing the corresponding block.
    #
    # name - The name of the stat
    # context - An arbitrary context object to compute the result.
    # start_at - A date to filter resources created after it
    # end_at - A date to filter resources created before it.
    #
    # Returns the result of executing the stats block using the passing context or an error.
    def resolve(name, context, start_at = nil, end_at = nil)
      stat = @stats.detect { |s| s[:name] == name }
      return stat[:block].call(context, start_at, end_at) if stat.present?

      raise StandardError, "Stats '#{name}' is not registered."
    end

    # Public: Resolves every stat with the given context and return an enumerator
    #
    # context - An arbitrary context object to compute the result.
    # start_at - A date to filter resources created after it
    # end_at - A date to filter resources created before it
    #
    # Returns an Enumerator where each value is a tuple of name and resolved value
    def with_context(context, start_at = nil, end_at = nil)
      Enumerator.new do |yielder|
        @stats.each do |stat|
          yielder << {
            name: stat[:name],
            data: resolve(stat[:name], context, start_at, end_at),
            icon_name: stat[:icon_name],
            tooltip_key: stat[:tooltip_key],
            sub_title: stat[:sub_title],
            admin: stat[:admin]
          }
        end
      end
    end

    # Public: Creates a new registry with the filtered stats
    #
    # conditions - A hash of conditions
    #            * primary: Whether the stat is primary or not.
    #            * priority: The priority of the stat used for render issues.
    #
    # Returns a new StatsRegistry with the filtered stats
    def filter(conditions)
      filtered_stats = @stats.select do |stat|
        selected = true
        conditions.each do |condition, value|
          selected = false if stat[condition] != value
        end
        selected
      end
      StatsRegistry.new(filtered_stats)
    end

    # Public: Creates a new registry with all stats except the provided ones
    #
    # names - An Array of stats names to exclude
    #
    # Returns a new StatsRegistry with the selected stats
    def except(names)
      filtered_stats = @stats.reject do |stat|
        names.include? stat[:name]
      end
      StatsRegistry.new(filtered_stats)
    end

    # Public: Creates a new registry with only the stats included into the provided ones
    #
    # names - An Array of stats names to include
    #
    # Returns a new StatsRegistry with the selected stats
    def only(names)
      filtered_stats = @stats.select do |stat|
        names.include? stat[:name]
      end
      StatsRegistry.new(filtered_stats)
    end
  end
end
