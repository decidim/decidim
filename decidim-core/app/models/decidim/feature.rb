# frozen_string_literal: true
module Decidim
  # A Feature represents a self-contained group of functionalities usually
  # defined via a FeatureManifest and its Components. It's meant to be able to
  # provide a single feature that spans over several steps, each one with its component.
  class Feature < ApplicationRecord
    belongs_to :participatory_process, foreign_key: "decidim_participatory_process_id"
    has_many :components, foreign_key: "decidim_feature_id"

    validates :participatory_process, presence: true

    def manifest
      Decidim.find_feature_manifest(feature_type)
    end
  end
end
