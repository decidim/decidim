# frozen_string_literal: true

module Decidim
  class UserBlock < ApplicationRecord
    MINIMUM_JUSTIFICATION_LENGTH = 10

    belongs_to :user, class_name: "Decidim::User", foreign_key: :decidim_user_id
    belongs_to :blocking_user, class_name: "Decidim::User", foriegn_key: :blocking_user_id
  end
end
