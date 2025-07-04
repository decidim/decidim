# frozen_string_literal: true

module Decidim
  module Elections
    # Provides access to election resources so that users can participate in elections.
    class VotesController < Decidim::Elections::ApplicationController
      layout "decidim/election_booth"

      include FormFactory
      include Decidim::UserProfile

      helper_method :exit_path, :elections, :election, :questions, :questions_count, :voter_not_yet_in_census?, :voter

      delegate :count, to: :questions, prefix: true

      def new
        case election.census_manifest
        when "token_csv"
          @form = form(LoginForm).instance
          render :new, layout: "decidim/election_booth"
        else
          if authorized_to_vote?
            redirect_to question_election_votes_path(election_id: election.id, id: 0)
          else
            flash[:alert] = t("votes.messages.not_authorized", scope: "decidim.elections")
            redirect_to exit_path
          end
        end
      end

      def check_verification
        email = params.dig(:login, :email).to_s.strip.downcase
        token = params.dig(:login, :token).to_s.strip

        if valid_voter?(email, token)
          redirect_to question_election_votes_path(election_id: election.id, id: 0)
        else
          flash[:alert] = t("invalid", scope: "decidim.elections.votes.check_census")
          redirect_to new_election_vote_path(election)
        end
      end

      def question
        @question = questions[params[:id].to_i]

        if @question
          render :vote_question, layout: "decidim/election_booth"
        else
          redirect_to exit_path
        end
      end

      def confirm
        @questions = questions
        @responses = session[:votes_buffer] || {}
        render :confirm_vote, layout: "decidim/election_booth"
      end

      def step
        step_index = params[:id].to_i

        save_vote(step_index) if request.post?

        next_step = step_index + 1

        if next_step < questions_count
          redirect_to question_election_votes_path(election_id: election.id, id: next_step)
        elsif next_step == questions_count
          redirect_to confirm_election_votes_path(election_id: election.id)
        else
          redirect_to exit_path
        end
      end

      def cast_vote
        votes_data = session[:votes_buffer] || {}

        ConfirmVote.call(election:, voter:, votes_data:) do
          on(:ok) do
            session[:votes_buffer] = nil
            flash[:notice] = t("votes.cast_vote.success", scope: "decidim.elections")
            redirect_to exit_path, notice: t("votes.cast_vote.success", scope: "decidim.elections")
          end

          on(:invalid) do
            flash[:alert] = I18n.t("votes.cast_vote.invalid", scope: "decidim.elections")
            redirect_to confirm_election_votes_path(election_id: election.id)
          end
        end
      end

      private

      def exit_path
        @exit_path ||= if allowed_to?(:read, :election, election:)
                         election_path(election)
                       else
                         elections_path
                       end
      end

      def elections
        @elections ||= Decidim::Elections::Election.where(component: current_component)
      end

      def election
        @election ||= elections.find(params[:election_id])
      end

      def questions
        @questions ||= election.questions.includes(:response_options).order(position: :asc)
      end

      def voter_not_yet_in_census?
        voter.nil?
      end

      def authorized_to_vote?
        return false unless current_user
        return true if current_user.admin?

        required_verifications = election.verification_types
        user_authorizations = Decidim::Verifications::Authorizations.new(
          organization: current_organization,
          user: current_user,
          granted: true
        ).query.pluck(:name)

        required_verifications.all? { |type| user_authorizations.include?(type) }
      end

      def voter
        @voter ||= Decidim::Elections::Voter.with_email(current_user&.email).find_by(election_id: election.id)
      end

      def valid_voter?(email, token)
        voter&.token == token && voter&.email == email && voter&.election_id == election.id
      end

      def save_vote(step_index)
        question = questions[step_index]
        response_option_id = params.dig(:response, :votes, question.id.to_s, :response_option_id)

        return if response_option_id.blank?

        session[:votes_buffer] ||= {}
        session[:votes_buffer][question.id.to_s] = { "response_option_id" => response_option_id }
      end
    end
  end
end
