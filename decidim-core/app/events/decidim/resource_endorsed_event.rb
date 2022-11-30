# frozen-string_literal: true

module Decidim
  class ResourceEndorsedEvent < Decidim::Events::SimpleEvent
    i18n_attributes :endorser_nickname, :endorser_name, :endorser_path, :nickname, :resource_type

    delegate :nickname, :name, to: :endorser, prefix: true

    def nickname
      endorser_nickname
    end

    def endorser_path
      endorser.profile_path
    end

    def resource_text
      return resource.body if resource.respond_to? :body
      return resource.description if resource.respond_to? :description
    end

    def resource_type
      resource.class.model_name.human
    end

    private

    def endorser
      @endorser ||= Decidim::UserPresenter.new(endorser_user)
    end

    def endorser_user
      @endorser_user ||= Decidim::User.find_by(id: extra[:endorser_id])
    end
  end
end
