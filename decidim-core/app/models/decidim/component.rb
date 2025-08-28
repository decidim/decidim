# frozen_string_literal: true

module Decidim
  # A Component represents a self-contained group of functionalities usually
  # defined via a ComponentManifest. It is meant to be able to provide a single
  # component that spans over several steps.
  class Component < ApplicationRecord
    include HasSettings
    include HasTaxonomySettings
    include Publicable
    include Traceable
    include Loggable
    include Decidim::ShareableWithToken
    include ScopableComponent
    include Decidim::SoftDeletable
    include TranslatableAttributes

    belongs_to :participatory_space, polymorphic: true

    scope :registered_component_manifests, -> { where(manifest_name: Decidim.component_registry.manifests.collect(&:name)) }
    scope :registered_space_manifests, -> { where(participatory_space_type: Decidim.participatory_space_registry.manifests.collect(&:model_class_name)) }

    default_scope { registered_component_manifests.registered_space_manifests.order(arel_table[:weight].asc, arel_table[:manifest_name].asc) }

    delegate :organization, to: :participatory_space

    def self.log_presenter_class_for(_log)
      Decidim::AdminLog::ComponentPresenter
    end

    # Other components with the same manifest and same participatory space as this one.
    def siblings
      @siblings ||= participatory_space.components.where.not(id:).where(manifest_name:)
    end

    # Public: Finds the manifest this component is associated to.
    #
    # Returns a ComponentManifest.
    def manifest
      Decidim.find_component_manifest(manifest_name)
    end

    # Public: Assigns a manifest to this component.
    #
    # manifest - The ComponentManifest for this Component.
    #
    # Returns nothing.
    def manifest=(manifest)
      self.manifest_name = manifest.name
    end

    # Public: The name of the engine the component is mounted to.
    def mounted_engine
      "decidim_#{participatory_space_name}_#{manifest_name}"
    end

    # Public: The name of the admin engine the component is mounted to.
    def mounted_admin_engine
      "decidim_admin_#{participatory_space_name}_#{manifest_name}"
    end

    # Public: The hash of contextual params when the component is mounted.
    def mounted_params
      {
        :host => organization.host,
        :component_id => id,
        :locale => I18n.locale,
        :"#{participatory_space.underscored_name}_slug" => participatory_space.slug
      }
    end

    # Public: The Form Class for this component.
    #
    # Returns a ComponentForm.
    def form_class
      manifest.component_form_class
    end

    # Public: Returns the value of the registered primary stat.
    def primary_stat
      @primary_stat ||= begin
        data = manifest.stats.filter(primary: true).with_context([self]).map { |name, value| [name, value] }.first&.first&.[](:data)
        data.respond_to?(:first) ? data.first : data
      end
    end

    # Public: Returns the component's name as resource title
    def resource_title
      name
    end

    def hierarchy_title
      [
        I18n.t("decidim.admin.menu.#{participatory_space.class.name.demodulize.underscore.pluralize}"),
        translated_attribute(participatory_space.title),
        translated_attribute(name)
      ].join(" / ")
    end

    # Public: Returns an empty description
    def resource_description; end

    def can_participate_in_space?(user)
      return true unless participatory_space.try(:private_space?)
      return false unless user

      participatory_space.can_participate?(user)
    end

    def private_non_transparent_space?
      return false unless participatory_space.respond_to?(:private_space?)
      return false unless participatory_space.private_space?

      if participatory_space.respond_to?(:is_transparent?)
        !participatory_space.is_transparent?
      else
        true
      end
    end

    # Public: Public URL for component with given share token as query parameter
    def shareable_url(share_token)
      EngineRouter.main_proxy(self).root_url(self, share_token: share_token.token)
    end

    delegate :serializes_specific_data?, to: :manifest

    private

    def participatory_space_name
      participatory_space.underscored_name
    end
  end
end
