# frozen_string_literal: true

require "devise/models/decidim_validatable"
require "valid_email2"

module Decidim
  # A UserGroup is an organization of participants
  class UserGroup < UserBaseEntity
    include Decidim::Traceable
    include Decidim::DownloadYourData
    include Decidim::ActsAsAuthor
    include Decidim::UserReportable
    include Decidim::Searchable

    has_many :memberships, class_name: "Decidim::UserGroupMembership", foreign_key: :decidim_user_group_id, dependent: :destroy
    has_many :users, through: :memberships, class_name: "Decidim::User", foreign_key: :decidim_user_id
    has_many :managers,
             -> { where(decidim_user_group_memberships: { role: [:creator, :admin] }) },
             through: :memberships,
             class_name: "Decidim::User",
             foreign_key: :decidim_user_id,
             source: :user

    validates :name, presence: true, uniqueness: { scope: :decidim_organization_id }

    validate :correct_state
    validate :unique_document_number, if: :has_document_number?

    devise :confirmable, :decidim_validatable, confirmation_keys: [:decidim_organization_id, :email]

    scope :verified, -> { where.not("extended_data->>'verified_at' IS ?", nil) }
    scope :not_verified, -> { where("extended_data->>'verified_at' IS ?", nil) }
    scope :rejected, -> { where.not("extended_data->>'rejected_at' IS ?", nil) }
    scope :pending, -> { where("extended_data->>'rejected_at' IS ? AND extended_data->>'verified_at' IS ?", nil, nil) }

    searchable_fields(
      {
        organization_id: :decidim_organization_id,
        A: :name,
        datetime: :created_at
      },
      index_on_create: ->(user_group) { !user_group.deleted? },
      index_on_update: ->(user_group) { !user_group.deleted? }
    )

    def self.with_document_number(organization, number)
      where(decidim_organization_id: organization.id)
        .where("extended_data->>'document_number' = ?", number)
    end

    def non_deleted_memberships
      memberships.where(decidim_users: { deleted_at: nil })
    end

    # Returns the presenter for this author, to be used in the views.
    # Required by ActsAsAuthor.
    def presenter
      Decidim::UserGroupPresenter.new(self)
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

    # Check if the group has been deleted or not
    def deleted?
      deleted_at.present?
    end

    def self.user_collection(user)
      user.user_groups
    end

    def self.export_serializer
      Decidim::DownloadYourDataSerializers::DownloadYourDataUserGroupSerializer
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
      extended_data["verified_at"] = nil
      extended_data["rejected_at"] = Time.current
      save!
    end

    def verify!
      extended_data["verified_at"] = Time.current
      extended_data["rejected_at"] = nil
      save!
    end

    # sugar for the memberships query
    def accepted_memberships
      UserGroups::AcceptedMemberships.for(self)
    end

    # easy way to return all the users accepted in this group
    def accepted_users
      accepted_memberships.map(&:user)
    end

    # Currently, groups always accept conversations from anyone.
    # This may change in the future in case the desired behaviour
    # is to check if all (or any) of the administrators accepts conversations
    # or there's simply and option for this in the group preferences.
    def accepts_conversation?(_user)
      true
    end

    def unread_messages_count_for(user)
      @unread_messages_count_for ||= {}
      @unread_messages_count_for[user.id] ||= Decidim::Messaging::Conversation.user_collection(self).unread_messages_by(user).count
    end

    def self.state_eq(value)
      send(value.to_sym) if %w(all pending rejected verified).include?(value)
    end

    def self.ransackable_scopes(_auth = nil)
      [:state_eq]
    end

    scope :sort_by_users_count_asc, lambda {
      order("users_count ASC NULLS FIRST")
    }

    scope :sort_by_users_count_desc, lambda {
      order("users_count DESC NULLS LAST")
    }

    def self.sort_by_document_number_asc
      order(Arel.sql("extended_data->>'document_number' ASC"))
    end

    def self.sort_by_document_number_desc
      order(Arel.sql("extended_data->>'document_number' DESC"))
    end

    def self.sort_by_phone_asc
      order(Arel.sql("extended_data->>'phone' ASC"))
    end

    def self.sort_by_phone_desc
      order(Arel.sql("extended_data->>'phone' DESC"))
    end

    def self.sort_by_state_asc
      order(Arel.sql("extended_data->>'rejected_at' ASC, extended_data->>'verified_at' ASC, deleted_at ASC"))
    end

    def self.sort_by_state_desc
      order(Arel.sql("extended_data->>'rejected_at' DESC, extended_data->>'verified_at' DESC, deleted_at DESC"))
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
                    .where.not(id:)
                    .any?

      errors.add(:document_number, :taken) if is_repeated
    end

    def has_document_number?
      document_number.present?
    end

    # Overwites method in `Decidim::Validatable`, as user groups don't have a
    # password.
    def password_required?
      false
    end

    # Overwites method in `Decidim::Validatable`, as user groups don't have a
    # password.
    def password
      nil
    end
  end
end
