# frozen_string_literal: true

# This validator takes care of ensuring the validated content is
# an existing address and computes its coordinates.
class GeocodingValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if Decidim.geocoder.present? && record.feature.present?
      organization = record.feature.organization
      Geocoder.configure(Geocoder.config.merge(http_headers: { "Referer" => organization.host }))
      coordinates = Geocoder.coordinates(value)

      if coordinates.present?
        record.latitude = coordinates.first
        record.longitude = coordinates.last
      else
        record.errors.add(attribute, :invalid)
      end
    else
      record.errors.add(attribute, :invalid)
    end
  end
end
