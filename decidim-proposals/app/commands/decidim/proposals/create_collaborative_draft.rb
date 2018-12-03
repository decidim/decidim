# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic when a user creates a new collaborative draft.
    class CreateCollaborativeDraft < Rectify::Command
      include AttachmentMethods
      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # current_user - The current user.
      def initialize(form, current_user)
        @form = form
        @current_user = current_user
        @attached_to = nil
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the collaborative draft.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        if process_attachments?
          build_attachment
          return broadcast(:invalid) if attachment_invalid?
        end

        transaction do
          create_collaborative_draft
          create_attachment if process_attachments?
        end

        broadcast(:ok, collaborative_draft)
      end

      private

      attr_reader :form, :collaborative_draft, :attachment

      def create_collaborative_draft
        @collaborative_draft = Decidim.traceability.perform_action!(
          :create,
          CollaborativeDraft,
          @form.current_user,
          visibility: "public-only"
        ) do
          draft = CollaborativeDraft.new(
            title: parsed_title,
            body: parsed_body,
            category: form.category,
            scope: form.scope,
            component: form.component,
            address: form.address,
            latitude: form.latitude,
            longitude: form.longitude,
            state: "open"
          )
          draft.coauthorships.build(author: @current_user, user_group: @form.user_group)
          draft.save!
          draft
        end

        @attached_to = @collaborative_draft
      end

      def user_group
        @user_group ||= Decidim::UserGroup.find_by(organization: organization, id: form.user_group_id)
      end

      def organization
        @organization ||= @current_user.organization
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
    end
  end
end
