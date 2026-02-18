# frozen_string_literal: true

module Decidim
  class ResourceLikedEvent < Decidim::Events::SimpleEvent
    i18n_attributes :liker_nickname, :liker_name, :liker_path, :nickname, :resource_type

    delegate :nickname, :name, to: :liker, prefix: true

    def nickname
      liker_nickname
    end

    def liker_path
      liker.profile_path
    end

    def resource_text
      return resource.body if resource.respond_to? :body
      return resource.description if resource.respond_to? :description
    end

    def resource_type
      resource.class.model_name.human
    end

    private

    def liker
      @liker ||= Decidim::UserPresenter.new(liker_user)
    end

    def liker_user
      @liker_user ||= Decidim::User.find_by(id: extra[:liker_id])
    end
  end
end
