# coding: utf-8
# frozen_string_literal: true
# This validator takes care of ensuring the validated content is
# an existing address and computes its coordinates.
class GeocodingValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    coordinates = Geocoder.coordinates(value)

    if coordinates.present?
      record.latitude = coordinates.first
      record.longitude = coordinates.last
    else
      record.errors.add(attribute, :invalid)
    end
  end
end
