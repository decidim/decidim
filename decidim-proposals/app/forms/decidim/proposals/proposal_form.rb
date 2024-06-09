# frozen_string_literal: true

module Decidim
  module Proposals
    # A form object to be used when public users want to create a proposal.
    class ProposalForm < Decidim::Form
      include Decidim::TranslatableAttributes
      include Decidim::AttachmentAttributes
      include Decidim::HasUploadValidations

      mimic :proposal

      attribute :title, String
      attribute :body, Decidim::Attributes::CleanString
      attribute :body_template, String
      attribute :user_group_id, Integer
      attribute :address, String
      attribute :latitude, Float
      attribute :longitude, Float
      attribute :category_id, Integer
      attribute :scope_id, Integer
      attribute :attachment, AttachmentForm
      attribute :suggested_hashtags, Array[String]

      attachments_attribute :documents

      validates :title, :body, presence: true, etiquette: true
      validates :title, length: { in: 15..150 }
      validates :body, proposal_length: {
        minimum: 15,
        maximum: ->(record) { record.component.settings.proposal_length }
      }
      validates :address, geocoding: true, if: ->(form) { form.has_address? && !form.geocoded? }
      validates :category, presence: true, if: ->(form) { form.category_id.present? }
      validates :scope, presence: true, if: ->(form) { form.scope_id.present? }
      validates :scope_id, scope_belongs_to_component: true, if: ->(form) { form.scope_id.present? }

      validate :body_is_not_bare_template
      validate :notify_missing_attachment_if_errored

      alias component current_component
      delegate :categories, to: :current_component

      def map_model(model)
        self.title = translated_attribute(model.title)
        self.body = translated_attribute(model.body)
        @suggested_hashtags = Decidim::ContentRenderers::HashtagRenderer.new(body).extra_hashtags.map(&:name).map(&:downcase)

        presenter = ProposalPresenter.new(model)
        self.body = presenter.editor_body(all_locales: body.is_a?(Hash))

        self.user_group_id = model.user_groups.first&.id
        self.category_id = model.categorization.decidim_category_id if model.categorization

        # The scope attribute is with different key (decidim_scope_id), so it
        # has to be manually mapped.
        self.scope_id = model.scope.id if model.scope

        self.documents = model.attachments
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

      def has_address?
        geocoding_enabled? && address.present?
      end

      def geocoded?
        latitude.present? && longitude.present?
      end

      def extra_hashtags
        @extra_hashtags ||= (component_automatic_hashtags + suggested_hashtags).uniq
      end

      def suggested_hashtags
        downcased_suggested_hashtags = super.to_set(&:downcase)
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

      def body_is_not_bare_template
        return if body_template.blank?

        errors.add(:body, :cant_be_equal_to_template) if body.presence == body_template.presence
      end

      # This method will add an error to the "add_documents" field only if there is any error
      # in any other field. This is needed because when the form has an error, the attachment
      # is lost, so we need a way to inform the user of this problem.
      def notify_missing_attachment_if_errored
        errors.add(:add_documents, :needs_to_be_reattached) if errors.any? && add_documents.present?
      end

      def ordered_hashtag_list(string)
        string.to_s.split.compact_blank.uniq.sort_by(&:parameterize)
      end
    end
  end
end
