# frozen_string_literal: true

module Decidim
  module ContentBlocks
    # Base cell to wrap each content block which identifies also the resource
    # the block belongs to
    class BaseCell < Decidim::ViewModel
      def resource
        @resource ||= base_model.presence && base_model.find(model.scoped_resource_id)
      end

      private

      def base_model
        @base_model ||= options[:base_model] ||
                        case model.scope_name
                        when "participatory_process_group_homepage"
                          Decidim::ParticipatoryProcessGroup
                        when "participatory_process_homepage"
                          Decidim::ParticipatoryProcess
                        end
      end

      def section_class
        return "content-block" if extra_classes.blank?

        "content-block #{extra_classes}"
      end

      def data; end

      def prefixed_class(name)
        [classes_prefix, name].compact.join("__")
      end

      def extra_classes; end

      def classes_prefix; end
    end
  end
end
