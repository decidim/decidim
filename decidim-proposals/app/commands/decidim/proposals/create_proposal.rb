# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user creates a new proposal.
    class CreateProposal < Rectify::Command
      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # current_user - The current user.
      def initialize(form, current_user)
        @form = form
        @current_user = current_user
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

        if process_attachments?
          build_attachment
          return broadcast(:invalid) if attachment_invalid?
        end

        transaction do
          create_proposal
          create_attachment if process_attachments?
        end

        broadcast(:ok, proposal)
      end

      private

      attr_reader :form, :proposal, :attachment

      def create_proposal
        @proposal = Proposal.create!(
          title: form.title,
          body: form.body,
          category: form.category,
          scope: form.scope,
          author: @current_user,
          decidim_user_group_id: form.user_group_id,
          feature: form.feature,
          address: form.address,
          latitude: form.latitude,
          longitude: form.longitude
        )
      end

      def build_attachment
        @attachment = Attachment.new(
          title: form.attachment.title,
          file: form.attachment.file,
          attached_to: @proposal
        )
      end

      def attachment_invalid?
        if attachment.invalid? && attachment.errors.has_key?(:file)
          form.attachment.errors.add :file, attachment.errors[:file]
          true
        end
      end

      def attachment_present?
        form.attachment.file.present?
      end

      def create_attachment
        attachment.attached_to = proposal
        attachment.save!
      end

      def attachments_allowed?
        form.current_feature.settings.attachments_allowed?
      end

      def process_attachments?
        attachments_allowed? && attachment_present?
      end

      def proposal_limit_reached?
        proposal_limit = form.current_feature.settings.proposal_limit

        return false if proposal_limit.zero?

        if user_group
          user_group_proposals.count >= proposal_limit
        else
          current_user_proposals.count >= proposal_limit
        end
      end

      def user_group
        @user_group ||= Decidim::UserGroup.where(organization: organization, id: form.user_group_id).first
      end

      def organization
        @organization ||= @current_user.organization
      end

      def current_user_proposals
        Proposal.where(author: @current_user, feature: form.current_feature)
      end

      def user_group_proposals
        Proposal.where(user_group: @user_group, feature: form.current_feature)
      end
    end
  end
end
