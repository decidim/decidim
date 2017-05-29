# frozen_string_literal: true

module Decidim
  # This model holds all the data needed to send a newsletter.
  class Newsletter < ApplicationRecord
    belongs_to :author, class_name: "User"
    belongs_to :organization

    validates :subject, :body, presence: true
    validate :author_belongs_to_organization

    # Returns true if this newsletter was already sent.
    #
    # Returns a Boolean.
    def sent?
      sent_at.present?
    end

    private

    def author_belongs_to_organization
      return if !author || !organization
      errors.add(:author, :invalid) unless author.organization == organization
    end
  end
end
