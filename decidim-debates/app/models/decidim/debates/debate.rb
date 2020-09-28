# frozen_string_literal: true

module Decidim
  module Debates
    # The data store for a Debate in the Decidim::Debates component. It stores a
    # title, description and any other useful information to render a custom
    # debate.
    class Debate < Debates::ApplicationRecord
      include Decidim::HasComponent
      include Decidim::HasCategory
      include Decidim::Resourceable
      include Decidim::Followable
      include Decidim::Comments::Commentable
      include Decidim::ScopableResource
      include Decidim::Authorable
      include Decidim::Reportable
      include Decidim::HasReference
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::DataPortability
      include Decidim::NewsletterParticipant
      include Decidim::Searchable
      include Decidim::Hashtaggable
      include Decidim::TranslatableResource
      include Decidim::TranslatableAttributes
      include Decidim::Endorsable
      include Decidim::Randomable

      belongs_to :last_comment_by, polymorphic: true, foreign_key: "last_comment_by_id", foreign_type: "last_comment_by_type", optional: true
      component_manifest_name "debates"

      validates :title, presence: true

      translatable_fields :title, :description, :instructions, :information_updates
      searchable_fields({
                          participatory_space: { component: :participatory_space },
                          A: :search_title,
                          D: :search_body,
                          datetime: :start_time
                        },
                        index_on_create: ->(debate) { debate.visible? },
                        index_on_update: ->(debate) { debate.visible? })

      scope :open, -> { where(closed_at: nil) }
      scope :closed, -> { where.not(closed_at: nil) }
      scope :authored_by, ->(author) { where(author: author) }
      scope :commented_by, lambda { |author|
        joins(:comments).where(
          decidim_comments_comments:
          {
            decidim_author_id: author.id,
            decidim_author_type: author.class.base_class.name
          }
        )
      }

      def self.log_presenter_class_for(_log)
        Decidim::Debates::AdminLog::DebatePresenter
      end

      # Public: Overrides the `reported_content_url` Reportable concern method.
      def reported_content_url
        ResourceLocatorPresenter.new(self).url
      end

      # Public: Calculates whether the current debate is an AMA-styled one or not.
      # AMA-styled debates are those that have a start and end time set, and comments
      # are only open during that timelapse. AMA stands for Ask Me Anything, a type
      # of debate inspired by Reddit.
      #
      # Returns a Boolean.
      def ama?
        start_time.present? && end_time.present?
      end

      # Public: Checks whether the debate is an AMA-styled one and is open.
      #
      # Returns a boolean.
      def open_ama?
        ama? && Time.current.between?(start_time, end_time)
      end

      # Public: Checks if the debate is open or not.
      #
      # Returns a boolean.
      def open?
        (ama? && open_ama?) || !ama?
      end

      # Public: Overrides the `commentable?` Commentable concern method.
      def commentable?
        component.settings.comments_enabled?
      end

      # Public: Overrides the `accepts_new_comments?` Commentable concern method.
      def accepts_new_comments?
        return false unless open?
        return false if closed?

        commentable? && !comments_blocked?
      end

      # Public: Overrides the `comments_have_alignment?` Commentable concern method.
      def comments_have_alignment?
        true
      end

      # Public: Overrides the `comments_have_votes?` Commentable concern method.
      def comments_have_votes?
        true
      end

      # Public: Identifies the commentable type in the API.
      def commentable_type
        self.class.name
      end

      # Public: Override Commentable concern method `users_to_notify_on_comment_created`
      def users_to_notify_on_comment_created
        return Decidim::User.where(id: followers).or(Decidim::User.where(id: component.participatory_space.admins)).distinct if official?

        followers
      end

      def self.export_serializer
        Decidim::Debates::DataPortabilityDebateSerializer
      end

      # Public: Whether the object can have new comments or not.
      def user_allowed_to_comment?(user)
        can_participate_in_space?(user)
      end

      def self.newsletter_participant_ids(component)
        Decidim::Debates::Debate.where(component: component).joins(:component)
                                .where(decidim_author_type: Decidim::UserBaseEntity.name)
                                .where.not(author: nil)
                                .pluck(:decidim_author_id).flatten.compact.uniq
      end

      # Checks whether the user can edit the debate.
      #
      # user - the user to check for authorship
      def editable_by?(user)
        !closed? && authored_by?(user)
      end

      # Checks whether the debate is closed or not.
      #
      def closed?
        closed_at.present? && conclusions.present?
      end

      # Checks whether the user can edit the debate.
      #
      # user - the user to check for authorship
      def closeable_by?(user)
        authored_by?(user)
      end

      # Public: Updates the comments counter cache. We have to do it these
      # way in order to properly calculate the counter with hidden
      # comments.
      #
      # rubocop:disable Rails/SkipsModelValidations
      def update_comments_count
        comments_count = comments.not_hidden.count
        last_comment = comments.not_hidden.order("created_at DESC").first

        update_columns(
          last_comment_at: last_comment&.created_at,
          last_comment_by_id: last_comment&.decidim_author_id,
          last_comment_by_type: last_comment&.decidim_author_type,
          comments_count: comments_count,
          updated_at: Time.current
        )
      end
      # rubocop:enable Rails/SkipsModelValidations

      private

      def comments_blocked?
        component.current_settings.comments_blocked
      end
    end
  end
end
