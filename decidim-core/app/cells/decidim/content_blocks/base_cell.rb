# frozen_string_literal: true

module Decidim
  module ContentBlocks
    # Base cell to wrap each content block which identifies also the resource
    # the block belongs to
    class BaseCell < Decidim::ViewModel
      # This constant contains the relation between the different scope names
      # and the models to find the resource with the id stored in
      # scoped_resource_id.For future associations with other participatory spaces
      # extend this hash
      SCOPE_ASSOCIATIONS = {
        homepage: "Decidim::Organization",
        participatory_process_group_homepage: "Decidim::ParticipatoryProcessGroup",
        participatory_process_homepage: "Decidim::ParticipatoryProcess"
      }.with_indifferent_access.freeze

      def resource
        @resource ||= base_model.presence && base_model.find(model.scoped_resource_id)
      end

      private

      def base_model
        @base_model ||= options[:base_model] || SCOPE_ASSOCIATIONS[model.scope_name]&.safe_constantize
      end

      def section_class
        return "content-block" if extra_classes.blank?

        "content-block #{extra_classes}"
      end

      def data; end

      def block_id; end

      def extra_classes; end
    end
  end
end
