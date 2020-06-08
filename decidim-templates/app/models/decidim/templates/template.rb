# frozen_string_literal: true

module Decidim
  module Templates
    class Template < ApplicationRecord
      belongs_to :organization,
                 foreign_key: "decidim_organization_id",
                 class_name: "Decidim::Organization"

      belongs_to :templatable, foreign_key: "templatable_id", foreign_type: "templatable_type", polymorphic: true
    end
  end
end
