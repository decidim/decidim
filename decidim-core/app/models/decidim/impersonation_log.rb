# frozen_string_literal: true

module Decidim
  # TODO
  class ImpersonationLog < ApplicationRecord
    belongs_to :admin, foreign_key: "decidim_admin_id", class_name: "Decidim::User"
    belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"

    # TODO
    def expired?
      false
    end
  end
end
