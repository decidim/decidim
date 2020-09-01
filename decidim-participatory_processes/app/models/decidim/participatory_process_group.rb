# frozen_string_literal: true

module Decidim
  class ParticipatoryProcessGroup < ApplicationRecord
    include Decidim::Resourceable
    include Decidim::Traceable
    include Decidim::TranslatableResource

    translatable_fields :name, :description

    has_many :participatory_processes,
             foreign_key: "decidim_participatory_process_group_id",
             class_name: "Decidim::ParticipatoryProcess",
             inverse_of: :participatory_process_group,
             dependent: :nullify

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization"

    mount_uploader :hero_image, Decidim::HeroImageUploader

    def self.log_presenter_class_for(_log)
      Decidim::ParticipatoryProcesses::AdminLog::ParticipatoryProcessGroupPresenter
    end
  end
end
