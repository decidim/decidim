# frozen_string_literal: true

module Decidim
  module Amendable
    # A command with all the business logic when a user updates and amendment draft.
    class UpdateDraft < Decidim::Command
      delegate :current_user, to: :form

      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(form)
        @form = form
        @amendment = form.amendment
        @amender = form.amender
        @emendation = form.emendation
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the amend.
      # - :invalid if the amendment is not a draft.
      # - :invalid if the form is not valid or the amender is not the current user.
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

      attr_reader :form, :amendment, :amender, :emendation

      # Prevent PaperTrail from creating an additional version
      # in the amendment multi-step creation process (step 3: complete)
      #
      # A first version will be created in step 4: publish
      # for diff rendering in the amendment control version
      def update_draft
        PaperTrail.request(enabled: false) do
          emendation.assign_attributes(form.emendation_params)
          emendation.title = { I18n.locale => form.emendation_params.with_indifferent_access[:title] }
          emendation.body = { I18n.locale => form.emendation_params.with_indifferent_access[:body] }
          emendation.add_author(current_user)
          emendation.save!
        end
      end
    end
  end
end
