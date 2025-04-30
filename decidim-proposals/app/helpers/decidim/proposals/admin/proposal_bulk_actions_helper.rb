# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      module ProposalBulkActionsHelper
        def proposal_find(id)
          Decidim::Proposals::Proposal.find(id)
        end

        # Public: Generates a select field with the templates of the given component.
        #
        # component - A component instance.
        # prompt - An i18n string to show as prompt
        #
        # Returns a String.
        def bulk_templates_select(component, prompt, id: nil)
          options_for_select = find_templates_for_select(component)
          select(:template, :template_id, options_for_select, prompt:, id:)
        end

        def find_templates_for_select(component)
          return [] unless Decidim.module_installed? :templates
          return @templates_for_select if @templates_for_select

          templates = Decidim::Templates::Template.where(
            target: :proposal_answer,
            templatable: component
          ).order(:templatable_id)

          @templates_for_select = templates.map do |template|
            [translated_attribute(template.name), template.id]
          end
        end

        # find the evaluators for the current space.
        def find_evaluators_for_select(participatory_space, current_user)
          evaluator_roles = participatory_space.user_roles(:evaluator).order_by_name
          evaluators = Decidim::User.where(id: evaluator_roles.pluck(:decidim_user_id)).to_a

          filtered_evaluator_roles = evaluator_roles.filter do |role|
            role.decidim_user_id != current_user.id
          end

          filtered_evaluator_roles.map do |role|
            evaluator = evaluators.find { |user| user.id == role.decidim_user_id }

            [evaluator.name, role.id]
          end
        end
      end
    end
  end
end
