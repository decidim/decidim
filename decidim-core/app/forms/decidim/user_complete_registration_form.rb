# frozen_string_literal: true

module Decidim
  # The form object that handles the data behind updating a user's
  # profile in the signup process
  class UserCompleteRegistrationForm < Form
    mimic :user

    attribute :avatar
    attribute :remove_avatar
    attribute :personal_url
    attribute :about
    attribute :scopes, Array[UserInterestScopeForm]

    validates :avatar, file_size: { less_than_or_equal_to: ->(_record) { Decidim.maximum_avatar_size } }

    validate :personal_url_format

    def personal_url
      return if super.blank?

      return "http://" + super unless super.match?(%r{\A(http|https)://}i)

      super
    end

    def map_model(user)
      self.scopes = user.organization.scopes.top_level.map do |scope|
        UserInterestScopeForm.from_model(scope: scope, user: user)
      end
    end

    private

    def personal_url_format
      return if personal_url.blank?

      uri = URI.parse(personal_url)
      errors.add :personal_url, :invalid if !uri.is_a?(URI::HTTP) || uri.host.nil?
    rescue URI::InvalidURIError
      errors.add :personal_url, :invalid
    end
  end
end
