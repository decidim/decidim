# frozen_string_literal: true

module Decidim
  class UserBlock < ApplicationRecord
    MINIMUM_JUSTIFICATION_LENGTH = 15

    belongs_to :user, -> { entire_collection }, class_name: "Decidim::UserBaseEntity", foreign_key: :decidim_user_id
    belongs_to :blocking_user, class_name: "Decidim::UserBaseEntity"
  end
end
