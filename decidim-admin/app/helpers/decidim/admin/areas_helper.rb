# frozen_string_literal: true

module Decidim
  module Admin
    # This module includes helpers to show areas in admin
    module AreasHelper
      Option = Struct.new(:id, :name)

      # Public: A formatted collection of areas for a given organization to be used
      # in forms.
      #
      # organization - Organization object
      #
      # Returns an Array.
      def organization_area_types(organization = current_organization)
        [Option.new("", "-")] +
          organization.area_types.map do |area_type|
            Option.new(area_type.id, translated_attribute(area_type.name))
          end
      end
    end
  end
end
