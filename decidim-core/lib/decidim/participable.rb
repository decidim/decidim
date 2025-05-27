# frozen_string_literal: true

module Decidim
  #
  # Utilities for models that can act as participatory spaces
  #
  module Participable
    extend ActiveSupport::Concern

    included do
      delegate :demodulized_name, :foreign_key, :module_name, :admin_module_name, :underscored_name,
               :mounted_engine, :mounted_admin_engine, :admin_extension_module, :admins_query,
               to: :class

      def skip_space_slug?(method_name)
        [
          :"edit_#{underscored_name}_path",
          :"edit_#{underscored_name}_url",
          :"new_#{underscored_name}_path",
          :"new_#{underscored_name}_url",
          :"#{underscored_name}_path",
          :"#{underscored_name}_url",
          :"#{underscored_name.pluralize}_path",
          :"#{underscored_name.pluralize}_url"
        ].include?(method_name)
      end

      def slug_param_name
        :"#{underscored_name}_slug"
      end

      def mounted_params
        {
          :host => organization.host,
          :locale => I18n.locale,
          :"#{underscored_name}_slug" => slug
        }
      end

      def admins
        admins_query.for(self)
      end

      # Public: Returns an ActiveRecord::Relation of all the users that can
      # moderate the space. This is used when notifying of flagged/hidden
      # content.
      def moderators
        admins
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

      def can_participate?(_user)
        true
      end

      def empty_published_component?
        components.published.empty?
      end

      def cta_button_text_key
        return :more_info if empty_published_component?

        :take_part
      end

      def cta_button_text_key_accessible
        return :more_info_about if empty_published_component?

        :take_part_in
      end
    end

    class_methods do
      def demodulized_name
        @demodulized_name ||= name.demodulize
      end

      delegate :foreign_key, to: :demodulized_name

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

      def admin_extension_module
        "#{admin_module_name}::#{demodulized_name}Context".constantize
      end

      def admins_query
        "#{admin_module_name}::AdminUsers".constantize
      end

      def moderators(organization)
        admins_query.for_organization(organization)
      end

      def slug_format
        /\A[a-zA-Z]+[a-zA-Z0-9-]+\z/
      end

      def participatory_space_manifest
        Decidim.find_participatory_space_manifest(name.demodulize.underscore.pluralize)
      end

      # Public: Is the class a participatory space?
      def participatory_space?
        true
      end

      # Public: Adds a sane default way to retrieve public spaces. Please, overwrite
      # this from your model class in case this is not correct for your model.
      #
      # Returns an `ActiveRecord::Association`.
      def public_spaces
        published
      end

      # Public: Adds a sane default way to retrieve active spaces. Please, overwrite
      # this from your model class in case this is not correct for your model.
      #
      # Returns an `ActiveRecord::Association`.
      def active_spaces
        public_spaces
      end

      # Public: Adds a sane default way to retrieve future spaces. Please, overwrite
      # this from your model class in case this is not correct for your model.
      #
      # Returns an `ActiveRecord::Association`.
      def future_spaces
        none
      end

      # Public: Adds a sane default way to retrieve past spaces. Please, overwrite
      # this from your model class in case this is not correct for your model.
      #
      # Returns an `ActiveRecord::Association`.
      def past_spaces
        none
      end
    end
  end
end
