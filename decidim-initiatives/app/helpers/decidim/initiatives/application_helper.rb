# frozen_string_literal: true

module Decidim
  module Initiatives
    # Custom helpers, scoped to the initiatives engine.
    #
    module ApplicationHelper
      include Decidim::CheckBoxesTreeHelper

      def filter_states_values
        TreeNode.new(
          TreePoint.new("", t("decidim.initiatives.application_helper.filter_state_values.all")),
          [
            TreePoint.new("open", t("decidim.initiatives.application_helper.filter_state_values.open")),
            TreeNode.new(
              TreePoint.new("closed", t("decidim.initiatives.application_helper.filter_state_values.closed")),
              [
                TreePoint.new("accepted", t("decidim.initiatives.application_helper.filter_state_values.accepted")),
                TreePoint.new("rejected", t("decidim.initiatives.application_helper.filter_state_values.rejected"))
              ]
            ),
            TreePoint.new("answered", t("decidim.initiatives.application_helper.filter_state_values.answered"))
          ]
        )
      end

      def filter_types_values
        types_values = Decidim::InitiativesType.where(organization: current_organization).map do |type|
          TreeNode.new(
            TreePoint.new(type.id.to_s, type.title[I18n.locale.to_s])
          )
        end

        TreeNode.new(
          TreePoint.new("", t("decidim.initiatives.application_helper.filter_type_values.all")),
          types_values
        )
      end

      def filter_areas_values
        areas_or_types = areas_for_select(current_organization)

        areas_values = if areas_or_types.first.is_a?(Decidim::Area)
                         filter_areas(areas_or_types)
                       else
                         filter_areas_and_types(areas_or_types)
                       end

        TreeNode.new(
          TreePoint.new("", t("decidim.initiatives.application_helper.filter_area_values.all")),
          areas_values
        )
      end

      def filter_areas(areas)
        areas.map do |area|
          TreeNode.new(
            TreePoint.new(area.id.to_s, area.name[I18n.locale.to_s])
          )
        end
      end

      def filter_areas_and_types(area_types)
        area_types.map do |area_type|
          TreeNode.new(
            TreePoint.new(area_type.area_ids.join("_"), area_type.name[I18n.locale.to_s]),
            area_type.areas.map do |area|
              TreePoint.new(area.id.to_s, area.name[I18n.locale.to_s])
            end
          )
        end
      end
    end
  end
end
