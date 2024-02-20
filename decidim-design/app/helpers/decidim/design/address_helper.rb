# frozen_string_literal: true

module Decidim
  module Design
    module AddressHelper
      def address_sections
        [
          {
            id: "demo",
            contents: [
              {
                type: :text,
                values: [
                  "Address cell receives a resource, and searches the geolocalizable attributes to render an specific markup."
                ]
              },
              {
                values: cell("decidim/address", address_item)
              },
              {
                type: :text,
                values: [
                  "Depending of the type of the content, the address could be an online url.
                    For such cases, the displayed information is quite the same but shaped to fit."
                ]
              },
              {
                values: cell("decidim/address", online_item, online: true)
              }
            ]
          },
          {
            id: "source_code",
            contents: [
              {
                type: :text,
                values: [""],
                cell_snippet: {
                  cell: "decidim/address",
                  args: [address_item],
                  call_string: [
                    'cell("decidim/address", _RESOURCE_)',
                    'cell("decidim/address", _RESOURCE_, online: true)'
                  ]
                }
              }
            ]
          }
        ]
      end

      def addressable_class
        Class.new(ApplicationRecord) do
          self.table_name = Decidim::Pages::Page.table_name

          attr_accessor :organization, :location, :address, :latitude, :longitude, :online_meeting_url, :type_of_meeting

          geocoded_by :address
        end
      end

      def address_item
        addressable_class.new(
          organization: current_organization,
          location: "Barcelona",
          address: "Carrer del Pare Llaurador, 113",
          latitude: 40.1234,
          longitude: 2.1234
        )
      end

      def online_item
        addressable_class.new(
          organization: current_organization,
          type_of_meeting: "online",
          online_meeting_url: "https://meet.jit.si/DecidimTry"
        )
      end
    end
  end
end
