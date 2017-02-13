module Decidim
  class Newsletter < ApplicationRecord
    belongs_to :author, class_name: User
    belongs_to :organization

    def delivered?
      delivered_at.present?
    end
  end
end
