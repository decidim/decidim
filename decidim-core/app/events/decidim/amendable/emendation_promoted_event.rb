# frozen-string_literal: true

module Decidim::Amendable
  class EmendationPromotedEvent < Decidim::Amendable::AmendmentBaseEvent
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
