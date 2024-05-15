# frozen_string_literal: true

module Decidim
  module Design
    module AddressHelper
      def address_sections
        [
          {
            id: t("decidim.design.helpers.demo"),
            contents: [
              {
                type: :text,
                values: [
                  t("decidim.design.helpers.address_description")
                ]
              },
              {
                values: cell("decidim/address", address_item)
              },
              {
                type: :text,
                values: [
                  t("decidim.design.helpers.address_description_2")
                ]
              },
              {
                values: cell("decidim/address", online_item, online: true)
              }
            ]
          },
          {
            id: t("decidim.design.helpers.source_code"),
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

          attr_accessor :organization, :location, :address, :latitude, :longitude, :online_meeting_url, :type_of_meeting, :start_time, :end_time

          geocoded_by :address
        end
      end

      def address_item
        addressable_class.new(
          organization: current_organization,
          location: "Barcelona",
          address: "Carrer del Pare Llaurador, 113",
          latitude: 40.1234,
          longitude: 2.1234,
          start_time: 2.days.from_now,
          end_time: 2.days.from_now + 4.hours
        )
      end

      def online_item
        addressable_class.new(
          organization: current_organization,
          type_of_meeting: "online",
          online_meeting_url: "https://meet.jit.si/DecidimTry",
          start_time: 2.days.from_now,
          end_time: 2.days.from_now + 4.hours
        )
      end
    end
  end
end
