# frozen_string_literal: true
module Decidim
  class Feature < ApplicationRecord
    belongs_to :participatory_process, foreign_key: "decidim_participatory_process_id"
    has_many :components, foreign_key: "decidim_feature_id"

    validates :participatory_process, presence: true

    def manifest
      @manifest ||= Decidim.features.find do |manifest|
        manifest.name == feature_type.to_sym
      end
    end
  end
end
