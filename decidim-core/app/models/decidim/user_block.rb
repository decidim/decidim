# frozen_string_literal: true

module Decidim
  class UserBlock < ApplicationRecord
    MINIMUM_JUSTIFICATION_LENGTH = 15

    belongs_to :user, class_name: "Decidim::UserBaseEntity", foreign_key: :decidim_user_id, inverse_of: :blocking
    # `blocking_user` has no `inverse_of`: the reciprocal `has_one :blocking` on `Decidim::UserBaseEntity` is
    # the block record of the blocked user, so it is the reciprocal of `user` and not of `blocking_user`.
    belongs_to :blocking_user, class_name: "Decidim::UserBaseEntity"
  end
end
