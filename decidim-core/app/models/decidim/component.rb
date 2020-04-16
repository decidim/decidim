# frozen_string_literal: true

module Decidim
  # A Component represents a self-contained group of functionalities usually
  # defined via a ComponentManifest. It's meant to be able to provide a single
  # component that spans over several steps.
  class Component < ApplicationRecord
    include HasSettings
    include Publicable
    include Traceable
    include Loggable
    include Scopable

    has_many :children, foreign_key: "parent_id", class_name: "Decidim::Component", inverse_of: :parent, dependent: :destroy
    belongs_to :parent, foreign_key: "parent_id", class_name: "Decidim::Component", inverse_of: :children, optional: true
    delegate :allow_parent?, :allow_children?, to: :manifest

    scope :top_level, -> { where parent: nil }

    belongs_to :participatory_space, polymorphic: true

    default_scope { order(arel_table[:weight].asc, arel_table[:manifest_name].asc) }

    delegate :organization, :categories, to: :participatory_space

    def self.log_presenter_class_for(_log)
      Decidim::AdminLog::ComponentPresenter
    end

    # Other components with the same manifest and same participatory space as this one.
    def siblings
      @siblings ||= participatory_space.components.where.not(id: id).where(manifest_name: manifest_name)
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
        host: organization.host,
        component_id: id,
        "#{participatory_space.underscored_name}_slug".to_sym => participatory_space.slug
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
      @primary_stat ||= manifest.stats.filter(primary: true).with_context([self]).map { |name, value| [name, value] }.first&.last
    end

    # Public: Returns the component's name as resource title
    def resource_title
      name
    end

    # Public: Returns an empty description
    def resource_description; end

    def can_participate_in_space?(user)
      return true unless participatory_space.try(:private_space?)
      return false unless user

      participatory_space.can_participate?(user)
    end

    # Public: Returns the component Scope
    # overrides the method from Scopable
    def scope
      return participatory_space.scope unless scopes_enabled

      participatory_space.scopes.find_by(id: settings.scope_id)
    end

    # overrides the method from Scopable
    #
    # Returns a boolean.
    def scopes_enabled
      settings.try(:scopes_enabled)
    end

    # Whether the component or participatory_space has subscopes or not.
    #
    # Returns a boolean.
    def has_subscopes?
      scopes_enabled || participatory_space.scopes_enabled && subscopes.any?
    end

    delegate :serializes_specific_data?, to: :manifest

    private

    def participatory_space_name
      participatory_space.underscored_name
    end
  end
end
