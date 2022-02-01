# frozen_string_literal: true

module Decidim
  class NotificationsSubscription < ApplicationRecord
    belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"
  end
end
