# frozen_string_literal: true

module Decidim
  module Initiatives
    module Admin
      # A command with all the business logic that updates an
      # existing initiative.
      class UpdateInitiative < Rectify::Command
        # Public: Initializes the command.
        #
        # initiative - Decidim::Initiative
        # form       - A form object with the params.
        def initialize(initiative, form, current_user)
          @form = form
          @initiative = initiative
          @current_user = current_user
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          @initiative = Decidim.traceability.update!(
            initiative,
            current_user,
            attributes
          )
          broadcast(:ok, initiative)
        rescue ActiveRecord::RecordInvalid
          broadcast(:invalid, initiative)
        end

        private

        attr_reader :form, :initiative, :current_user

        def attributes
          attrs = {
            title: form.title,
            description: form.description,
            signature_type: form.signature_type,
            hashtag: form.hashtag,
            answer: form.answer,
            answer_url: form.answer_url
          }

          attrs[:answered_at] = DateTime.now unless form.answer.blank?

          if current_user.admin?
            attrs[:signature_start_time] = form.signature_start_time
            attrs[:signature_end_time] = form.signature_end_time
            attrs[:offline_votes] = form.offline_votes
          end

          attrs
        end
      end
    end
  end
end
