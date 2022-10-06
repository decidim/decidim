# frozen_string_literal: true

module Decidim
  # This concern contains the logic related to collective or shared authorship.
  #
  # Coauthorable shares nearly the same object interface as Authorable but with some differences.
  # - `authored_by?(user)` is exactly the same
  # - `normalized_author` is now `identities`.
  #
  # All coauthors, including the initial author, will share the same permissions.
  module Coauthorable
    extend ActiveSupport::Concern

    included do
      has_many :coauthorships, -> { order(:created_at) }, as: :coauthorable, class_name: "Decidim::Coauthorship", dependent: :destroy, inverse_of: :coauthorable
      has_many :user_groups, -> { order(:created_at) }, as: :coauthorable, class_name: "Decidim::UserGroup", through: :coauthorships

      # retrieves models from all identities of the author.
      scope :from_all_author_identities, lambda { |author|
        joins(:coauthorships).where("decidim_coauthorships.decidim_author_id = ? AND decidim_coauthorships.decidim_author_type = ?", author.id, author.class.base_class.name)
      }
      # retrieves models from the given author, ignoring the UserGroups it belongs to.
      scope :from_author, ->(author) { from_all_author_identities(author).where("decidim_coauthorships.decidim_user_group_id": nil) }
      # retrieves models from the given UserGroup.
      scope :from_user_group, ->(user_group) { joins(:coauthorships).where("decidim_coauthorships.decidim_user_group_id": user_group.id) }
      scope :with_official_origin, lambda {
        where.not(coauthorships_count: 0)
             .joins(:coauthorships)
             .where(decidim_coauthorships: { decidim_author_type: "Decidim::Organization" })
      }
      scope :with_participants_origin, lambda {
        where.not(coauthorships_count: 0)
             .joins(:coauthorships)
             .where.not(decidim_coauthorships: { decidim_author_type: "Decidim::Organization" })
             .where(decidim_coauthorships: { decidim_user_group_id: nil })
      }
      scope :with_user_group_origin, lambda {
        where.not(coauthorships_count: 0)
             .joins(:coauthorships)
             .where(decidim_coauthorships: { decidim_author_type: "Decidim::UserBaseEntity" })
             .where.not(decidim_coauthorships: { decidim_user_group_id: nil })
      }
      scope :with_meeting_origin, lambda {
        where.not(coauthorships_count: 0)
             .joins(:coauthorships)
             .where(decidim_coauthorships: { decidim_author_type: "Decidim::Meetings::Meeting" })
      }

      scope :with_any_origin, lambda { |*origin_keys|
        search_values = origin_keys.compact.compact_blank

        conditions = [:official, :participants, :user_group, :meeting].map do |key|
          search_values.member?(key.to_s) ? try("with_#{key}_origin") : nil
        end.compact
        return self unless conditions.any?

        scoped_query = where(id: conditions.shift)
        conditions.each do |condition|
          scoped_query = scoped_query.or(where(id: condition))
        end

        scoped_query
      }

      scope :coauthored_by, ->(author) { where.not(coauthorships_count: 0).from_all_author_identities(author) }

      validates :coauthorships, presence: true

      # Overwrite default reload method to unset the instance variables so reloading works as expected.
      def reload(options = nil)
        remove_instance_variable(:@authors) if defined?(@authors)
        remove_instance_variable(:@notifiable_identities) if defined?(@notifiable_identities)
        super(options)
      end

      # Returns all the authors of a coauthorable.
      #
      # We need to do it this ways since the authors are polymorphic, and we can't have a has_many through relation
      # with polymorphic objects.
      def authors
        return @authors if defined?(@authors)

        authors = coauthorships.pluck(:decidim_author_id, :decidim_author_type).each_with_object({}) do |(id, klass), all|
          all[klass] ||= []
          all[klass] << id
        end

        @authors = authors.flat_map do |klass, ids|
          klass.constantize.where(id: ids)
        end.compact.uniq
      end

      # Returns the identities that should be notified for a coauthorable.
      #
      def notifiable_identities
        @notifiable_identities ||= identities.flat_map do |identity|
          if identity.is_a?(Decidim::User)
            identity
          elsif identity.is_a?(Decidim::UserGroup)
            identity.managers
          elsif respond_to?(:component)
            component.participatory_space.admins
          end
        end.compact.uniq
      end

      # Checks whether the user is author of the given proposal, either directly
      # authoring it or via a user group.
      #
      # author - the author to check for authorship
      def authored_by?(author)
        coauthorships.exists?(author:)
      end

      # Returns the identities for the authors, whether they are user groups, users or others.
      #
      # Returns an Array of User, UserGroups or any other entity capable object (such as Organization).
      def identities
        coauthorships.includes(:author, :user_group).order(:created_at).collect(&:identity)
      end

      # Returns the identities for the authors, only if they are user groups or users.
      #
      # Returns an Array of User and/or UserGroups.
      def user_identities
        coauthorships.where(decidim_author_type: "Decidim::UserBaseEntity").order(:created_at).collect(&:identity)
      end

      # Syntactic sugar to access first coauthor as a Coauthorship.
      def creator
        coauthorships.order(:created_at).first
      end

      # Checks whether the user is the creator of the given proposal
      #
      # author - the author to check for authorship
      def created_by?(author)
        author == creator_author
      end

      # Syntactic sugar to access first coauthor Author
      def creator_author
        creator.try(:author)
      end

      # Syntactic sugar to access first identity whether it is a User or a UserGroup.
      # @return The User od UserGroup that created this Coauthorable.
      def creator_identity
        creator.try(:identity)
      end

      # Adds a new coauthor to the list of coauthors. The coauthorship is created with
      # current object as coauthorable and `user` param as author. To set the user group
      # use `extra_attributes` with the `user_group` key.
      #
      # @param author: The new coauthor.
      # @extra_attrs: Extra
      def add_coauthor(author, extra_attributes = {})
        user_group = extra_attributes[:user_group]

        return if coauthorships.exists?(decidim_author_id: author.id, decidim_author_type: author.class.base_class.name) && user_group.blank?
        return if user_group && coauthorships.exists?(user_group:)

        coauthorship_attributes = extra_attributes.merge(author:)

        if persisted?
          coauthorships.create!(coauthorship_attributes)
        else
          coauthorships.build(coauthorship_attributes)
        end

        authors << author
      end
    end
  end
end
