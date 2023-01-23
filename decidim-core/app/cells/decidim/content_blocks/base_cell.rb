# frozen_string_literal: true

module Decidim
  module ContentBlocks
    # Base cell to wrap each content block which identifies also the resource
    # the block belongs to
    class BaseCell < Decidim::ViewModel
      def resource
        @resource ||= base_relation.find(model.scoped_resource_id)
      end

      private

      def base_relation
        raise NotImplementedError, "Please, overwrite this method. Inheriting classes should define their own base relation"
      end

      def section_class
        return "content-block" if extra_classes.blank?

        "content-block #{extra_classes}"
      end

      def prefixed_class(name)
        [classes_prefix, name].compact.join("__")
      end

      def extra_classes; end

      def classes_prefix; end
    end
  end
end
