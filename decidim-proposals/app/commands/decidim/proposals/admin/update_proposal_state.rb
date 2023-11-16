# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class UpdateProposalState < Decidim::Command
        include TranslatableAttributes

        def initialize(form, state)
          @form = form
          @state = state
        end

        def call
          return broadcast(:invalid) if form.invalid?

          update_state
          broadcast(:ok, state)
        end

        private

        attr_reader :form, :state

        def update_state
          Decidim.traceability.update!(
            state,
            form.current_user,
            **attributes
          )
        end

        # By design, the System parameter is not included in the attributes that are supposed to be edited by the user
        def attributes
          {
            title: form.title,
            description: form.description,
            default: form.default,
            include_in_stats: form.include_in_stats,
            answerable: form.answerable,
            notifiable: form.notifiable,
            gamified: form.gamified,
            announcement_title: form.announcement_title,
            css_class: form.css_class
          }.merge(state.system? ? {} : { token: form.token })
        end
      end
    end
  end
end
