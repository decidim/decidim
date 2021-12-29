# frozen_string_literal: true

require "geocoder/stores/active_record"

module Decidim
  # This concern overrides some of the Active Record functionality injected by
  # the Geocoder gem in order to pass the geocoding searches through Decidim's
  # own API which configures the geocoder correctly for each search. This is
  # used when the `model.geocode` and `model.reverse_geocode` methods are called
  # for the Active Record models.
  #
  # NOTE: This module is automatically loaded for all active record models in
  #       the "decidim.geocoding_extensions" initializer. It does not need to be
  #       included separately into any models.
  module Geocodable
    extend ActiveSupport::Concern

    class_methods do
      # Avoid double loading Geocoder::Store::ActiveRecord since it's already
      # loaded by this concern (below in the included block).
      def geocoder_init(options)
        @geocoder_options = {} unless defined?(@geocoder_options)
        @geocoder_options.merge! options
      end
    end

    included do
      include Geocoder::Store::ActiveRecord

      def geocoded_and_valid?
        geocoded? && to_coordinates.none?(&:nan?)
      end

      private

      # rubocop:disable Style/OptionalBooleanParameter
      def do_lookup(_reverse = false)
        RecordGeocoder.with_record(self) do
          super
        end
      end
      # rubocop:enable Style/OptionalBooleanParameter
    end

    module RecordGeocoder
      def self.with_record(record)
        @record = record
        yield
      ensure
        @record = nil
      end

      def self.utility
        return if @record.blank?
        return unless Decidim::Map.available?(:geocoding)
        return unless @record.respond_to?(:organization)

        Decidim::Map.geocoding(organization: @record.organization)
      end

      def self.search(query, options = {})
        if (util = utility)
          util.search(query, options.compact)
        else
          Geocoder.search(query, options)
        end
      end

      # Make the calculation functions work within the geocoded record, e.g.
      # `distance_to`.
      module Calculations
        extend Geocoder::Calculations
      end
    end

    # Change the `Geocoder` module reference under the Geocoder::Store::Base
    # module which initiates the geocoding searches. This allows passing the
    # geocoding queries through Decidim's own API that configures the geocoder
    # correctly for each query.
    #
    # Overrides this call with the method defined above:
    # https://git.io/JJEpq
    ::Geocoder::Store::Base.const_set(:Geocoder, RecordGeocoder)
  end
end
