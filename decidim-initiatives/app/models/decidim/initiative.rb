# frozen_string_literal: true

module Decidim
  # The data store for a Initiative in the Decidim::Initiatives component.
  class Initiative < ApplicationRecord
    include ActiveModel::Dirty
    include Decidim::Authorable
    include Decidim::Participable
    include Decidim::Publicable
    include Decidim::Scopable
    include Decidim::Comments::Commentable
    include Decidim::Followable
    include Decidim::HasAttachments
    include Decidim::HasAttachmentCollections
    include Decidim::Traceable
    include Decidim::Loggable
    include Decidim::Initiatives::InitiativeSlug
    include Decidim::Resourceable

    belongs_to :organization,
               foreign_key: "decidim_organization_id",
               class_name: "Decidim::Organization"

    belongs_to :scoped_type,
               foreign_key: "scoped_type_id",
               class_name: "Decidim::InitiativesTypeScope",
               inverse_of: :initiatives

    delegate :type, to: :scoped_type, allow_nil: true
    delegate :scope, to: :scoped_type, allow_nil: true

    has_many :votes,
             foreign_key: "decidim_initiative_id",
             class_name: "Decidim::InitiativesVote",
             dependent: :destroy,
             inverse_of: :initiative

    has_many :committee_members,
             foreign_key: "decidim_initiatives_id",
             class_name: "Decidim::InitiativesCommitteeMember",
             dependent: :destroy,
             inverse_of: :initiative

    has_many :components, as: :participatory_space, dependent: :destroy

    # This relationship exists only by compatibility reasons.
    # Initiatives are not intended to have categories.
    has_many :categories,
             foreign_key: "decidim_participatory_space_id",
             foreign_type: "decidim_participatory_space_type",
             dependent: :destroy,
             as: :participatory_space

    enum signature_type: [:online, :offline, :any]
    enum state: [:created, :validating, :discarded, :published, :rejected, :accepted]

    validates :title, :description, :state, presence: true
    validates :signature_type, presence: true
    validates :hashtag,
              uniqueness: true,
              allow_blank: true,
              case_sensitive: false

    scope :open, lambda {
      published
        .where.not(state: [:discarded, :rejected, :accepted])
        .where("signature_start_date <= ?", Date.current)
        .where("signature_end_date >= ?", Date.current)
    }
    scope :closed, lambda {
      published
        .where(state: [:discarded, :rejected, :accepted])
        .or(where("signature_start_date > ?", Date.current))
        .or(where("signature_end_date < ?", Date.current))
    }
    scope :published, -> { where.not(published_at: nil) }
    scope :with_state, ->(state) { where(state: state) if state.present? }

    scope :public_spaces, -> { published }

    scope :order_by_most_recent, -> { order(created_at: :desc) }
    scope :order_by_supports, -> { order(Arel.sql("initiative_votes_count + coalesce(offline_votes, 0) desc")) }
    scope :order_by_most_commented, lambda {
      select("decidim_initiatives.*")
        .left_joins(:comments)
        .group("decidim_initiatives.id")
        .order(Arel.sql("count(decidim_comments_comments.id) desc"))
    }

    after_save :notify_state_change
    after_create :notify_creation

    def self.order_randomly(seed)
      transaction do
        connection.execute("SELECT setseed(#{connection.quote(seed)})")
        select('"decidim_initiatives".*, RANDOM()').order(Arel.sql("RANDOM()")).load
      end
    end

    def self.log_presenter_class_for(_log)
      Decidim::Initiatives::AdminLog::InitiativePresenter
    end

    # PUBLIC
    #
    # Returns true when an initiative has been created by an individual person.
    # False in case it has been created by an authorized organization.
    #
    # RETURN boolean
    def created_by_individual?
      decidim_user_group_id.nil?
    end

    # PUBLIC
    #
    # RETURN boolean TRUE when the initiative is open, false in case its
    # not closed.
    def open?
      !closed?
    end

    # PUBLIC
    #
    # Returns when an initiative is closed. An initiative is closed when
    # at least one of the following conditions is true:
    #
    # * It has been discarded.
    # * It has been rejected.
    # * It has been accepted.
    # * Signature collection period has finished.
    #
    # RETURNS BOOLEAN
    def closed?
      discarded? || rejected? || accepted? || !votes_enabled?
    end

    # PUBLIC
    #
    # Returns the author name. If it has been created by an organization it will
    # return the organization's name. Otherwise it will return author's name.
    #
    # RETURN string
    def author_name
      user_group&.name || author.name
    end

    # PUBLIC author_avatar_url
    #
    # Returns the author's avatar URL. In case it is not defined the method
    # falls back to decidim/default-avatar.svg
    #
    # RETURNS STRING
    def author_avatar_url
      author.avatar&.url ||
        ActionController::Base.helpers.asset_path("decidim/default-avatar.svg")
    end

    # PUBLIC banner image
    #
    # Overrides participatory space's banner image with the banner image defined
    # for the initiative type.
    #
    # RETURNS string
    delegate :banner_image, to: :type

    def votes_enabled?
      published? &&
        signature_start_date <= Date.current &&
        signature_end_date >= Date.current
    end

    # Public: Checks if the organization has given an answer for the initiative.
    #
    # Returns Boolean.
    def answered?
      answered_at.present?
    end

    # Public: Overrides scopes enabled flag available in other models like
    # participatory space or assemblies. For initiatives it won't be directly
    # managed by the user and it will be enabled by default.
    def scopes_enabled?
      true
    end

    # Public: Overrides scopes enabled attribute value.
    # For initiatives it won't be directly
    # managed by the user and it will be enabled by default.
    def scopes_enabled
      true
    end

    # Public: Publishes this initiative
    #
    # Returns true if the record was properly saved, false otherwise.
    def publish!
      return false if published?
      update(
        published_at: Time.current,
        state: "published",
        signature_start_date: Date.current,
        signature_end_date: Date.current + Decidim::Initiatives.default_signature_time_period_length
      )
    end

    #
    # Public: Unpublishes this initiative
    #
    # Returns true if the record was properly saved, false otherwise.
    def unpublish!
      return false unless published?
      update(published_at: nil, state: "discarded")
    end

    # Public: Returns wether the signature interval is already defined or not.
    def has_signature_interval_defined?
      signature_end_date.present? && signature_start_date.present?
    end

    # Public: Returns the hashtag for the initiative.
    def hashtag
      attributes["hashtag"].to_s.delete("#")
    end

    def supports_count
      face_to_face_votes = offline_votes.nil? || online? ? 0 : offline_votes
      digital_votes = offline? ? 0 : (initiative_votes_count + initiative_supports_count)
      digital_votes + face_to_face_votes
    end

    # Public: Returns the percentage of required supports reached
    def percentage
      percentage = supports_count * 100 / scoped_type.supports_required
      percentage = 100 if percentage > 100
      percentage
    end

    # Public: Overrides slug attribute from participatory processes.
    def slug
      slug_from_id(id)
    end

    def to_param
      slug
    end

    # Public: Overrides the `comments_have_alignment?`
    # Commentable concern method.
    def comments_have_alignment?
      true
    end

    # Public: Overrides the `comments_have_votes?` Commentable concern method.
    def comments_have_votes?
      true
    end

    # PUBLIC
    #
    # Checks if user is the author or is part of the promotal committee
    # of the initiative.
    #
    # RETURNS boolean
    def has_authorship?(user)
      return true if author.id == user.id
      committee_members.approved.where(decidim_users_id: user.id).any?
    end

    def accepts_offline_votes?
      Decidim::Initiatives.face_to_face_voting_allowed &&
        (offline? || any?) &&
        published?
    end

    private

    def notify_state_change
      return unless saved_change_to_state?
      notifier = Decidim::Initiatives::StatusChangeNotifier.new(initiative: self)
      notifier.notify
    end

    def notify_creation
      notifier = Decidim::Initiatives::StatusChangeNotifier.new(initiative: self)
      notifier.notify
    end
  end
end
