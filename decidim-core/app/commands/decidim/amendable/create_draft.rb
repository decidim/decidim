# frozen_string_literal: true

module Decidim
  module Amendable
    # A command with all the business logic when a user starts amending a resource.
    class CreateDraft < Decidim::Command
      delegate :current_user, :current_organization, to: :form

      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(form)
        @form = form
        @amendable = form.amendable
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the amend.
      # - :invalid if the form was not valid and we could not proceed.
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

      attr_reader :form, :amendable

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
            emendation.taxonomies = amendable.taxonomies if amendable.respond_to?(:taxonomies)
            emendation.add_author(current_user)
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
