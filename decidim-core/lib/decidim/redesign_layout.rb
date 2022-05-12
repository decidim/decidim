# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # This concern contains the logic related with switching layouts for the new
  # design in controllers. Include this concern in the controllers with new
  # layouts
  #
  # To enable/disable new designs on a controller put in the controller
  # redesign active: false
  #
  # The new layout is expected to be defined at the same path with the name
  # prefixed with "redesigned_"
  #
  # If a controller calls layout use redesign active: true to use redesigned
  # layouts. This will affect to inheriting controllers not calling layout
  # again
  #
  # For participatory spaces replace participatory_space_layout with
  # redesign_participatory_space_layout. It will enable redesign for all
  # actions in the controller using redesigned FALLBACK_LAYOUT on actions not
  # covered by conditions
  #
  module RedesignLayout
    extend ActiveSupport::Concern

    FALLBACK_LAYOUT = "layouts/decidim/application"

    class_methods do
      def layout(layout, conditions = {})
        if layout.is_a?(String)
          super(redesigned_layout(layout), **conditions)
        else
          super
        end
      end

      def redesign(opts = {})
        @enable_redesign = opts.fetch(:active, true)
        layout_conditions = opts.slice(:except, :only) || _layout_conditions

        layout(_layout, **layout_conditions) if _layout
      end

      def redesign_participatory_space_layout(options = {})
        @redesign_layout_conditions = conditions_parsed(options)

        layout :participatory_space_redesign_layout
        before_action :authorize_participatory_space, **options
      end

      def redesigned_layout(layout_value)
        return layout_value unless layout_value.is_a?(String)

        if @enable_redesign && !redesigned?(layout_value)
          layout_value.sub(%r{.*\K/(_?)}, "/\\1redesigned_")
        elsif !@enable_redesign
          layout_value.sub(%r{.*\K/_?redesigned}, "/\\1")
        else
          layout_value
        end
      end

      def redesign_defined?
        !@enable_redesign.nil?
      end

      def redesign_enabled?
        @enable_redesign
      end

      def redesign_layout_conditions
        @redesign_layout_conditions
      end

      def default_layout
        @default_layout
      end

      private

      def redesigned?(layout)
        %r{.*\K/_?redesigned}.match?(layout)
      end

      def conditions_parsed(conditions = {})
        conditions.each { |k, v| conditions[k] = Array(v).map(&:to_s) }
      end
    end

    included do
      delegate :redesigned_layout, :redesign, :redesign_enabled?, :redesign_defined?, :redesign_layout_conditions, to: :class

      helper_method :redesigned_layout, :redesign_enabled?, :redesign_defined?

      helper_method :redesigned_layout, :redesign_enabled?, :redesign_defined?

      def participatory_space_redesign_layout
        redesign unless redesign_defined?

        if conditional_layout?
          redesigned_layout(current_participatory_space_manifest.context(current_participatory_space_context).layout)
        else
          redesigned_layout(FALLBACK_LAYOUT)
        end
      end

      def conditional_layout?
        return if redesign_layout_conditions.blank?

        if (only = redesign_layout_conditions[:only])
          only.include?(action_name)
        elsif (except = redesign_layout_conditions[:except])
          !except.exclude?(action_name)
        else
          true
        end
      end
    end
  end
end
