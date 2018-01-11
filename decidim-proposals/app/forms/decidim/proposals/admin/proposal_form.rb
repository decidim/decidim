# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A form object to be used when admin users want to create a proposal.
      class ProposalForm < Decidim::Form
        mimic :proposal

        attribute :title, String
        attribute :body, String
        attribute :address, String
        attribute :latitude, Float
        attribute :longitude, Float
        attribute :category_id, Integer
        attribute :scope_id, Integer
        attribute :attachment, AttachmentForm

        validates :title, :body, presence: true
        validates :address, geocoding: true, if: -> { current_feature.settings.geocoding_enabled? }
        validates :category, presence: true, if: ->(form) { form.category_id.present? }
        validates :scope, presence: true, if: ->(form) { form.scope_id.present? }
        validate { errors.add(:scope_id, :invalid) if current_participatory_space&.scope && !current_participatory_space&.scope&.ancestor_of?(scope) }

        delegate :categories, to: :current_feature

        def map_model(model)
          return unless model.categorization

          self.category_id = model.categorization.decidim_category_id
        end

        alias feature current_feature

        # Finds the Category from the category_id.
        #
        # Returns a Decidim::Category
        def category
          @category ||= categories.find_by(id: category_id)
        end

        # Finds the Scope from the given decidim_scope_id, uses participatory space scope if missing.
        #
        # Returns a Decidim::Scope
        def scope
          @scope ||= @scope_id ? current_feature.scopes.find_by(id: @scope_id) : current_participatory_space&.scope
        end

        # Scope identifier
        #
        # Returns the scope identifier related to the proposal
        def scope_id
          @scope_id || scope&.id
        end
      end
    end
  end
end
