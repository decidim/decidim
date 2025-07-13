# frozen_string_literal: true

module Decidim
  class MapCell < Decidim::ViewModel
    include Decidim::MapHelper

    def show
      return unless Decidim::Map.available?(:geocoding, :dynamic)

      render
    end

    def geocoded_data
      @geocoded_data ||= data_for_map
    end

    private

    def data_for_map
      data = model.select(&:geocoded_and_valid?)
      data.map do |map|
        map.slice(:latitude, :longitude, :address)
           .merge(
             title: map.presenter.title,
             link: resource_locator(map).path,
             items: cell(options[:metadata_card], map).send(:items_for_map).to_json
           )
      end
    end

    def metadata_card
      "decidim/meetings/meeting_card_metadata"
    end

    def cache_hash
      nil
    end
  end
end
