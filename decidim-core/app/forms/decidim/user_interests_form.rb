# frozen_string_literal: true

module Decidim
  # The form object that handles the data behind updating a user's
  # interests in their profile page.
  class UserInterestsForm < Form
    mimic :user

    attribute :scopes, Array[UserInterestScopeForm]

    def map_model(user)
      self.scopes = user.organization.scopes.top_level.map do |scope|
        UserInterestScopeForm.from_model(scope:, user:)
      end
    end
  end
end
