# frozen_string_literal: true
module Decidim
  class ParticipatoryProcessUserRole < ApplicationRecord
    belongs_to :user, foreign_key: "decidim_user_id", class_name: Decidim::User
    belongs_to :participatory_process, foreign_key: "decidim_participatory_process_id", class_name: Decidim::ParticipatoryProcess

    ROLES = %w(admin).freeze
    validates :role, inclusion: { in: ROLES }
  end
end
