# frozen_string_literal: true

module Decidim
  module Proposals
    # A form object used to collect the title and description for an proposal.
    class ProposalWizardForm < Decidim::Proposals::ProposalForm
      clear_validators!

      # attribute :id, String # proposal wizard step id (iherited from wicked)
      # attr_accessor :form_step
      # mimic :proposal
      #
      # attribute :title, String
      # attribute :body, String
      # attribute :category_id, Integer
      # attribute :scope_id, Integer
      # attribute :user_group_id, Integer

      # validates :title, :body, presence: true, etiquette: true, if: :required_for_step_2?
      # validates :title, length: { maximum: 150 }, if: :required_for_step_2?
      # validates :body, length: { maximum: 500 }, etiquette: true, if: :required_for_step_2?
      # validates :address, geocoding: true, if: ->(form) { Decidim.geocoder.present? && form.has_address? } #, if: :step_3?
      # validates :address, presence: true, if: ->(form) { form.has_address? } #, if: :step_3?
      # validates :category, presence: true, if: ->(form) { form.category_id.present? } #, if: :step_3?
      # validates :scope, presence: true, if: ->(form) { form.scope_id.present? } #, if: :step_3?

      # delegate :categories, to: :current_feature

      # def step_1?
      #   id == 'step_1'
      # end
      #
      # def step_2?
      #   id == 'step_2'
      # end
      #
      # def step_3?
      #   id == 'step_3'
      # end

      def required_for_step_2?
        case id
        when "step_1"
          false
        else
          true
        end
        # All fields are required if no form step is present
        # return true if form_step.nil?

        # All fields from previous steps are required if the
        # step parameter appears before or we are on the current step
        # return true if self.id.index(step.to_s) <= self.id.index(form_step)
        # raise
      end
    end
  end
end
