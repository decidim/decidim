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
  module RedesignLayout
    extend ActiveSupport::Concern

    class_methods do
      def layout(layout, conditions = {})
        super unless layout.is_a?(String)

        super(redesigned_layout(layout), **conditions)
      end

      def redesign(opts = {})
        @enable_redesign = opts.fetch(:active, true)

        layout(_layout, _layout_conditions) if _layout
      end

      def redesign_participatory_space_layout(options = {})
        layout :participatory_space_redesign_layout, **options
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

      private

      def redesigned?(layout)
        %r{.*\K/_?redesigned}.match?(layout)
      end
    end

    included do
      delegate :redesigned_layout, :redesign, :redesign_defined?, to: :class

      def participatory_space_redesign_layout
        redesign unless redesign_defined?

        redesigned_layout(current_participatory_space_manifest.context(current_participatory_space_context).layout)
      end
    end
  end
end
