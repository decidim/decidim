# frozen_string_literal: true

module Decidim
  class UserBlock < ApplicationRecord
    MINIMUM_JUSTIFICATION_LENGTH = 15

    # `user` has no `inverse_of`: the reciprocal `has_one :blocking` on `Decidim::UserBaseEntity` is keyed on
    # `decidim_user_blocks.id` through `decidim_users.block_id`, not on the `decidim_user_id` column used here,
    # so the two are not the same join. Declaring the inverse would make the block the in-memory target of that
    # association and autosave would propagate `block_id` onto this record's primary key, so a user unblocked in
    # the admin (`block_id = nil`) would be saved as an insert with a NULL `decidim_user_blocks.id`.
    belongs_to :user, class_name: "Decidim::UserBaseEntity", foreign_key: :decidim_user_id
    # `blocking_user` has no `inverse_of` either: the reciprocal `has_one :blocking` on `Decidim::UserBaseEntity`
    # is the block record of the blocked user, so it is the reciprocal of `user` and not of `blocking_user`.
    belongs_to :blocking_user, class_name: "Decidim::UserBaseEntity"
  end
end
