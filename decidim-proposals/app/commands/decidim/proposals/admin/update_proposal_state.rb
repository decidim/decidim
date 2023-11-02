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

        def attributes
          {
            title: form.title,
            description: form.description,
            default: form.default,
            token: form.token,
            system: form.system,
            include_in_stats: form.include_in_stats,
            css_class: form.css_class
          }
        end
      end
    end
  end
end
