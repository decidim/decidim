# frozen-string_literal: true

module Decidim::Amendable
  class AmendmentCreatedEvent < Decidim::Amendable::AmendmentBaseEvent
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
