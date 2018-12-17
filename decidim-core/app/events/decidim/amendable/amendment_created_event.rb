# frozen-string_literal: true

module Decidim::Amendable
  class AmendmentCreatedEvent < Decidim::Amendable::AmendmentBaseEvent
    i18n_attributes :amendable_path, :amendable_type, :amendable_title, :emendation_path, :emendation_author_nickname, :emendation_author_path

    def amendment_resource
      @amendment_resource ||= Decidim::Amendment.find extra[:amendment_id]
    end

    def amendable_resource
      resource
    end

    def emendation_resource
      @emendation_resource ||= amendment_resource.emendation
    end

    def event_has_roles?
      true
    end
  end
end
