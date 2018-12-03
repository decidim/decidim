# frozen_string_literal: true

module Decidim
  module Proposals
    # A form object to be used when public users want to create a proposal.
    class ProposalForm < Decidim::Proposals::ProposalWizardCreateStepForm
      mimic :proposal

      attribute :address, String
      attribute :latitude, Float
      attribute :longitude, Float
      attribute :category_id, Integer
      attribute :scope_id, Integer
      attribute :has_address, Boolean
      attribute :attachment, AttachmentForm
      attribute :hashtags_suggested, Array[String]

      validates :address, geocoding: true, if: ->(form) { Decidim.geocoder.present? && form.has_address? }
      validates :address, presence: true, if: ->(form) { form.has_address? }
      validates :category, presence: true, if: ->(form) { form.category_id.present? }
      validates :scope, presence: true, if: ->(form) { form.scope_id.present? }

      validate :scope_belongs_to_participatory_space_scope

      validate :notify_missing_attachment_if_errored

      delegate :categories, to: :current_component

      def map_model(model)
        super

        @hashtags_suggested = Decidim::ContentRenderers::HashtagRenderer.new(model.body).extra_hashtags.map(&:name).map(&:downcase)
      end

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

      def extra_hashtags_content
        @extra_hashtags_content ||= extra_hashtags.map { |hashtag| "##{hashtag}" }.join(" ")
      end

      def extra_hashtags
        @extra_hashtags ||= (component_hashtags_auto + hashtags_suggested).uniq
      end

      def hashtags_suggested
        downcased_hashtags_suggested = @hashtags_suggested.map(&:downcase).to_set
        component_hashtags_suggested.select { |hashtag| downcased_hashtags_suggested.member?(hashtag.downcase) }
      end

      def hashtag_suggested_checked?(hashtag)
        @hashtags_suggested.member?(hashtag)
      end

      def component_hashtags_auto
        @component_hashtags_auto ||= ordered_hashtag_list(current_component.current_settings.hashtags_auto)
      end

      def component_hashtags_suggested
        @component_hashtags_suggested ||= ordered_hashtag_list(current_component.current_settings.hashtags_suggested)
      end

      private

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

      def ordered_hashtag_list(string)
        return [] unless string

        string.split.reject(&:blank?).uniq.sort_by(&:parameterize)
      end
    end
  end
end
