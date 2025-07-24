# frozen_string_literal: true

module Decidim
  module Elections
    # Provides access to election resources so that users can participate Election.where(component: current_component).published.lections.
    module UsesVotesBooth
      extend ActiveSupport::Concern

      included do
        layout "decidim/election_booth"
        helper_method :exit_path, :election, :questions, :question, :response_chosen?, :votes_buffer

        before_action except: [:new, :create, :receipt] do
          next if allowed_to?(:create, :vote, election:) && session_authenticated?

          flash[:alert] = t("votes.not_authorized", scope: "decidim.elections")
          redirect_to exit_path
        end

        # If the election has a census manifest that a requires authentication, render the auth form
        def new
          enforce_permission_to(:create, :vote, election:)
          if session_authenticated?
            return redirect_to(election_vote_path(election, id: question))
          elsif !election.census.auth_form?
            flash[:alert] = t("votes.not_authorized", scope: "decidim.elections")
            return redirect_to exit_path
          end

          @form = election.census.form_instance({}, election:, current_user:)
          render "decidim/elections/votes/new"
        end

        # If the election has a census manifest that requires authentication
        # create the session attributes for subsequent automatic validation
        def create
          enforce_permission_to(:create, :vote, election:)

          @form = election.census.form_instance(params, election:, current_user:)
          if @form.valid?
            session[:session_attributes] = @form.attributes
            redirect_to election_vote_path(election, id: question)
          else
            flash[:alert] =
              @form.errors.full_messages.join("<br>").presence || t("failed", scope: "decidim.elections.votes.check_census")
            redirect_to action: :new
          end
        end
      end

      private

      def election
        @election ||= Election.where(component: current_component).published.find(params[:election_id])
      end

      def questions
        @questions ||= election.questions
      end

      def question
        @question ||= questions.find_by(id: params[:id]) || questions.first
      end

      def session_authenticated?
        @session_authenticated ||= election.census.valid_user?(election, session_attributes, current_user:)
      end

      def voter_uid
        @voter_uid ||= election.census.voter_uid(election, session_attributes, current_user:)
      end

      def votes_buffer
        session[:votes_buffer] ||= {}
      end

      def session_attributes
        session[:session_attributes] ||= {}
      end

      def response_chosen?(response_option)
        response_ids = if votes_buffer.has_key?(question.id.to_s)
                         votes_buffer[question.id.to_s]
                       else
                         previous_responses[question.id.to_s]
                       end
        return false if response_ids.blank?

        response_ids.include?(response_option.id.to_s)
      end

      def previous_responses
        @previous_responses ||= election.questions.to_h do |question|
          [question.id.to_s, question.votes.where(voter_uid: voter_uid).pluck(:response_option_id).map(&:to_s)]
        end
      end

      def exit_path
        @exit_path ||= if allowed_to?(:read, :election, election:)
                         election_path(election)
                       else
                         elections_path
                       end
      end
    end
  end
end
