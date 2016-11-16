# frozen_string_literal: true
module Decidim
  class Component < ApplicationRecord
    belongs_to :participatory_process, foreign_key: "decidim_participatory_process_id"

    validates :participatory_process, presence: true

    def manifest
      Decidim.components.find do |manifest|
        manifest.config[:name] == component_type.to_sym
      end
    end
  end
end
