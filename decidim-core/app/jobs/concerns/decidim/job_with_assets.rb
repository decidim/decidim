# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # This module configures the asset router for the jobs as there is no request
  # present causing the asset router have to do extra work when resolving the
  # correct hostname for each asset separately. This can be heavy especially
  # during export jobs when potentially a large amount of records is exported
  # and the host resolving would have to be otherwise repeated for each record
  # individually causing potentially a lot of unnecessary database queries
  # performed during the job.
  #
  # The best way to use this is to have a named argument `organization` defined
  # for the `#perform` method of the job that has the associated organization.
  # This module will resolve the organization from the value passed to that
  # argument position. Alternatively, if one of the arguments passed to the
  # `#perform` method return the organization through the `#organization` method
  # or association, that will also work. Otherwise, the default host will be
  # configured for the assets through `EngineRouter#default_url_options`.
  module JobWithAssets
    extend ActiveSupport::Concern

    included do
      before_perform :configure_activestorage
    end

    private

    # Configures the ActiveStorage URL options for generating asset URLs.
    #
    # @return [void]
    def configure_activestorage
      options = EngineRouter.new("main_app", {}).default_url_options
      options[:host] = organization.host if organization
      return if options[:host].blank?

      ActiveStorage::Current.url_options = options
    end

    # Resolves the organization through the arguments passed to the `perform`
    # method and returns the value if found.
    #
    # @return [Decidim::Organization, nil] The resolved organization record or
    #   nil if it could not be resolved.
    def organization
      return @organization if instance_variable_defined?(:@organization)

      @organization = OrganizationArgumentResolver.resolve(method(:perform), arguments)
    end

    class OrganizationArgumentResolver
      # Syntatic sugar for creating a new instance and running the `#resolve`
      # method on it.
      #
      # @param source_method (see #initialize)
      # @param values (see #initialize)
      # @return (see #resolve)
      def self.resolve(source_method, values)
        new(source_method, values).resolve
      end

      # Initializes the resolver.
      #
      # @param source_method [Method] The source method that receives the
      #   arguments.
      # @param values [Array] An array of the values passed to the
      #   source_method's arguments.
      def initialize(source_method, values)
        @source_method = source_method
        @values = values
      end

      # Tries to resolve the organization from the source method arguments and
      # their values.
      #
      # @return [Decidim::Organization, nil] The resolved organization record or
      #   nil if not found.
      def resolve
        from_named_argument || from_argument_values || from_argument_value_associations
      end

      private

      attr_reader :source_method, :values

      # Finds the position of the named argument `organization` if such argument
      # is defined for the source method. If defined, fetches its value and
      # returns it if it is a `Decidim::Organization`.
      #
      # @return [Decidim::Organization, nil] The resolved organization record or
      #   nil if not found.
      def from_named_argument
        org_arg = source_method.parameters.find_index { |p| p[0] == :req && p[1] == :organization }
        org = values[org_arg] unless org_arg.nil?
        org if org.is_a?(Decidim::Organization)
      end

      # Iterates over all arguments and returns the value if the value is a
      # `Decidim::Organization`.
      #
      # @return [Decidim::Organization, nil] The resolved organization record or
      #   nil if not found.
      def from_argument_values
        org = values.find { |arg| arg.is_a?(Decidim::Organization) }
        org if org.is_a?(Decidim::Organization)
      end

      # Iterates over all arguments and returns the first value's associated
      # organization if the value responds to `organization` that returns a
      # `Decidim::Organization`.
      #
      # @return [Decidim::Organization, nil] The resolved organization record or
      #   nil if not found.
      def from_argument_value_associations
        org = values.find { |arg| arg.respond_to?(:organization) }&.organization
        org if org.is_a?(Decidim::Organization)
      end
    end
  end
end
