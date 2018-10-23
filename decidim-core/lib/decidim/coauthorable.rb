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

      validates :coauthorships, presence: true

      # Overwrite default reload method to unset the instance variables so reloading works as expected.
      def reload(options = nil)
        remove_instance_variable(:@authors) if defined?(@authors)
        remove_instance_variable(:@notifiable_authors) if defined?(@notifiable_authors)
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

      # Returns the authors that should be notified for a coauthorable.
      #
      def notifiable_authors
        @notifiable_authors ||= authors.flat_map do |author|
          if author.is_a?(Decidim::User)
            author
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
        coauthorships.where(author: author).exists?
      end

      # Returns the identities for the authors, whether they are user groups or users.
      #
      # Returns an Array of User and/or UserGroups.
      def identities
        coauthorships.order(:created_at).collect(&:identity)
      end

      # Syntactic sugar to access first coauthor as a Coauthorship.
      def creator
        coauthorships.order(:created_at).first
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
      # use `extra_attrs` either with `user_group` or `decidim_user_group_id` keys.
      #
      # @param author: The new coauthor.
      # @extra_attrs: Extra
      def add_coauthor(author, extra_attrs = {})
        if persisted?
          coauthorships.create!(extra_attrs.merge(author: author))
        else
          coauthorships.build(extra_attrs.merge(author: author))
        end

        authors << author
      end
    end
  end
end
