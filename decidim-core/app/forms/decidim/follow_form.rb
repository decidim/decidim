# frozen_string_literal: true

module Decidim
  # A form object to be used when users want to follow a followable resource.
  class FollowForm < Decidim::Form
    mimic :follow

    attribute :followable_gid, String

    validates :followable_gid, :followable, presence: true
    validates :followable, exclusion: { in: ->(form) { [form.current_user] } }

    def followable
      @followable ||= GlobalID::Locator.locate_signed followable_gid
    end

    def follow
      @follow ||= Decidim::Follow.find_by(user: current_user, followable:)
    end
  end
end
