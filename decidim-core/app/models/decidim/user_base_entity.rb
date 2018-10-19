# frozen_string_literal: true

module Decidim
  # This class serves as a base class for `Decidim::User` and `Decidim::UserGroup`
  # so that we can set some shared logic.
  # This class is not supposed to be used directly.
  class UserBaseEntity < ApplicationRecord
    self.table_name = "decidim_users"

    include Nicknamizable
    include Resourceable
    include Decidim::Followable
    include Decidim::Loggable

    belongs_to :organization, foreign_key: "decidim_organization_id", class_name: "Decidim::Organization"
    has_many :notifications, foreign_key: "decidim_user_id", class_name: "Decidim::Notification", dependent: :destroy
    has_many :following_follows, foreign_key: "decidim_user_id", class_name: "Decidim::Follow", dependent: :destroy

    validates :avatar, file_size: { less_than_or_equal_to: ->(_record) { Decidim.maximum_avatar_size } }
    mount_uploader :avatar, Decidim::AvatarUploader

    # Public: Returns a collection with all the entities this user is following.
    #
    # This can't be done as with a `has_many :following, through: :following_follows`
    # since it's a polymorphic relation and Rails doesn't know how to load it. With
    # this implementation we only query the database once for each kind of following.
    #
    # Returns an Array of Decidim::Followable
    def following
      @following ||= begin
                       followings = following_follows.pluck(:decidim_followable_type, :decidim_followable_id)
                       grouped_followings = followings.each_with_object({}) do |(type, following_id), all|
                         all[type] ||= []
                         all[type] << following_id
                         all
                       end

                       grouped_followings.flat_map do |type, ids|
                         type.constantize.where(id: ids)
                       end
                     end
    end

    def following_users
      @following_users ||= following.select do |f|
        f.is_a?(Decidim::User) || f.is_a?(Decidim::UserGroup)
      end
    end
  end
end
