# frozen_string_literal: true

module Decidim::Amendable
  # This cell renders the button to amend the given resource.
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
      case model.emendation_state
      when "accepted"
        t(:accepted,
          scope: "decidim.amendments.emendation.announcement",
          amendable_type: amendable_type,
          amendable_link: amendable_link,
          announcement_date: announcement_date
        )
      when "rejected"
        t(:rejected,
          scope: "decidim.amendments.emendation.announcement",
          amendable_type: amendable_type,
          amendable_link: amendable_link,
          announcement_date: announcement_date,
          publish_as_button: publish_as_button
        )
      when "evaluating"
        t(:evaluating,
          scope: "decidim.amendments.emendation.announcement",
          amendable_type: amendable_type,
          amendable_link: amendable_link
        )
      end
    end

    def amendable_link
      link_to resource_locator(model.amendable).path do
        %{<strong>#{model.amendable.title}</strong>}
      end
    end

    def amendable_type
      @label ||= t(model.class.model_name.i18n_key, scope: "activerecord.models", count: 1).downcase
    end

    def announcement_date
      case model.emendation_state
      when "accepted"
        Time.now
      when "rejected"
        Time.now
      when "evaluating"
        model.created_at
      end
    end

    def publish_as_button
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
