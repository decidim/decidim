# frozen_string_literal: true

module Decidim
  class ParticipatoryProcessGroup < ApplicationRecord
    include Decidim::Resourceable
    include Decidim::Searchable
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

    has_one_attached :hero_image
    validates_upload :hero_image, uploader: Decidim::HeroImageUploader

    searchable_fields({
                        participatory_space: :itself,
                        A: :title,
                        B: :description
                      },
                      index_on_create: ->(_process) { true },
                      index_on_update: ->(_process) { true })

    # Scope to return only the promoted groups.
    #
    # Returns an ActiveRecord::Relation.
    def self.promoted
      where(promoted: true)
    end

    def self.log_presenter_class_for(_log)
      Decidim::ParticipatoryProcesses::AdminLog::ParticipatoryProcessGroupPresenter
    end

    def self.participatory_spaces(group_id)
      find(group_id).participatory_processes
    end
  end
end
