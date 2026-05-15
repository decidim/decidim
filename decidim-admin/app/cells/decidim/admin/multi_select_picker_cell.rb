# frozen_string_literal: true

module Decidim
  module Admin
    # Universal cell for rendering multi-select pickers
    class MultiSelectPickerCell < Decidim::ViewModel
      include ActionView::Helpers::FormOptionsHelper

      def show
        render :show
      end

      def cell_options_for_select
        context[:options_for_select] || []
      end

      def selected_values
        context[:selected_values] || []
      end

      def select_id
        context[:select_id]
      end

      def field_name
        context[:field_name]
      end

      def placeholder
        context[:placeholder] || ""
      end

      def css_classes
        context[:class] || ""
      end
    end
  end
end
