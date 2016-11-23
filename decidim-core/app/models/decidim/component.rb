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

    validates :participatory_process, :step, presence: true

    # Public: Returns the manifest this particular component is associated to.
    #
    # Returns a class that inherits from Decidim::Components::ComponentManifest.
    def manifest
      @manifest ||= Decidim.components.find do |manifest|
        manifest.name == component_type.to_sym
      end
    end
  end
end
