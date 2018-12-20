# frozen_string_literal: true

module Decidim::Amendable
  # This cell renders the callout with information about the state of the emendation
  class AnnouncementCell < Decidim::ViewModel
    include Decidim::ApplicationHelper

    def show
      cell "decidim/announcement", announcement
    end

    private

    def announcement
      {
        announcement: emendation_message,
        callout_class: state_classes
      }
    end

    def emendation_message
      t(model.emendation_state,
        scope: "decidim.amendments.emendation.announcement",
        amendable_type: amendable_type,
        amendable_link: amendable_link,
        announcement_date: announcement_date)
    end

    def amendable_link
      link_to resource_locator(model.amendable).path do
        %(<strong>#{present(model.amendable).title}</strong>)
      end
    end

    def amendable_type
      @amendable_type ||= t(model.class.model_name.i18n_key, scope: "activerecord.models", count: 1).downcase
    end

    def announcement_date
      model.amendment.updated_at
    end

    def state_classes
      case model.emendation_state
      when "accepted"
        "success"
      when "rejected"
        "alert"
      when "evaluating"
        "warning"
      when "withdrawn"
        "alert"
      else
        "muted"
      end
    end
  end
end
