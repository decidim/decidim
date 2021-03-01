# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # This class holds a Form to create/update votings from Decidim's admin panel.
      class PollingStationForm < Decidim::Form
        include TranslatableAttributes

        def map_model(model)
          self.polling_station_president_id = model.polling_station_president&.id
          self.polling_station_manager_ids = model.polling_station_managers.pluck(:id)
        end

        def geocoding_enabled?
          Decidim::Map.available?(:geocoding)
        end

        def has_address?
          geocoding_enabled? && address.present?
        end

        def geocoded?
          latitude.present? && longitude.present?
        end

        def polling_station_president
          @polling_station_president ||= PollingOfficer.find_by(id: polling_station_president_id)
        end

        def polling_station_managers
          @polling_station_managers ||= PollingOfficer.where(id: polling_station_manager_ids)
        end

        def voting
          @voting ||= context[:voting]
        end

        translatable_attribute :title, String
        translatable_attribute :location, String
        translatable_attribute :location_hints, String
        attribute :address, String
        attribute :latitude, Float
        attribute :longitude, Float
        attribute :polling_station_president_id, Integer
        attribute :polling_station_manager_ids, Array[Integer]

        validates :title, translatable_presence: true
        validates :location, translatable_presence: true
        validates :location_hints, translatable_presence: true
        validates :address, presence: true
        validates :address, geocoding: true, if: ->(form) { form.has_address? && !form.geocoded? }

        alias component voting
      end
    end
  end
end
