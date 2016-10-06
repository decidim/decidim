# frozen_string_literal: true
module Decidim
  # Interaction between a user and an organization is done via a
  # ParticipatoryProcess. It's a unit of action from the Organization point of
  # view that groups several features (proposals, debates...) distributed in
  # steps that get enabled or disabled depending on which step is currently
  # active.
  class ParticipatoryProcess < ApplicationRecord
    belongs_to :organization, foreign_key: "decidim_organization_id", class_name: Decidim::Organization

    validates :title, :slug, :subtitle, :short_description, :description, presence: true
    validates :slug, uniqueness: true
  end
end
