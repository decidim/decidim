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
        next if allowed_to?(:create, :vote, election:) && election.census.valid_user?(election, session_credentials, current_user:)

        flash[:alert] = t("votes.not_authorized", scope: "decidim.elections")
        redirect_to exit_path
      end

      # If the election has a census manifest that a prior requires authentication, render the auth form
      # Otherwise, the current user will be send as data for checking if they are allowed to vote
      # (Note that a census manifest can still allow unauthenticated users to vote)
      def new
        enforce_permission_to(:create, :vote, election:)

        redirect_to(election_vote_path(election_id: election, id: question)) && return unless election.census.auth_form?

        @form = election.census.form_instance({}, election:, current_user:)
      end

      def create
        enforce_permission_to(:create, :vote, election:)

        @form = election.census.form_instance(params, { election:, current_user: })
        if @form.valid?
          session[:session_credentials] = @form.attributes
          redirect_to election_vote_path(election_id: election, id: question)
        else
          flash[:alert] = t("failed", scope: "decidim.elections.votes.check_census", errors: @form.errors.full_messages.join(", "))
          redirect_to new_election_vote_path(election)
        end
      end

      # Show the voting form for the given question
      def show; end

      # This action is used to save the vote for the current question and redirect to the next question
      def update
        save_vote!

        if next_pending_question
          redirect_to election_vote_path(election_id: election, id: next_pending_question, edit: editing?)
        elsif election.per_question_waiting?
          # TODO: show spinner and message
          byebug
        else
          redirect_to confirm_election_votes_path(election_id: election)
        end
      end

      # This action is used to show the confirmation page with the votes that will be cast
      def confirm
        render :confirm
      end

      def cast
        CastVotes.call(election, votes_buffer, session_credentials) do
          on(:ok) do
            votes_buffer.clear
            session[:voter_uid] = election.census.user_uid(session_credentials)
            session[:session_credentials] = nil
            flash[:notice] = t("votes.cast.success", scope: "decidim.elections")
            redirect_to receipt_election_votes_path(election), notice: t("votes.cast.success", scope: "decidim.elections")
          end

          on(:invalid) do
            flash[:alert] = I18n.t("votes.cast.invalid", scope: "decidim.elections")
            redirect_to confirm_election_votes_path(election)
          end
        end
      end

      def receipt
        enforce_permission_to(:create, :vote, election:)

        @voter_uid = session[:voter_uid]
        redirect_to(exit_path) && return unless election.votes.exists?(voter_uid: @voter_uid)

        render :receipt
      end

      private

      def session_credentials
        @session_credentials ||= session[:session_credentials] || current_user
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

      def questions
        @questions ||= begin
          list = election.questions
          list = list.enabled if election.per_question?
          list.includes(:response_options)
        end
      end

      def question
        @question ||= questions.find_by(id: params[:id]) || questions.first
      end

      # Returns the next question to be answered, or nil if there are no more questions
      def next_pending_question
        return question.next_question if votes_buffer.blank? || editing?

        questions.where.not(id: votes_buffer.keys).first
      end

      def save_vote!
        response_ids = params.dig(:response, question.id.to_s)
        return if response_ids.blank?

        votes_buffer[question.id.to_s] = response_ids
      end

      def votes_buffer
        session[:votes_buffer] ||= {}
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
