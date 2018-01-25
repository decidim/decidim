# frozen-string_literal: true

module Decidim
  class ProfileUpdatedEvent < Decidim::Events::ExtendedEvent
    i18n_attributes :nickname, :name

    delegate :profile_path, :profile_url, :nickname, :name, to: :updated_user

    private

    def resource_path
      profile_path
    end

    def resource_title
      name
    end

    def resource_url
      profile_url
    end

    def updated_user
      @updated_user ||= Decidim::UserPresenter.new(resource)
    end
  end
end
