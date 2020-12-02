# frozen_string_literal: true

module Decidim
  class ParticipatoryProcessGroup < ApplicationRecord
    include Decidim::Resourceable
    include Decidim::Traceable
    include Decidim::HasUploadValidations
    include Decidim::TranslatableResource

    translatable_fields :title, :description, :developer_group, :local_area, :meta_scope, :participatory_scope,
                        :participatory_structure, :target

    has_many :participatory_processes,
             foreign_key: "decidim_participatory_process_group_id",
             class_name: "Decidim::ParticipatoryProcess",
             inverse_of: :participatory_process_group,
             dependent: :nullify

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization"

    validates_upload :hero_image
    mount_uploader :hero_image, Decidim::HeroImageUploader

    def self.log_presenter_class_for(_log)
      Decidim::ParticipatoryProcesses::AdminLog::ParticipatoryProcessGroupPresenter
    end
  end
end
