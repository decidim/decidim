# frozen_string_literal: true
module Decidim
  # A Component represents the association between a participatory process and a
  # Component Engine. It configures how that component should behave, its name,
  # and other relevant fields.
  class Component < ApplicationRecord
    belongs_to :feature, foreign_key: "decidim_feature_id"

    belongs_to :step,
               foreign_key: "decidim_participatory_process_step_id",
               class_name: "Decidim::ParticipatoryProcessStep"

    has_one :participatory_process, through: :feature

    validates :feature, :step, :manifest, presence: true

    validate :manifest_belongs_to_feature
    validate :participatory_process_is_valid

    # Public: Fins the manifest this particular component is associated to.
    #
    # Returns a ComponentManifest.
    def manifest
      Decidim.find_component_manifest(component_type)
    end

    # Public: Assigns a manifest to this component.
    #
    # manifest - The ComponentManifest for this Component.
    #
    # Returns nothing.
    def manifest=(manifest)
      self.component_type = manifest.name
    end

    private

    def manifest_belongs_to_feature
      return if feature&.manifest&.component_manifests&.include?(manifest)

      errors.add(:manifest, I18n.t("errors.messages.invalid_manifest"))
    end

    def participatory_process_is_valid
      return if !step&.participatory_process || !feature&.participatory_process
      return if feature.participatory_process == step.participatory_process

      errors.add(:manifest, I18n.t("errors.messages.invalid_participatory_process"))
    end
  end
end
