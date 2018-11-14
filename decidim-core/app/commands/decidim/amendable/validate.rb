# frozen_string_literal: true

module Decidim
  module Amendable
    # A command with all the business logic when a user starts amending a resource.
    class Validate < Rectify::Command
      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # amendable    - The resource that is being amended.
      def initialize(form)
        @form = form
        @amendable = form.amendable
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid, together with the amend.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?
        return broadcast(:invalid) if amendable_form.invalid?
        return broadcast(:invalid) if emendation_doesnt_change_amendable

        broadcast(:ok)
      end

      private

      attr_reader :form

      def amendable_form
        @amendable.form.from_params(emendation_attributes).with_context(context)
      end

      def emendation_attributes
        fields = {}

        parsed_title = Decidim::ContentProcessor.parse_with_processor(:hashtag, form[:emendation_fields][:title], current_organization: form.current_organization).rewrite
        parsed_body = Decidim::ContentProcessor.parse_with_processor(:hashtag, form[:emendation_fields][:body], current_organization: form.current_organization).rewrite

        fields[:title] = parsed_title
        fields[:body] = parsed_body
        fields[:decidim_component_id] = @amendable.component.id
        fields[:decidim_scope_id] = @amendable.scope.id
        fields[:decidim_amendable_id] = @amendable.id
        fields[:published_at] = Time.current if form.emendation_type == "Decidim::Proposals::Proposal"
        fields
      end

      def context
        {
          current_organization: @amendable.organization,
          current_component: @amendable.component,
          current_user: form.current_user,
          current_participatory_space: @amendable.participatory_space
        }
      end

      def emendation_doesnt_change_amendable
        emendation_title = emendation_attributes[:title]
        emendation_body = emendation_attributes[:body]
        emendation_title == @amendable.title && emendation_body == @amendable.body
      end
    end
  end
end
