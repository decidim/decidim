# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      module ProposalBulkActionsHelper
        def proposal_find(id)
          Decidim::Proposals::Proposal.find(id)
        end

        # Public: Generates a select field with the valuators of the given participatory space.
        #
        # participatory_space - A participatory space instance.
        # prompt - An i18n string to show as prompt
        #
        # Returns a String.
        def bulk_valuators_select(participatory_space, prompt)
          options_for_select = find_valuators_for_select(participatory_space)
          select(:valuator_role, :id, options_for_select, prompt:)
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

        # Internal: A method to cache to queries to find the valuators for the
        # current space.
        def find_valuators_for_select(participatory_space)
          return @valuators_for_select if @valuators_for_select

          valuator_roles = participatory_space.user_roles(:valuator)
          valuators = Decidim::User.where(id: valuator_roles.pluck(:decidim_user_id)).to_a

          @valuators_for_select = valuator_roles.map do |role|
            valuator = valuators.find { |user| user.id == role.decidim_user_id }

            [valuator.name, role.id]
          end
        end

        def find_templates_for_select(component)
          return @templates_for_select if @templates_for_select

          templates = Decidim::Templates::Template.where(
            target: :proposal_answer,
            templatable: component
          ).order(:templatable_id)

          @templates_for_select = templates.map do |template|
            [translated_attribute(template.name), template.id]
          end
        end
      end
    end
  end
end
