# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user updates a proposal.
    class UpdateProposal < Decidim::Command
      include ::Decidim::MultipleAttachmentsMethods
      include GalleryMethods
      include HashtagsMethods

      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # current_user - The current user.
      # proposal - the proposal to update.
      def initialize(form, current_user, proposal)
        @form = form
        @current_user = current_user
        @proposal = proposal
        @attached_to = proposal
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the proposal.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if invalid?

        if process_attachments?
          build_attachments
          return broadcast(:invalid) if attachments_invalid?
        end

        if process_gallery?
          build_gallery
          return broadcast(:invalid) if gallery_invalid?
        end

        transaction do
          if @proposal.draft?
            update_draft
          else
            update_proposal
          end

          photo_cleanup!
          document_cleanup!

          create_gallery if process_gallery?
          create_attachments(first_weight: first_attachment_weight) if process_attachments?
        end

        broadcast(:ok, proposal)
      end

      private

      attr_reader :form, :proposal, :current_user, :attachment

      def invalid?
        form.invalid? || !proposal.editable_by?(current_user) || proposal_limit_reached?
      end

      # Prevent PaperTrail from creating an additional version
      # in the proposal multi-step creation process (step 3: complete)
      #
      # A first version will be created in step 4: publish
      # for diff rendering in the proposal control version
      def update_draft
        PaperTrail.request(enabled: false) do
          @proposal.update(attributes)
          @proposal.coauthorships.clear
          @proposal.add_coauthor(current_user, user_group:)
        end
      end

      def update_proposal
        @proposal = Decidim.traceability.update!(
          @proposal,
          current_user,
          attributes,
          visibility: "public-only"
        )
        @proposal.coauthorships.clear
        @proposal.add_coauthor(current_user, user_group:)
      end

      def attributes
        {
          title: {
            I18n.locale => title_with_hashtags
          },
          body: {
            I18n.locale => body_with_hashtags
          },
          category: form.category,
          scope: form.scope,
          address: form.address,
          latitude: form.latitude,
          longitude: form.longitude
        }
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

      def first_attachment_weight
        return 1 if proposal.photos.count.zero?

        proposal.photos.count
      end

      def user_group
        @user_group ||= Decidim::UserGroup.find_by(organization:, id: form.user_group_id)
      end

      def organization
        @organization ||= current_user.organization
      end

      def current_user_proposals
        Proposal.from_author(current_user).where(component: form.current_component).published.where.not(id: proposal.id).except_withdrawn
      end

      def user_group_proposals
        Proposal.from_user_group(user_group).where(component: form.current_component).published.where.not(id: proposal.id).except_withdrawn
      end
    end
  end
end
