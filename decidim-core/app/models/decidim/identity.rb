# frozen_string_literal: true

module Decidim
  class Identity < ApplicationRecord
    belongs_to :user, foreign_key: :decidim_user_id, class_name: Decidim::User

    validates :provider, presence: true
    validates :uid, presence: true, uniqueness: { scope: :provider }
  end
end
