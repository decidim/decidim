# frozen_string_literal: true

module Decidim
  class ParticipatoryProcessGroup < ApplicationRecord
    include Decidim::Resourceable

    has_many :participatory_processes,
             foreign_key: "decidim_participatory_process_group_id",
             class_name: "Decidim::ParticipatoryProcess",
             inverse_of: :participatory_process_group,
             dependent: :nullify

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization"

    mount_uploader :hero_image, Decidim::HeroImageUploader
  end
end
