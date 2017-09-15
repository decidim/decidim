# frozen_string_literal: true

module Decidim
  #
  # Utilities for models that can act as participatory spaces
  #
  module Participable
    extend ActiveSupport::Concern

    # rubocop:disable Metrics/BlockLength
    included do
      def demodulized_name
        self.class.name.demodulize
      end

      def foreign_key
        demodulized_name.foreign_key
      end

      def module_name
        "Decidim::#{demodulized_name.pluralize}"
      end

      def admin_module_name
        "#{module_name}::Admin"
      end

      def underscored_name
        demodulized_name.underscore
      end

      def mounted_engine
        "decidim_#{underscored_name.pluralize}"
      end

      def mounted_admin_engine
        "decidim_admin_#{underscored_name.pluralize}"
      end

      def mounted_params
        {
          host: organization.host,
          "#{underscored_name}_slug".to_sym => slug,
          foreign_key.to_sym => id
        }
      end

      def extension_module
        "#{module_name}::#{demodulized_name}Context".constantize
      end

      def admin_extension_module
        "#{admin_module_name}::#{demodulized_name}Context".constantize
      end

      def admins_query
        "#{admin_module_name}::AdminUsers".constantize
      end

      def admins
        admins_query.for(self)
      end

      def allows_steps?
        respond_to?(:steps)
      end

      def has_steps?
        allows_steps? && steps.any?
      end

      def manifest
        self.class.participatory_space_manifest
      end
    end
    # rubocop:enable Metrics/BlockLength

    class_methods do
      def participatory_space_manifest
        Decidim.find_participatory_space_manifest(name.demodulize.underscore.pluralize)
      end
    end
  end
end
