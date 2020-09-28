# frozen_string_literal: true

module Decidim
  module Proposals
    # A form object to be used when public users want to create a proposal.
    class ProposalForm < Decidim::Proposals::ProposalWizardCreateStepForm
      include Decidim::TranslatableAttributes

      mimic :proposal

      attribute :address, String
      attribute :latitude, Float
      attribute :longitude, Float
      attribute :category_id, Integer
      attribute :scope_id, Integer
      attribute :has_address, Boolean
      attribute :attachment, AttachmentForm
      attribute :suggested_hashtags, Array[String]

      validates :address, geocoding: true, if: ->(form) { Decidim.geocoder.present? && form.has_address? }
      validates :address, presence: true, if: ->(form) { form.has_address? }
      validates :category, presence: true, if: ->(form) { form.category_id.present? }
      validates :scope, presence: true, if: ->(form) { form.scope_id.present? }
      validates :scope_id, scope_belongs_to_component: true, if: ->(form) { form.scope_id.present? }
      validate :notify_missing_attachment_if_errored

      delegate :categories, to: :current_component

      def map_model(model)
        super

        body = translated_attribute(model.body)
        @suggested_hashtags = Decidim::ContentRenderers::HashtagRenderer.new(body).extra_hashtags.map(&:name).map(&:downcase)

        # The scope attribute is with different key (decidim_scope_id), so it
        # has to be manually mapped.
        self.scope_id = model.scope.id if model.scope
      end

      # Finds the Category from the category_id.
      #
      # Returns a Decidim::Category
      def category
        @category ||= categories.find_by(id: category_id)
      end

      # Finds the Scope from the given scope_id, uses participatory space scope if missing.
      #
      # Returns a Decidim::Scope
      def scope
        @scope ||= @scope_id ? current_component.scopes.find_by(id: @scope_id) : current_component.scope
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

      def extra_hashtags
        @extra_hashtags ||= (component_automatic_hashtags + suggested_hashtags).uniq
      end

      def suggested_hashtags
        downcased_suggested_hashtags = Array(@suggested_hashtags&.map(&:downcase)).to_set
        component_suggested_hashtags.select { |hashtag| downcased_suggested_hashtags.member?(hashtag.downcase) }
      end

      def suggested_hashtag_checked?(hashtag)
        suggested_hashtags.member?(hashtag)
      end

      def component_automatic_hashtags
        @component_automatic_hashtags ||= ordered_hashtag_list(current_component.current_settings.automatic_hashtags)
      end

      def component_suggested_hashtags
        @component_suggested_hashtags ||= ordered_hashtag_list(current_component.current_settings.suggested_hashtags)
      end

      private

      # This method will add an error to the `attachment` field only if there's
      # any error in any other field. This is needed because when the form has
      # an error, the attachment is lost, so we need a way to inform the user of
      # this problem.
      def notify_missing_attachment_if_errored
        errors.add(:attachment, :needs_to_be_reattached) if errors.any? && attachment.present?
      end

      def ordered_hashtag_list(string)
        string.to_s.split.reject(&:blank?).uniq.sort_by(&:parameterize)
      end
    end
  end
end
