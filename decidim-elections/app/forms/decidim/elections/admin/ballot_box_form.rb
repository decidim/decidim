# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This class holds a form to open and close a ballot box.
      class BallotBoxForm < Decidim::Form
        validate do
          validations.each do |message, t_args, valid|
            errors.add(message, I18n.t("steps.#{current_step}.errors.#{message}", **t_args, scope: "decidim.elections.admin")) unless valid
          end
        end

        def validations
          @validations ||= if current_step == "ready"
                             [
                               [:time_before,
                                { start_time: I18n.l(election.start_time, format: :long),
                                  hours: Decidim::Elections.open_ballot_box_maximum_hours_before_start },
                                election.maximum_hours_before_start?]
                             ].freeze
                           else
                             [
                               [:time_after, { end_time: I18n.l(election.end_time, format: :long) }, election.finished?]
                             ].freeze
                           end
        end

        def messages
          @messages ||= validations.map do |message, t_args, _valid|
            [message, I18n.t("steps.#{current_step}.requirements.#{message}", **t_args, scope: "decidim.elections.admin")]
          end.to_h
        end

        def current_step
          @current_step ||= election.bb_status
        end

        def election
          @election ||= context[:election]
        end

        def bulletin_board
          @bulletin_board ||= context[:bulletin_board] || Decidim::Elections.bulletin_board
        end
      end
    end
  end
end
