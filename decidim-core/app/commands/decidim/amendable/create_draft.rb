# frozen_string_literal: true

module Decidim
  module Amendable
    # A command with all the business logic when a user starts amending a resource.
    class CreateDraft < Decidim::Command
      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      def initialize(form)
        @form = form
        @amendable = form.amendable
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
        return broadcast(:invalid) if form.invalid?

        transaction do
          create_emendation!
          create_amendment!
        end

        broadcast(:ok, @amendment)
      end

      private

      attr_reader :form, :amendable, :current_user, :user_group

      # Prevent PaperTrail from creating an additional version
      # in the amendment multi-step creation process (step 1: create)
      #
      # A first version will be created in step 4: publish
      # for diff rendering in the amendment control version
      def create_emendation!
        PaperTrail.request(enabled: false) do
          @emendation = Decidim.traceability.perform_action!(
            :create,
            amendable.class,
            current_user,
            visibility: "public-only"
          ) do
            emendation = amendable.class.new(form.emendation_params)
            emendation.title = { I18n.locale => form.emendation_params.with_indifferent_access[:title] }
            emendation.body = { I18n.locale => form.emendation_params.with_indifferent_access[:body] }
            emendation.component = amendable.component
            emendation.add_author(current_user, user_group)
            emendation.save!
            emendation
          end
        end
      end

      def create_amendment!
        @amendment = Decidim::Amendment.create!(
          amender: current_user,
          amendable:,
          emendation: @emendation,
          state: "draft"
        )
      end
    end
  end
end
