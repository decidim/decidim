# frozen_string_literal: true
module Decidim
  module Admin
    # Custom helpers, scoped to the admin panel.
    #
    module AttributesDisplayHelper
      # Displays the given attributes list in a list. This is a simple
      # `show_for` alternative, so there's no way to modify how an attribute is
      # shown and there is no intention on adding this. It is intnded to be
      # used inside a `dl` HTML tag, so you can customize how a specific
      # attribute has to be shown directly:
      #
      #   <dl>
      #     <%= display_for @post, :title, :body %>
      #     <dt>Comments number</dt>
      #     <dd>2</dd>
      #   </dl>
      #
      # This will render this HTML:
      #
      #   <dl>
      #     <dt>Title</dt>
      #     <dd>Hello, world!</dd>
      #     <dt>Body</dt>
      #     <dd>Lorem ipsum dolor sit amet...</dd>
      #     <dt>Comments number</dt>
      #     <dd>2</dd>
      #   </dl>
      #
      # record - any Ruby object that needs some attributes rendered
      # attrs - a list of N attributes of the `record`.
      def display_for(record, *attrs)
        attrs.map do |attr|
          display_label(record, attr) + display_value(record, attr)
        end.reduce(:+)
      end

      private

      # Private: Holds the logic to render a label for a given attribute.
      def display_label(record, attr)
        content_tag(:dt, record.class.human_attribute_name(attr))
      end

      # Private: Holds the logic to render the attribute value.
      def display_value(record, attr)
        association = record.class.reflect_on_all_associations.detect { |a| a.name == attr }
        if association.present?
          title = record.send(association.name).try(:name) || record.send(association.name).try(:title)
          content_tag(:dd, title)
        else
          content_tag(:dd, record.send(attr).try(:html_safe))
        end
      end
    end
  end
end
