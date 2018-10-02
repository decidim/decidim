# frozen_string_literal: true

module Decidim
  # A UserGroup is an organization of citizens
  class UserGroup < UserBaseEntity
    include Decidim::Traceable
    include Decidim::DataPortability

    has_many :memberships, class_name: "Decidim::UserGroupMembership", foreign_key: :decidim_user_group_id, dependent: :destroy
    has_many :users, through: :memberships, class_name: "Decidim::User", foreign_key: :decidim_user_id

    validates :name, presence: true, uniqueness: { scope: :decidim_organization_id }
    validates :document_number, presence: true
    validates :phone, presence: true

    validate :correct_state
    validate :unique_document_number

    scope :verified, -> { where.not("extended_data->>'verified_at' IS ?", nil) }
    scope :rejected, -> { where.not("extended_data->>'rejected_at' IS ?", nil) }
    scope :pending, -> { where("extended_data->>'rejected_at' IS ? AND extended_data->>'verified_at' IS ?", nil, nil) }

    def self.with_document_number(organization, number)
      where(decidim_organization_id: organization.id)
        .where("extended_data->>'document_number' = ?", number)
    end

    def self.log_presenter_class_for(_log)
      Decidim::AdminLog::UserGroupPresenter
    end

    # Public: Checks if the user group is verified.
    def verified?
      verified_at.present?
    end

    # Public: Checks if the user group is rejected.
    def rejected?
      rejected_at.present?
    end

    # Public: Checks if the user group is pending.
    def pending?
      verified_at.blank? && rejected_at.blank?
    end

    def self.user_collection(user)
      user.user_groups
    end

    def self.export_serializer
      Decidim::DataPortabilitySerializers::DataPortabilityUserGroupSerializer
    end

    def document_number
      extended_data["document_number"]
    end

    def phone
      extended_data["phone"]
    end

    def rejected_at
      extended_data["rejected_at"]
    end

    def verified_at
      extended_data["verified_at"]
    end

    def reject!
      self.extended_data["verified_at"] = nil
      self.extended_data["rejected_at"] = Time.current
      save!
    end

    def verify!
      self.extended_data["verified_at"] = Time.current
      self.extended_data["rejected_at"] = nil
      save!
    end

    private

    # Private: Checks if the state user group is correct.
    def correct_state
      errors.add(:base, :invalid) if verified? && rejected?
    end

    def unique_document_number
      is_repeated = self
                    .class
                    .with_document_number(organization, document_number)
                    .where.not(id: id)
                    .any?

      errors.add(:document_number, :taken) if is_repeated
    end
  end
end
