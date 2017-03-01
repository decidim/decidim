module Decidim
  class ParticipatoryProcessGroup < ApplicationRecord
    has_many :participatory_processes
    belongs_to :organization

    mount_uploader :hero_image, Decidim::HeroImageUploader
  end
end
