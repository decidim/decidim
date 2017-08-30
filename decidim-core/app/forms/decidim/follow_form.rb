# frozen_string_literal: true

module Decidim
  # A form object to be used when users want to follow a followable resource.
  class FollowForm < Decidim::Form
    mimic :follow

    attribute :followable_gid, String

    validates :followable_gid, :followable, presence: true

    def followable
      @followable ||= GlobalID::Locator.locate_signed followable_gid
    end

    def follow
      @follow ||= Decidim::Follow.where(user: current_user, followable: followable).first
    end
  end
end
