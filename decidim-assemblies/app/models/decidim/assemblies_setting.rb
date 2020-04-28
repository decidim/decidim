# frozen_string_literal: true

module Decidim
  # Assembly type.
  class AssembliesSetting < ApplicationRecord
    include Decidim::Traceable
    include Decidim::Loggable

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization"

  end
end
