# frozen_string_literal: true

module Decidim
  module DummyResources
    class DummyResource < ApplicationRecord
      include HasComponent
      include HasReference
      include Resourceable
      include Reportable
      include Authorable
      include HasCategory
      include ScopableResource
      include Decidim::Comments::Commentable
      include Followable
      include Traceable
      include Publicable
      include Decidim::DownloadYourData
      include Searchable
      include Paddable
      include Amendable
      include Decidim::NewsletterParticipant
      include ::Decidim::Endorsable
      include Decidim::HasAttachments
      include Decidim::ShareableWithToken
      include Decidim::TranslatableResource

      translatable_fields :title
      searchable_fields(
        scope_id: { scope: :id },
        participatory_space: { component: :participatory_space },
        A: [:title],
        D: [:address],
        datetime: :published_at
      )

      amendable(
        fields: [:title],
        form: "Decidim::DummyResources::DummyResourceForm"
      )

      component_manifest_name "dummy"

      def reported_content_url
        ResourceLocatorPresenter.new(self).url
      end

      def reported_attributes
        [:title]
      end

      def reported_searchable_content_extras
        [normalized_author.name]
      end

      def allow_resource_permissions?
        component.settings.resources_permissions_enabled
      end

      # Public: Overrides the `commentable?` Commentable concern method.
      def commentable?
        component.settings.comments_enabled?
      end

      # Public: Whether the object can have new comments or not.
      def user_allowed_to_comment?(user)
        component.can_participate_in_space?(user)
      end

      # Public: Whether the object can have new comment votes or not.
      def user_allowed_to_vote_comment?(user)
        component.can_participate_in_space?(user)
      end

      def self.user_collection(user)
        where(decidim_author_id: user.id, decidim_author_type: "Decidim::User")
      end

      def self.export_serializer
        DummySerializer
      end

      def self.newsletter_participant_ids(component)
        authors_ids = Decidim::DummyResources::DummyResource.where(component:)
                                                            .where(decidim_author_type: Decidim::UserBaseEntity.name)
                                                            .where.not(author: nil)
                                                            .group(:decidim_author_id)
                                                            .pluck(:decidim_author_id)
        commentators_ids = Decidim::Comments::Comment.user_commentators_ids_in(Decidim::DummyResources::DummyResource.where(component:))
        (authors_ids + commentators_ids).flatten.compact.uniq
      end
    end
  end
end
