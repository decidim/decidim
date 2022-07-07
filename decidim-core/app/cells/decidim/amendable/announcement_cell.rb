# frozen_string_literal: true

module Decidim::Amendable
  # This cell renders the callout with information about the state of the emendation
  class AnnouncementCell < Decidim::ViewModel
    include Decidim::ApplicationHelper

    def show
      cell "decidim/announcement", announcement, callout_class: state_classes
    end

    private

    def announcement
      emendation_message + promoted_message
    end

    def emendation_message
      message(model.state, amendable_type, proposal_link, announcement_date)
    end

    def promoted_message
      return "" unless model.amendment.promoted?

      proposal = model.linked_promoted_resource
      text = message(:promoted, amendable_type)
      %(<br><strong>#{proposal_link(proposal, text)}</strong>)
    end

    def message(state, type, link = nil, date = nil)
      t(state,
        scope: "decidim.amendments.emendation.announcement",
        amendable_type: type,
        proposal_link: link,
        date: date)
    end

    def proposal_link(resource = model.amendable, text = nil)
      text ||= %(<strong>#{present(model.amendable).title}</strong>)
      link_to resource_locator(resource).path do
        text
      end
    end

    def amendable_type
      @amendable_type ||= t(model.class.model_name.i18n_key, scope: "activerecord.models", count: 1).downcase
    end

    def announcement_date
      model.amendment.updated_at
    end

    def state_classes
      case model.state
      when "accepted"
        "success"
      when "rejected", "withdrawn"
        "alert"
      when "evaluating"
        "warning"
      else
        "muted"
      end
    end
  end
end
