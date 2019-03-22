# frozen-string_literal: true

module Decidim::Amendable
  class AmendmentCreatedEvent < Decidim::Amendable::AmendmentBaseEvent
    i18n_attributes :amendable_path, :amendable_type, :amendable_title

    def amendable_resource
      @amendable_resource ||= resource
    end

    def emendation_resource
      nil
    end

    def event_has_roles?
      true
    end
  end
end
