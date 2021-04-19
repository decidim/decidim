# frozen_string_literal: true

module Decidim
  module Conferences
    module AdminLog
      # This class holds the logic to present a `Decidim::ConferenceSpeaker`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you shouldn't need to call this class
      # directly, but here's an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    ConferenceSpeakerPresenter.new(action_log, view_helpers).present
      class ConferenceSpeakerPresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          {
            full_name: :string,
            gender: :string,
            birthday: :date,
            birthplace: :string,
            designation_date: :date,
            designation_mode: :string,
            position: "Decidim::Conferences::AdminLog::ValueTypes::SpeakerPositionPresenter",
            position_other: :string,
            weight: :integer,
            ceased_date: :date
          }
        end

        def i18n_labels_scope
          "activemodel.attributes.conference_speaker"
        end

        def action_string
          case action
          when "create", "delete", "update"
            "decidim.admin_log.conference_speaker.#{action}"
          else
            super
          end
        end

        def diff_actions
          super + %w(delete)
        end
      end
    end
  end
end
