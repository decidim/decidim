#  frozen_string_literal: true

module Decidim
  module Templates
    # A command with all the business logic when duplicating a proposal's answer template
    module Admin
      class CopyProposalAnswerTemplate < CopyTemplate
        def copy_template
          @copied_template = Template.create!(
            organization: @template.organization,
            name: @template.name,
            description: @template.description,
            target: :proposal_answer,
            field_values: @template.field_values,
            templatable: @template.templatable
          )
        end
      end
    end
  end
end
