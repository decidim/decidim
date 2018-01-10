# frozen_string_literal: true

module Decidim
  module Proposals
    # Simple helpers to handle markup variations for proposal wizard partials
    module ProposalWizardHelper
      # Returns the css classes used for proposal votes count in both proposals list and show pages
      #
      # from_proposals_list - A boolean to indicate if the template is rendered from the proposals list page
      #
      # Returns a hash with the css classes for the count number and label
      def step_classes(step, current_step)
        step_i = step.to_s.split("_").last.to_i
        current_step_i = current_step.to_s.split("_").last.to_i
        if step_i <= current_step_i
          %(phase-item--past #{step} #{current_step})
        else
          %()
        end
      end

      def proposal_wizard_stepper_step(step, current_step)
        html = %(<li class="#{step_classes(step, current_step)}">)
        html += %(<span></span>)
        html += %(<div class="caption">#{t(".#{step}")}</div>)
        html += %(</li>)
        html
      end

      def proposal_wizard_stepper(current_step)
        content_tag :ol do
          %(
            #{proposal_wizard_stepper_step(:step_1, current_step)}
            #{proposal_wizard_stepper_step(:step_2, current_step)}
            #{proposal_wizard_stepper_step(:step_3, current_step)}
            #{proposal_wizard_stepper_step(:step_4, current_step)}
          ).html_safe
        end
      end

      def proposal_wizard_actions(form)
        case @step
        when :step_1
          form.submit t("decidim.proposals.proposal_wizard.actions.go_to_step_2"), class: "button expanded"
        when :step_2
          actions = link_to t("decidim.proposals.proposal_wizard.actions.exit_wizard"), proposal_wizard_exit_path, class: "button clear"
          actions += form.submit t("decidim.proposals.proposal_wizard.actions.go_to_step_3"), class: "button expanded"
          actions
        when :step_3
          form.submit t("decidim.proposals.proposal_wizard.actions.go_to_step_4"), class: "button expanded"
        when :step_4
          actions = link_to t("decidim.proposals.proposal_wizard.actions.go_back_to_step_3"), wizard_path(:step_3, proposal_draft: form.id), class: "button clear"
          actions += link_to t("decidim.proposals.proposal_wizard.actions.go_to_finish"), wizard_path(:step_publish), class: "button expanded"
          actions
        else
          form.submit t("decidim.proposals.proposal_wizard.actions.go_to_next_step"), class: "button expanded"
        end
      end

      def proposal_wizard_author(user_group_id)
        if user_group_id.present? && current_user.user_groups.verified.where(id: user_group_id)
          Decidim::UserGroup.find user_group_id
        else
          current_user
        end
      end

      def proposal_wizard_user_group_verified?(user_group_id)
        if user_group_id.present? && current_user.user_groups.verified.where(id: user_group_id)
          true
        else
          false
        end
      end

      def proposal_wizard_author_avatar_url(user_group_id)
        proposal_wizard_author(user_group_id).avatar_url
      end

      def proposal_wizard_author_name(user_group_id)
        proposal_wizard_author(user_group_id).name
      end

      def proposal_wizard_feature(feature_id)
        Decidim::Feature.find feature_id
      end

      def proposal_preview_category(category_id)
        Decidim::Category.find category_id if category_id.present?
      end

      def proposal_preview_category_name(category_id)
        proposal_preview_category(category_id).name if category_id.present?
      end
    end
  end
end
