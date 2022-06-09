# frozen_string_literal: true

module Decidim
  module Proposals
    # A form object to be used when public users want to create a proposal.
    class ProposalForm < Decidim::Proposals::ProposalWizardCreateStepForm
      include Decidim::TranslatableAttributes
      include Decidim::AttachmentAttributes
      include Decidim::HasUploadValidations

      mimic :proposal

      attribute :address, String
      attribute :latitude, Float
      attribute :longitude, Float
      attribute :category_id, Integer
      attribute :scope_id, Integer
      attribute :has_address, Boolean
      attribute :attachment, AttachmentForm
      attribute :suggested_hashtags, Array[String]

      attachments_attribute :photos
      attachments_attribute :documents

      validates :address, geocoding: true, if: ->(form) { form.has_address? && !form.geocoded? }
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

        self.has_address = true if model.address.present?

        # Proposals have the "photos" field reserved for the proposal card image
        # so we don't want to show all photos there. Instead, only show the
        # first photo.
        self.photos = [model.photo].compact.select { |p| p.weight.zero? }
        self.documents = model.attachments - photos
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
        @scope ||= @attributes["scope_id"].value ? current_component.scopes.find_by(id: @attributes["scope_id"].value) : current_component.scope
      end

      # Scope identifier
      #
      # Returns the scope identifier related to the proposal
      def scope_id
        super || scope&.id
      end

      def geocoding_enabled?
        Decidim::Map.available?(:geocoding) && current_component.settings.geocoding_enabled?
      end

      def address
        return unless has_address

        super
      end

      def has_address?
        return unless has_address

        geocoding_enabled? && address.present?
      end

      def geocoded?
        latitude.present? && longitude.present?
      end

      def extra_hashtags
        @extra_hashtags ||= (component_automatic_hashtags + suggested_hashtags).uniq
      end

      def suggested_hashtags
        downcased_suggested_hashtags = super.map(&:downcase).to_set
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

      # This method will add an error to the `add_photos` and/or "add_documents" fields
      # only if there's any error in any other field. This is needed because when the
      # form has an error, the attachment is lost, so we need a way to inform the user of
      # this problem.
      def notify_missing_attachment_if_errored
        if errors.any?
          errors.add(:add_photos, :needs_to_be_reattached) if add_photos.present?
          errors.add(:add_documents, :needs_to_be_reattached) if add_documents.present?
        end
      end

      def ordered_hashtag_list(string)
        string.to_s.split.compact_blank.uniq.sort_by(&:parameterize)
      end
    end
  end
end
