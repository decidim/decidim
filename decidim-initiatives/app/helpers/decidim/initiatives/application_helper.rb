# frozen_string_literal: true

module Decidim
  module Initiatives
    # Custom helpers, scoped to the initiatives engine.
    #
    module ApplicationHelper
      include Decidim::CheckBoxesTreeHelper
      include Decidim::DateRangeHelper
      include InitiativesHelper

      def filter_states_values
        TreeNode.new(
          TreePoint.new("", filter_text_for(t("decidim.initiatives.application_helper.filter_state_values.all"))),
          [
            TreePoint.new("open", filter_text_for(t("decidim.initiatives.application_helper.filter_state_values.open"))),
            TreeNode.new(
              TreePoint.new("closed", filter_text_for(t("decidim.initiatives.application_helper.filter_state_values.closed"))),
              [
                TreePoint.new("accepted", filter_text_for(t("decidim.initiatives.application_helper.filter_state_values.accepted"))),
                TreePoint.new("rejected", filter_text_for(t("decidim.initiatives.application_helper.filter_state_values.rejected")))
              ]
            ),
            TreePoint.new("answered", filter_text_for(t("decidim.initiatives.application_helper.filter_state_values.answered")))
          ]
        )
      end

      def filter_types_values
        types_values = Decidim::InitiativesType.where(organization: current_organization).map do |type|
          TreeNode.new(
            TreePoint.new(type.id.to_s, filter_text_for(type.title[I18n.locale.to_s]))
          )
        end

        TreeNode.new(
          TreePoint.new("", filter_text_for(t("decidim.initiatives.application_helper.filter_type_values.all"))),
          types_values
        )
      end

      def component_name
        (defined?(current_component) && translated_attribute(current_component&.name).presence) || t("decidim.admin.models.initiatives.fields.title")
      end
    end
  end
end
