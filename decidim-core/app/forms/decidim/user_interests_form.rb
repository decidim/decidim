# frozen_string_literal: true

module Decidim
  # The form object that handles the data behind updating a user's
  # interests in her profile page.
  class UserInterestsForm < Form
    mimic :user

    attribute :scopes, Array[UserInterestScopeForm]
    attribute :areas, Array[UserInterestAreaForm]

    def newsletter_notifications_at
      return nil unless newsletter_notifications
      Time.current
    end

    def map_model(user)
      self.areas = user.organization.areas.map do |area|
        UserInterestAreaForm.from_model(area: area, user: user)
      end
      self.scopes = user.organization.scopes.top_level.map do |scope|
        UserInterestScopeForm.from_model(scope: scope, user: user)
      end
    end
  end
end
