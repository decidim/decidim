# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This class holds a form to perform an action on the BB.
      class ActionForm < Decidim::Form
        validates :pending_action, absence: true

        def messages
          @messages ||= {}
        end

        def current_step
          @current_step ||= election.bb_status
        end

        def election
          @election ||= context[:election]
        end

        def questions
          @questions ||= election.questions
        end

        def answers
          @answers ||= Decidim::Elections::Answer.where(question: questions)
        end

        def pending_action
          return @pending_action if defined?(@pending_action)

          @pending_action = election.actions.pending.first
        end

        def bulletin_board
          @bulletin_board ||= context[:bulletin_board] || Decidim::Elections.bulletin_board
        end
      end
    end
  end
end
