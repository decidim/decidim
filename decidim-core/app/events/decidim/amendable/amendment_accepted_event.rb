# frozen-string_literal: true

module Decidim::Amendable
  class AmendmentAcceptedEvent < Decidim::Amendable::AmendmentBaseEvent
    i18n_attributes :amendable_path, :amendable_type, :amendable_title, :emendation_path, :emendation_author_nickname, :emendation_author_path

    def amendable_resource
      @amendable_resource ||= resource.amendable
    end

    def emendation_resource
      @emendation_resource ||= resource
    end

    def event_has_roles?
      true
    end
  end
end
