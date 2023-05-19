# frozen_string_literal: true

module Decidim
  module Admin
    class ContentBlockCell < Decidim::ViewModel
      include Decidim::IconHelper
      include Decidim::ContentBlocks::HasRelatedComponents

      delegate :public_name_key, :has_settings?, :component_manifest_name, to: :model
      delegate :content_block_destroy_confirmation_text, to: :controller

      def edit_content_block_path
        raise "#{self.class.name} is expected to implement #edit_content_block_path"
      end

      def content_block_path
        raise "#{self.class.name} is expected to implement #content_block_path"
      end

      def component
        @component ||= if component_manifest_name.present?
                         components = components_for(model)
                         component_id = model.settings.try(:component_id)
                         components = components.where(id: component_id) if component_id.present?

                         components.first if components.one?
                       end
      end

      def name
        return I18n.t(public_name_key) if component.blank?

        "#{I18n.t(public_name_key)} (#{translated_attribute(component&.name)})"
      end
    end
  end
end
