# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # A form object to be used when admin users want to create a proposal.
      class ProposalBaseForm < Decidim::Form
        include Decidim::TranslatableAttributes
        include Decidim::AttachmentAttributes
        include Decidim::ApplicationHelper
        include Decidim::HasTaxonomyFormAttributes

        mimic :proposal

        attribute :address, String
        attribute :latitude, Float
        attribute :longitude, Float
        attribute :attachment, AttachmentForm
        attribute :position, Integer
        attribute :created_in_meeting, Boolean
        attribute :meeting_id, Integer
        attribute :suggested_hashtags, Array[String]

        attachments_attribute :photos

        validates :address, geocoding: true, if: ->(form) { form.has_address? && !form.geocoded? }
        validates :meeting_as_author, presence: true, if: ->(form) { form.created_in_meeting? }

        validate :notify_missing_attachment_if_errored

        def map_model(model)
          body = translated_attribute(model.body)
          @suggested_hashtags = Decidim::ContentRenderers::HashtagRenderer.new(body).extra_hashtags.map(&:name).map(&:downcase)
        end

        alias component current_component

        def participatory_space_manifest
          @participatory_space_manifest ||= current_component.participatory_space.manifest.name
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

        # Finds the Meetings of the current participatory space
        def meetings
          @meetings ||= Decidim.find_resource_manifest(:meetings).try(:resource_scope, current_component)
                          &.published&.order(title: :asc)
        end

        # Return the meeting as author
        def meeting_as_author
          @meeting_as_author ||= meetings.find_by(id: meeting_id)
        end

        def author
          return current_organization unless created_in_meeting?

          meeting_as_author
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

        # This method will add an error to the `attachment` field only if there is
        # any error in any other field. This is needed because when the form has
        # an error, the attachment is lost, so we need a way to inform the user of
        # this problem.
        def notify_missing_attachment_if_errored
          errors.add(:attachment, :needs_to_be_reattached) if errors.any? && attachment.present?
          errors.add(:add_photos, :needs_to_be_reattached) if errors.any? && add_photos.present?
        end

        def ordered_hashtag_list(string)
          string.to_s.split.compact_blank.uniq.sort_by(&:parameterize)
        end
      end
    end
  end
end
