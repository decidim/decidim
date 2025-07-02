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
        token = params.dig(:login, :token).to_s.strip

        if valid_token?(token)
          redirect_to question_election_votes_path(election_id: election.id, id: 0)
        else
          flash[:alert] = t("invalid", scope: "decidim.elections.votes.check_census")
          redirect_to new_election_vote_path(election)
        end
      end

      def step
        step_index = params[:step].to_i

        case step_index
        when 0...questions_count then render_question(step_index)
        when questions_count then render :confirm_vote
        else redirect_to exit_path
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
        render :confirm_vote, layout: "decidim/election_booth"
      end

      private

      def exit_path
        @exit_path ||= if allowed_to?(:view, :election, election:)
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

      def vote_allowed?
        unless can_vote?
          redirect_to(exit_path, alert: t("votes.messages.not_allowed", scope: "decidim.elections"))
          return false
        end

        enforce_permission_to(:vote, :election, election:)

        true
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

      def valid_token?(token)
        voter&.token == token
      end
    end
  end
end
