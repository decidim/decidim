# frozen_string_literal: true

module Decidim::Amendable
  # This cell renders the callout with information about the state of the emendation
  class AnnouncementCell < Decidim::ViewModel
    def show
      cell "decidim/announcement", announcement, callout_class:, callout_styles:
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
        date:)
    end

    def proposal_link(resource = model.amendable, text = nil)
      text ||= %(<strong>#{decidim_sanitize(present(model.amendable).title, strip_tags: true)}</strong>)
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

    def callout_class
      return "muted" if model.state.blank?
      return "alert" if model.withdrawn?
    end

    def callout_styles
      return if model.state.blank? || model.withdrawn?

      model.proposal_state&.css_style
    end
  end
end
