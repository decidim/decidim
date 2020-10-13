# frozen_string_literal: true

module Decidim
  # Assembly type.
  class AssembliesType < ApplicationRecord
    include Decidim::Traceable
    include Decidim::Loggable
    include Decidim::TranslatableResource

    translatable_fields :title

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization"

    has_many :assemblies,
             foreign_key: "decidim_assemblies_type_id",
             class_name: "Decidim::Assembly",
             dependent: :nullify

    validates :title, presence: true

    def self.log_presenter_class_for(_log)
      Decidim::Assemblies::AdminLog::AssembliesTypePresenter
    end
  end
end
