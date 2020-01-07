# frozen_string_literal: true

require "active_support/concern"

# ActiveRecord stores timestamps in UTC and converts them into the application's time zone
#
# This module provides a simple to use API to automatically generate '_local' suffix methods
# that provides dates/times according to the organization time_zone.
module Decidim
  module LocalDateTimeAttrReaders
    extend ActiveSupport::Concern

    included do
      include ActiveModel::AttributeMethods
    end

    class_methods do
      # Registers attribute reader methods with +_local+ suffix to read
      # +Date+, +Time+ and +DateTime+ typed attributes in local time.
      #
      #   class Debate
      #     include LocalDateTimeAttrReaders
      #
      #     local_datetime_attr_reader :start_time
      #   end
      #
      #   debate.start_time
      #   => Date instance using global application time zone
      #
      #   user.start_time_local
      #   => Date instance using time zone specified in organization.time_zone (ie: "Europe/Berlin")
      def local_attr_reader(*attrs)
        # We use ActiveModel::AttributeMethods instead of manually registering methods
        attribute_method_suffix "_local"

        attrs.each { |attr| define_attribute_method attr }
      end

      alias_method :local_date_attr_reader, :local_attr_reader
      alias_method :local_time_attr_reader, :local_attr_reader
      alias_method :local_datetime_attr_reader, :local_attr_reader
    end

    private

    def attribute_local(attr)
      send(attr).in_time_zone(time_zone_reader)
    end

    def time_zone_reader
      return organization.time_zone if respond_to? :organization

      Time.zone
    end
  end
end
