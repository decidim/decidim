module Decidim
  class ParticipatoryProcessGroup < ApplicationRecord
    has_many :participatory_processes,
              foreign_key: "decidim_participatory_process_group_id",
              class_name: Decidim::ParticipatoryProcess,
              inverse_of: :participatory_process_group
    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: Decidim::Organization,
               inverse_of: :participatory_process_groups

    mount_uploader :hero_image, Decidim::HeroImageUploader
  end
end
