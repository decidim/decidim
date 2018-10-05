# frozen_string_literal: true

module Decidim
  module Proposals
    # A form object to be used when public users want to create a proposal.
    class ProposalForm < Decidim::Form
      mimic :proposal

      include Decidim::Proposals::Concerns::FormattedAttributes

      attribute :title, String
      attribute :body, String
      attribute :address, String
      attribute :latitude, Float
      attribute :longitude, Float
      attribute :category_id, Integer
      attribute :scope_id, Integer
      attribute :user_group_id, Integer
      attribute :has_address, Boolean
      attribute :attachment, AttachmentForm
      validates :title, :body, presence: true, etiquette: true
      validates :title, length: { maximum: 150 }
      validates :address, geocoding: true, if: :geocodable
      validates :address, presence: true, if: ->(form) { form.has_address? }
      validates :category, presence: true, if: ->(form) { form.category_id.present? }
      validates :scope, presence: true, if: ->(form) { form.scope_id.present? }
      validate :proposal_length
      validate :scope_belongs_to_participatory_space_scope

      validate :notify_missing_attachment_if_errored

      delegate :categories, to: :current_component

      def geocodable
        Decidim.geocoder.present? && self.has_address? && address_has_changed?
      end

      def address_has_changed?
        return true if id.nil?
        address != Proposal.find(id).address unless id.nil?
      end

      def map_model(model)
        self.user_group_id = model.decidim_user_group_id
        return unless model.categorization

        self.category_id = model.categorization.decidim_category_id
      end

      alias component current_component
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
        @scope ||= @scope_id ? current_participatory_space.scopes.find_by(id: @scope_id) : current_participatory_space.scope
      end

      # Scope identifier
      #
      # Returns the scope identifier related to the proposal
      def scope_id
        @scope_id || scope&.id
      end

      def has_address?
        current_component.settings.geocoding_enabled? && has_address
      end

      private

      def proposal_length
        return unless body.presence
        length = current_component.settings.proposal_length
        errors.add(:body, :too_long, count: length) if body.length > length
      end

      def scope_belongs_to_participatory_space_scope
        errors.add(:scope_id, :invalid) if current_participatory_space.out_of_scope?(scope)
      end

      # This method will add an error to the `attachment` field only if there's
      # any error in any other field. This is needed because when the form has
      # an error, the attachment is lost, so we need a way to inform the user of
      # this problem.
      def notify_missing_attachment_if_errored
        errors.add(:attachment, :needs_to_be_reattached) if errors.any? && attachment.present?
      end
    end
  end
end
