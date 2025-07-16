# frozen_string_literal: true

module Decidim
  module Elections
    # Provides access to election resources so that users can participate in elections.
    class VotesController < Decidim::Elections::ApplicationController
      layout "decidim/election_booth"

      include Decidim::FormFactory

      helper_method :exit_path, :election, :questions, :question, :response_chosen?, :votes_buffer, :editing?

      delegate :count, to: :questions, prefix: true

      before_action except: [:new, :create, :receipt] do
        next if allowed_to?(:create, :vote, election:) && session_authenticated?

        flash[:alert] = t("votes.not_authorized", scope: "decidim.elections")
        redirect_to exit_path
      end

      # If the election has a census manifest that a requires authentication, render the auth form
      def new
        enforce_permission_to(:create, :vote, election:)
        if session_authenticated?
          return redirect_to(question_path(question))
        elsif !election.census.auth_form?
          flash[:alert] = t("votes.not_authorized", scope: "decidim.elections")
          return redirect_to exit_path
        end

        @form = election.census.form_instance({}, election:, current_user:)
      end

      # If the election has a census manifest that requires authentication
      # create the session attributes for subsequent automatic validation
      def create
        enforce_permission_to(:create, :vote, election:)

        @form = election.census.form_instance(params, election:, current_user:)
        if @form.valid?
          session[:session_attributes] = @form.attributes
          redirect_to question_path(question)
        else
          flash[:alert] = @form.errors.full_messages.join("<br>").presence || t("failed", scope: "decidim.elections.votes.check_census")
          redirect_to new_election_vote_path(election)
        end
      end

      # Show the voting form for the given question
      def show
        redirect_to(waiting_election_votes_path(election_id: election)) if waiting_for_next_question?
      end

      # Saves the vote for the current question and redirect to the next question
      def update
        save_vote!

        if election.per_question?
          vote = { question.id.to_s => params.dig(:response, question.id.to_s) }
          CastVotes.call(election, vote, voter_uid) do
            on(:ok) do
              session[:voter_uid] = voter_uid
              flash[:notice] = t("votes.cast.success", scope: "decidim.elections")
            end

            on(:invalid) do
              return redirect_to(question_path(question), alert: t("votes.cast.invalid", scope: "decidim.elections"))
            end
          end
        end

        redirect_to question_path(next_pending_question).presence || receipt_election_votes_path(election_id: election)
      end

      # If the election is per-question, this action will be called to show the waiting page
      # while the user waits for the next question to be available.
      # If the election is not per-question, this action will redirect to the next question
      def waiting
        redirect_path = waiting_for_next_question? ? nil : question_path(next_pending_question)

        respond_to do |format|
          format.html do
            redirect_to(redirect_path) if redirect_path.present?
          end

          format.json do
            render json: { url: redirect_path }
          end
        end
      end

      # Shows the confirmation page with the votes that will be cast
      def confirm
        redirect_to(waiting_election_votes_path(election_id: election)) if election.per_question?
      end

      # Casts the votes that have been saved in the session and redirects to the receipt page
      # Does not apply to per-question elections, as they cast votes on each question update
      def cast
        CastVotes.call(election, votes_buffer, voter_uid) do
          on(:ok) do
            votes_buffer.clear
            session[:voter_uid] = voter_uid
            session_attributes.clear
            redirect_to receipt_election_votes_path(election), notice: t("votes.cast.success", scope: "decidim.elections")
          end

          on(:invalid) do
            redirect_to confirm_election_votes_path(election), alert: I18n.t("votes.cast.invalid", scope: "decidim.elections")
          end
        end
      end

      # Shows the receipt page
      def receipt
        enforce_permission_to(:create, :vote, election:)
        return redirect_to(waiting_election_votes_path(election_id: election)) if waiting_for_next_question?

        @voter_uid = session[:voter_uid]
        votes_buffer.clear
        session_attributes.clear
        redirect_to(exit_path) unless election.votes.exists?(voter_uid: @voter_uid)
      end

      private

      def session_authenticated?
        @session_authenticated ||= election.census.valid_user?(election, session_attributes, current_user:)
      end

      def voter_uid
        @voter_uid ||= election.census.voter_uid(election, session_attributes, current_user:)
      end

      def waiting_for_next_question?
        return false unless election.per_question?

        election.per_question_waiting? || election.questions.disabled.any?
      end

      def exit_path
        @exit_path ||= if allowed_to?(:read, :election, election:)
                         election_path(election)
                       else
                         elections_path
                       end
      end

      def election
        @election ||= elections.find(params[:election_id])
      end

      def question
        @question ||= questions.find_by(id: params[:id]) || questions.first
      end

      # Returns the next question to be answered, or nil if there are no more questions
      def next_pending_question
        return question&.next_question if editing?

        voted_ids = votes_buffer.present? ? votes_buffer.keys : []
        questions.where.not(id: voted_ids).first
      end

      def question_path(question)
        options = {}.tap do |opts|
          opts[:edit] = "true" if editing?
        end
        return waiting_election_votes_path(election_id: election) if waiting_for_next_question?

        return election_vote_path(election_id: election, id: question, **options) if question

        confirm_election_votes_path(election_id: election) unless election.per_question?
      end

      def save_vote!
        response_ids = params.dig(:response, question.id.to_s)
        return if response_ids.blank?

        votes_buffer[question.id.to_s] = response_ids
      end

      def votes_buffer
        session[:votes_buffer] ||= {}
      end

      def session_attributes
        session[:session_attributes] ||= {}
      end

      def editing?
        params[:edit].present? && params[:edit] == "true"
      end

      def response_chosen?(response_option)
        return false if votes_buffer.blank?

        response_ids = votes_buffer[question.id.to_s]
        return false if response_ids.blank?

        response_ids.include?(response_option.id.to_s)
      end
    end
  end
end
