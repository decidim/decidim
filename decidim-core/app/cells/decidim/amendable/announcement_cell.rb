# frozen_string_literal: true

module Decidim::Amendable
  # This cell renders the callout with information about the state of the emendation
  class AnnouncementCell < Decidim::ViewModel

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
        announcement_date: announcement_date,
        publish_as_button: publish_as_button
      )
    end

    def amendable_link
      link_to resource_locator(model.amendable).path do
        %{<strong>#{model.amendable.title}</strong>}
      end
    end

    def amendable_type
      @amendable_type ||= t(model.class.model_name.i18n_key, scope: "activerecord.models", count: 1).downcase
    end

    def announcement_date
      model.amendment.updated_at
    end

    def publish_as_button
      return unless model.emendation_state == "rejected"
      link_to "#publish_as" do
        t("publish_as",
          scope: "decidim.amendments.emendation.announcement",
          amendable_type: amendable_type
        )
      end
    end


    def state_classes
      case model.emendation_state
      when "accepted"
        "success"
      when "rejected"
        "alert"
      when "evaluating"
        "warning"
      else
        "muted"
      end
    end
  end
end
