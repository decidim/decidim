# frozen_string_literal: true

module Decidim
  class ParticipatoryProcessType < ApplicationRecord
    include Decidim::Traceable
    include Decidim::Loggable
    include Decidim::TranslatableResource

    translatable_fields :title

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization"

    has_many :processes,
             foreign_key: "decidim_participatory_process_type_id",
             class_name: "Decidim::ParticipatoryProcess",
             inverse_of: :participatory_process_type,
             dependent: :nullify

    validates :title, presence: true

    def self.log_presenter_class_for(_log)
      Decidim::ParticipatoryProcesses::AdminLog::ParticipatoryProcessTypePresenter
    end
  end
end
