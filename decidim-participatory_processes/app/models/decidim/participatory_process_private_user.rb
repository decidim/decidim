# frozen_string_literal: true

module Decidim
  # This class gives a given User access to a given private Process
  class ParticipatoryProcessPrivateUser < ApplicationRecord
    belongs_to :user, class_name: "Decidim::User", foreign_key: :decidim_user_id, optional: true
    belongs_to :participatory_process, class_name: "Decidim::ParticipatoryProcess", foreign_key: :decidim_participatory_process_id, optional: true

    validate :user_and_participatory_process_same_organization

    private

    # Private: check if the process and the user have the same organization
    def user_and_participatory_process_same_organization
      return if !participatory_process || !user
      errors.add(:participatory_process, :invalid) unless user.organization == participatory_process.organization
    end
  end
end
