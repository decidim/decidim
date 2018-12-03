# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user updates a proposal.
    class UpdateProposal < Rectify::Command
      include AttachmentMethods
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
        return broadcast(:invalid) if form.invalid?
        return broadcast(:invalid) unless proposal.editable_by?(current_user)
        return broadcast(:invalid) if proposal_limit_reached?

        if process_attachments?
          @proposal.attachments.destroy_all

          build_attachment
          return broadcast(:invalid) if attachment_invalid?
        end

        transaction do
          if @proposal.draft?
            update_draft
          else
            update_proposal
          end
          create_attachment if process_attachments?
        end

        broadcast(:ok, proposal)
      end

      private

      attr_reader :form, :proposal, :current_user, :attachment

      def proposal_attributes
        fields = {}

        fields[:title] = parsed_title
        fields[:body] = parsed_body
        fields[:category] = form.category
        fields[:scope] = form.scope
        fields[:address] = form.address
        fields[:latitude] = form.latitude
        fields[:longitude] = form.longitude

        fields
      end

      # Prevent PaperTrail from creating an additional version
      # in the proposal multi-step creation process (step 3: complete)
      def update_draft
        PaperTrail.request(enabled: false) do
          @proposal.update(proposal_attributes)
          @proposal.coauthorships.clear
          @proposal.add_coauthor(current_user, user_group: user_group)
        end
      end

      def update_proposal
        @proposal = Decidim.traceability.update!(
          @proposal,
          current_user,
          proposal_attributes,
          visibility: "public-only"
        )
        @proposal.coauthorships.clear
        @proposal.add_coauthor(current_user, user_group: user_group)
      end

      def parsed_title
        @parsed_title ||= Decidim::ContentProcessor.parse_with_processor(:hashtag, form.title, current_organization: form.current_organization).rewrite
      end

      def parsed_body
        @parsed_body ||= begin
          ret = Decidim::ContentProcessor.parse_with_processor(:hashtag, form.body, current_organization: form.current_organization).rewrite.strip
          ret += "\n" + parsed_extra_hashtags.strip unless parsed_extra_hashtags.empty?
          ret
        end
      end

      def parsed_extra_hashtags
        @parsed_extra_hashtags ||= Decidim::ContentProcessor.parse_with_processor(
          :hashtag,
          form.extra_hashtags.map { |hashtag| "##{hashtag}" }.join(" "),
          current_organization: form.current_organization,
          extra_hashtags: true
        ).rewrite
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
    end
  end
end
