#  frozen_string_literal: true

module Decidim
  module Templates
    # A command with all the business logic when duplicating a proposal's answer template
    module Admin
      class CopyProposalAnswerTemplate < Decidim::Command
        def initialize(template)
          @template = template
        end

        def call
          return broadcast(:invalid) unless @template.valid?

          Template.transaction do
            copy_template
          end

          broadcast(:ok, @copied_template)
        end

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
