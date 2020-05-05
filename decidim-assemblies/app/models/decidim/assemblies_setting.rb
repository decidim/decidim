# frozen_string_literal: true

module Decidim
  # Assemblies setting.
  class AssembliesSetting < ApplicationRecord
    include Decidim::Traceable
    include Decidim::Loggable

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization"

    def self.log_presenter_class_for(_log)
      Decidim::Assemblies::AdminLog::AssembliesSettingPresenter
    end
  end
end
