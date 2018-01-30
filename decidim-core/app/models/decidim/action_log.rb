# frozen_string_literal: true

module Decidim
  # This class represents an action of a user on a resource. It is used
  # for transparency reasons, to log all actions so all other users can
  # see the actions being performed.
  class ActionLog < ApplicationRecord
    belongs_to :organization,
               foreign_key: :decidim_organization_id,
               class_name: "Decidim::Organization"

    belongs_to :user,
               foreign_key: :decidim_user_id,
               class_name: "Decidim::User"

    belongs_to :feature,
               foreign_key: :decidim_feature_id,
               optional: true,
               class_name: "Decidim::Feature"

    belongs_to :resource,
               polymorphic: true

    belongs_to :participatory_space,
               optional: true,
               polymorphic: true

    validates :organization, :user, :action, :resource, presence: true
  end
end
