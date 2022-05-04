# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This class holds a form to start and end the voting period.
      class VotePeriodForm < ActionForm
        validate do
          validations.each do |message, t_args, valid|
            errors.add(message, I18n.t("steps.#{current_step}.errors.#{message}", **t_args, scope: "decidim.elections.admin")) unless valid
          end
        end

        def validations
          @validations ||= if current_step == "key_ceremony_ended"
                             [
                               [:time_before,
                                { start_time: I18n.l(election.start_time, format: :long),
                                  hours: Decidim::Elections.start_vote_maximum_hours_before_start },
                                election.maximum_hours_before_start?]
                             ].freeze
                           else
                             [
                               [:time_after, { end_time: I18n.l(election.end_time, format: :long) }, election.finished?]
                             ].freeze
                           end
        end

        def messages
          @messages ||= validations.to_h do |message, t_args, _valid|
            [message, I18n.t("steps.#{current_step}.requirements.#{message}", **t_args, scope: "decidim.elections.admin")]
          end
        end
      end
    end
  end
end
