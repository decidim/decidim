# frozen_string_literal: true

module Decidim
  # It represents a member of the assembly (president, secretary, ...)
  # Can be linked to an existent user in the platform
  class AssemblyMember < ApplicationRecord
    include Decidim::Traceable
    include Decidim::Loggable
    include Decidim::HasUploadValidations

    POSITIONS = %w(president vice_president secretary other).freeze

    belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::UserBaseEntity", optional: true
    belongs_to :assembly, foreign_key: "decidim_assembly_id", class_name: "Decidim::Assembly"
    alias participatory_space assembly

    has_one_attached :non_user_avatar
    validates_avatar :non_user_avatar, uploader: Decidim::AvatarUploader

    delegate :organization, to: :assembly

    default_scope { order(weight: :asc, created_at: :asc) }

    scope :not_ceased, -> { where("ceased_date >= ? OR ceased_date IS NULL", Time.zone.today) }

    def self.log_presenter_class_for(_log)
      Decidim::Assemblies::AdminLog::AssemblyMemberPresenter
    end

    def remove_non_user_avatar
      false
    end
  end
end
