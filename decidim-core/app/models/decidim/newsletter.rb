# frozen_string_literal: true

module Decidim
  # This model holds all the data needed to send a newsletter.
  class Newsletter < ApplicationRecord
    include Decidim::Traceable
    include Decidim::Loggable
    include Decidim::TranslatableResource

    translatable_fields :subject

    belongs_to :author, class_name: "User"
    belongs_to :organization

    validates :subject, presence: true
    validate :author_belongs_to_organization

    def self.log_presenter_class_for(_log)
      Decidim::AdminLog::NewsletterPresenter
    end

    # Returns true if this newsletter was already sent.
    #
    # Returns a Boolean.
    def sent?
      sent_at.present?
    end

    def sent_scopes_ids
      extended_data["scope_ids"] || []
    end

    def sent_scopes
      @sent_scopes ||= organization.scopes.where(id: sent_scopes_ids)
    end

    def sended_to_all_users?
      extended_data["send_to_all_users"]
    end

    def sended_to_followers?
      extended_data["send_to_followers"]
    end

    def sended_to_participants?
      extended_data["send_to_participants"]
    end

    def sended_to_partipatory_spaces
      extended_data["participatory_space_types"]
    end

    def template
      @template ||= Decidim::ContentBlock
                    .for_scope(:newsletter_template, organization:)
                    .find_by(scoped_resource_id: id)
    end

    private

    def author_belongs_to_organization
      return if !author || !organization

      errors.add(:author, :invalid) unless author.organization == organization
    end
  end
end
