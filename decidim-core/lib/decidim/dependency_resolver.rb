# frozen_string_literal: true

module Decidim
  # The dependency resolver provides information about the Decidim module
  # dependencies. For instance, it can be used to check if a particular Decidim
  # module is needed by the instance or not.
  #
  # This is a singleton utility in order to make it perform better when it is
  # called from different places throughout the application.
  #
  # @example Checking whether a module is needed by the instance
  #   Decidim::DependencyResolver.instance.needed?("decidim-proposals")
  class DependencyResolver
    include Singleton

    def initialize
      @cache = []
    end

    # Finds a gem specification for the gem with the name provided as the
    # argument.
    #
    # When bundler is available, searches whether the gem is listed in the
    # Gemfile or required as a dependency for one of the gems in the Gemfile or
    # their dependencies.
    #
    # When bundler is not available, gets the gem specification from the loaded
    # specs which means any gems available in the gem install folder.
    #
    # @param gem [String] The name for the gem to be looked up.
    # @return [Bundler::LazySpecification, Gem::Specification, nil] When bundler
    #   is available, returns `Bundler::LazySpecification`. When bundler is not
    #   available, returns `Gem::Specification`. Both of these implement the
    #   necessary methods for the other checks. In both cases returns nil if
    #   the gem is not found.
    def lookup(gem)
      # In case the lookup method is called with a spec definition, return the
      # definition itself.
      return gem unless gem.is_a?(String)

      if bundler?
        lookup = Lookup.new
        return lookup.spec(gem) if cache.include?(gem)

        # Keep a local cache of the already processed gems in order to avoid
        # double lookups.
        lookup.find(Bundler.definition.dependencies, gem) do |dependency|
          if potential_module?(dependency.name)
            cache_miss = cache.exclude?(dependency.name)
            cache << dependency.name if cache_miss
            cache_miss
          else
            false
          end
        end
      else
        return unless potential_module?(gem)

        Gem.loaded_specs[gem]
      end
    end

    # Resolves the main load file path for module defined by the gem
    # specification.
    #
    # @param spec [Bundler::LazySpecification, Gem::Specification, String] The
    #   gem specification to test or the name of the gem.
    # @return [String] A string pointing the path to the module's main load
    #   file.
    def module_path(spec)
      spec = lookup(spec)
      return unless spec

      "#{spec.full_gem_path}/lib/#{spec.name.gsub("-", "/")}.rb"
    end

    # Resolves whether the module for the gem specification defines the main
    # load file.
    #
    # @param spec [Bundler::LazySpecification, Gem::Specification, String] The
    #   gem specification to test or the name of the gem.
    # @return [Boolean] A boolean indicating if the gem defined by the spec is
    #   available for loading.
    def available?(spec)
      path = module_path(spec)
      return false unless path

      File.exist?(path)
    end

    # Checks if the module for the gem speficiation has been loaded through
    # `require "decidim/foo"`.
    #
    # @param spec [Bundler::LazySpecification, Gem::Specification, String] The
    #   gem specification to test or the name of the gem.
    # @return [Boolean] A boolean indicating if the gem defined by the spec is
    #   loaded.
    def loaded?(spec)
      return false unless available?(spec)

      $LOADED_FEATURES.include?(module_path(spec))
    end

    # Resolves whether the target gem is needed or not, i.e. does it need to be
    # loaded.
    #
    # When bundler is available, the dependencies are resolved based on the
    # modules defined in the Gemfile which means that the gem is always needed
    # when it is reported as available by the resolver (i.e. defined as a
    # dependency in the Gemfile itself or one of those gems depend on it).
    #
    # When bundler is not available, this will check whether the Decidim module
    # provided by the gem has been already required/loaded or not. In this
    # situation, it is impossible to know whether the implementer has intended
    # the gem to be used or not, so we assume in these situations implementers
    # will load all the gems they want before running any initializers. This
    # means that the `require "decidim/foo"` statements have to be listed for
    # all modules before the initialization process.
    #
    # @param spec [Bundler::LazySpecification, Gem::Specification, String] The
    #   gem specification to test or the name of the gem.
    # @return [Boolean] A boolean indicating if the gem defined by the spec is
    #   needed.
    def needed?(spec)
      spec = lookup(spec)
      return false unless spec

      if bundler?
        available?(spec)
      else
        loaded?(spec)
      end
    end

    private

    attr_accessor :cache

    # Reports whether bundler is available.
    #
    # @return [Boolean] A boolean indicating if bundler is available or not.
    def bundler?
      defined?(Bundler)
    end

    # Only match the decidim gems. Skip the decidim-dev gem because it has
    # "decidim" as a runtime dependency which would cause all the default
    # gems to be always reported as available.
    def potential_module?(name)
      name != "decidim-dev" && name =~ /decidim(-.*)?/
    end

    # The lookup class takes care of the individual recursive lookups over a
    # dependency tree.
    class Lookup
      # @param debug [Boolean] A boolean indicating if the debug mode is enabled
      #   or not. False by default.
      def initialize(debug: false)
        @current_level = 0
        return unless debug

        formatter = proc do |_severity, _datetime, _progname, msg|
          "#{msg}\n"
        end
        @logger = Logger.new($stdout, formatter: formatter)
        logger.debug!
      end

      # Iterates recursively through the runtime dependencies array and their
      # sub-dependencies to find whether the provided gem is included. This
      # always iterates through the whole dependency tree even when the gem is
      # already found in order not to process the same dependencies multiple
      # times and to make the cache work correctly when calling this.
      #
      # @param dependencies [Array] An array of the dependencies to iterate
      #   through.
      # @param gem [String] The name of the gem to find.
      # @yield [dependency] Yields each dependency to be processed to the
      #   provided block to check if that dependency needs to be processed or
      #   not.
      # @yieldparam [Gem::Dependency] The runtime dependency being processed.
      # @yieldreturn [Boolean] A boolean indicating whether this dependency
      #   needs to be processed or not. True indicates it needs to be processed
      #   and false indicates processing is not needed.
      # @return [Bundler::LazySpecification, nil] The specification for the gem
      #   or nil when it is not found.
      def find(dependencies, gem, &block)
        found = nil
        dependencies.each do |dependency|
          next unless process?(dependency, &block)

          spec = spec(dependency.name)
          next unless spec # E.g. the "bundler" gem is not in the locked gems

          log(dependency)

          found ||= spec if spec.name == gem

          @current_level += 1
          # Do not se the found value directly here because otherwise the
          # recursive call would not be made if the target gem is already found.
          sub_spec = find(spec.dependencies, gem, &block)
          @current_level -= 1
          found ||= sub_spec
        end

        found
      end

      # Finds a gem specification from the locked gems of the instance.
      #
      # Note that this does not resolve if the module is needed or not. This may
      # also return the gem specification even when it is not listed in the
      # Gemfile, e.g. when the Decidim gems are installed through git.
      #
      # @param name [String] The name of the gem to find.
      # @return [Bundler::LazySpecification, nil] The specification for the gem
      #   or nil if the gem is not listed in the locked gems.
      def spec(name)
        Bundler.definition.locked_gems.specs.find { |s| s.name == name }
      end

      private

      attr_reader :logger, :current_level

      # Decides whether a dependency needs to be processed, i.e. compared
      # whether it is the gem to be found.
      #
      # @param dependency [Gem::Dependency] The dependency being processed.
      # @yield [dependency] Yields each dependency to be processed to the
      #   provided block to check if that dependency needs to be processed or
      #   not.
      # @yieldparam [Gem::Dependency] The runtime dependency being processed.
      # @yieldreturn [Boolean] A boolean indicating whether this dependency
      #   needs to be processed or not. True indicates it needs to be processed
      #   and false indicates processing is not needed.
      # @return [Boolean] A boolean indicating whether the dependency needs to
      #   be processed, i.e. compared whether it is the gem to be found.
      def process?(dependency)
        return false unless dependency.type == :runtime
        return true unless block_given?

        yield(dependency)
      end

      # Writes a log message for the given dependency at the current level of
      # processing. When debugging is enabled, will produce the following kind
      # of log output indicating the lookup tree.
      #
      # @example
      #   decidim-admin
      #   --decidim-core
      #   ----decidim-api
      #   decidim-assemblies
      #   decidim-blogs
      #   --decidim-comments
      #
      # @param dependency [Gem::Dependency] The dependency to be logged at the
      #   current level of processing.
      # @return [Boolean] A boolean indicating whether logging happened or not.
      def log(dependency)
        return false unless logger

        logger.debug("#{"--" * current_level}#{dependency.name}")
      end
    end
  end
end
