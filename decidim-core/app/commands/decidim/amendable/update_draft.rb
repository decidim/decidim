# frozen_string_literal: true

module Decidim
  module Amendable
    # A command with all the business logic when a user starts amending a resource.
    class UpdateDraft < Rectify::Command
      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # amendable    - The resource that is being amended.
      def initialize(form)
        @form = form
        @amendment = form.amendment
        @amender = form.amender
        @emendation = form.emendation
        @current_user = form.current_user
        @user_group = Decidim::UserGroup.find_by(id: form.user_group_id)
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the amend.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) unless form.valid? && amendment.draft? && amender == current_user

        transaction do
          update_draft
        end

        broadcast(:ok, @amendment)
      end

      private

      attr_reader :form, :amendment, :amender, :emendation, :current_user, :user_group

      # Prevent PaperTrail from creating an additional version
      # in the amendment multi-step creation process (step 3: complete)
      #
      # A first version will be created in step 4: publish
      # for diff rendering in the amendment control version
      def update_draft
        PaperTrail.request(enabled: false) do
          emendation.update(form.emendation_params)
          emendation.coauthorships.clear
          emendation.add_coauthor(current_user, user_group: user_group)
        end
      end
    end
  end
end
