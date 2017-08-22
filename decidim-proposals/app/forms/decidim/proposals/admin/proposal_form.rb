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

        delegate :categories, to: :current_feature, prefix: false

        def map_model(model)
          return unless model.categorization

          self.category_id = model.categorization.decidim_category_id
        end

        def organization_scopes
          current_organization.scopes
        end

        def process_scope
          current_feature.participatory_space.scope
        end

        alias feature current_feature

        # Finds the Category from the category_id.
        #
        # Returns a Decidim::Category
        def category
          @category ||= categories.where(id: category_id).first
        end

        # Finds the Scope from the scope_id.
        #
        # Returns a Decidim::Scope
        def scope
          @scope ||= organization_scopes.where(id: scope_id).first || process_scope
        end
      end
    end
  end
end
