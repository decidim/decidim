# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user creates a new proposal.
    class CreateProposal < Rectify::Command
      include AttachmentMethods
      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # current_user - The current user.
      # coauthorships - The coauthorships of the proposal.
      def initialize(form, current_user, coauthorships = nil)
        @form = form
        @current_user = current_user
        @coauthorships = coauthorships
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the proposal.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        if proposal_limit_reached?
          form.errors.add(:base, I18n.t("decidim.proposals.new.limit_reached"))
          return broadcast(:invalid)
        end

        transaction do
          create_proposal
        end

        broadcast(:ok, proposal)
      end

      private

      attr_reader :form, :proposal, :attachment

      def create_proposal
        @proposal = Proposal.create!(
          title: form.title,
          body: form.body,
          component: form.component
        )
        proposal.add_coauthor(@current_user, user_group: user_group)
      end

      def proposal_limit_reached?
        return false if @coauthorships.present?

        proposal_limit = form.current_component.settings.proposal_limit

        return false if proposal_limit.zero?

        if user_group
          user_group_proposals.count >= proposal_limit
        else
          current_user_proposals.count >= proposal_limit
        end
      end

      def user_group
        @user_group ||= Decidim::UserGroup.find_by(organization: organization, id: form.user_group_id)
      end

      def organization
        @organization ||= @current_user.organization
      end

      def current_user_proposals
        Proposal.from_author(@current_user).where(component: form.current_component).except_withdrawn
      end

      def user_group_proposals
        Proposal.from_user_group(@user_group).where(component: form.current_component).except_withdrawn
      end
    end
  end
end
