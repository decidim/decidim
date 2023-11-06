# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class CreateProposalState < Decidim::Command
        def initialize(form, component)
          @form = form
          @component = component
        end

        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            create_proposal_status
          end

          broadcast(:ok, @resource)
        end

        private

        attr_reader :form, :component, :resource

        def create_proposal_status
          @resource = Decidim.traceability.create(
            Decidim::Proposals::ProposalState,
            form.current_user,
            attributes,
            **extra_params
          )
        end

        # By design, the System parameter is not included in the attributes that are supposed to be edited by the user
        def attributes
          {
            title: form.title,
            description: form.description,
            default: form.default,
            token: form.token,
            include_in_stats: form.include_in_stats,
            css_class: form.css_class,
            answerable: form.answerable,
            notifiable: form.notifiable,
            component:
          }
        end

        def extra_params
          {}
        end
      end
    end
  end
end
