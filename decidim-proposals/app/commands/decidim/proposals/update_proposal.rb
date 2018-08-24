# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user updates a proposal.
    class UpdateProposal < Rectify::Command
      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # current_user - The current user.
      # proposal - the proposal to update.
      def initialize(form, current_user, proposal)
        @form = form
        @current_user = current_user
        @proposal = proposal
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the proposal.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?
        return broadcast(:invalid) unless proposal.editable_by?(current_user)
        return broadcast(:invalid) if proposal_limit_reached?

        if process_attachments?
          @proposal.attachments.destroy_all

          build_attachment
          return broadcast(:invalid) if attachment_invalid?
        end

        transaction do
          update_proposal
          create_attachment if process_attachments?
        end

        broadcast(:ok, proposal)
      end

      private

      attr_reader :form, :proposal, :current_user, :attachment

      def update_proposal
        parsed_title = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.title, current_organization: form.current_organization).rewrite
        parsed_body = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.body, current_organization: form.current_organization).rewrite

        @proposal.update!(
          title: parsed_title,
          body: parsed_body,
          category: form.category,
          scope: form.scope,
          address: form.address,
          latitude: form.latitude,
          longitude: form.longitude
        )
        @proposal.coauthorships.clear
        @proposal.add_coauthor(current_user, decidim_user_group_id: user_group&.id)
      end

      def proposal_limit_reached?
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
        @organization ||= current_user.organization
      end

      def current_user_proposals
        Proposal.from_author(current_user).where(component: form.current_component).published.where.not(id: proposal.id)
      end

      def user_group_proposals
        Proposal.from_user_group(user_group).where(component: form.current_component).published.where.not(id: proposal.id)
      end

      def build_attachment
        @attachment = Attachment.new(
          title: form.attachment.title,
          file: form.attachment.file,
          attached_to: @proposal
        )
      end

      def attachment_invalid?
        if form.attachment.invalid? && form.attachment.errors.has_key?(:file)
          form.attachment.errors.add :file, attachment.errors[:file]
          true
        end
      end

      def attachment_present?
        return if form.attachment.nil?
        form.attachment.file.present?
      end

      def create_attachment
        attachment.attached_to = proposal
        attachment.save!
      end

      def attachments_allowed?
        form.current_component.settings.attachments_allowed?
      end

      def process_attachments?
        attachments_allowed? && attachment_present?
      end
    end
  end
end
