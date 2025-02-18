# frozen_string_literal: true

module Decidim
  # This query finds the public ActionLog entries that can be shown in the
  # participant views of the application within a Decidim Organization. It is
  # intended to be used in the user profile, to retrieve activity and timeline
  # for that user.
  #
  # This will create the base query for the activities but the resulting query
  # needs to be scoped with either `with_resource_type` or
  # `with_new_resource_type` in order to avoid leaking private data.
  #
  # Possible options:
  #
  # :resource_name - an optional name for a resource for searching only that
  #    type of resources.
  # :user - an optional `Decidim::User` that performed the activities
  # :current_user - an optional `Decidim::User` for defining whether to show the
  #   private log entries that relate to the current user.
  # :follows - a collection of `Decidim::Follow` resources. It will return any
  #   activity affecting any of these resources, performed by any of them or
  #   contained in any of them as spaces.
  class PublicActivities < LastActivity
    def initialize(organization, options = {})
      @organization = organization
      @resource_name = options[:resource_name]
      @user = options[:user]
      @current_user = options[:current_user]
      @follows = options[:follows]
    end

    def query
      query = base_query

      query = query.where(user:) if user
      query = query.where(resource_type: resource_name) if resource_name.present?

      query = filter_follows(query)
      query = filter_moderated(query)
      filter_spaces(query)
    end

    private

    attr_reader :resource_name, :user, :follows

    def filter_follows(query)
      conditions = []

      if follows.present?
        conditions += follows.group_by(&:decidim_followable_type).map do |type, grouped_follows|
          Decidim::ActionLog.arel_table[:resource_type].eq(type).and(
            Decidim::ActionLog.arel_table[:resource_id].in(grouped_follows.map(&:decidim_followable_id))
          )
        end

        conditions += followed_users_conditions(follows)
        conditions += followed_spaces_conditions(follows)
      end

      return query if conditions.empty?

      chained_conditions = conditions.inject do |previous_condition, condition|
        previous_condition.present? ? previous_condition.or(condition) : condition
      end

      query.where(chained_conditions)
    end

    def followed_users_conditions(follows)
      followed_users = follows.where(decidim_followable_type: "Decidim::UserBaseEntity")
      return [] if followed_users.empty?

      [Decidim::ActionLog.arel_table[:decidim_user_id].in(followed_users.map(&:decidim_followable_id))]
    end

    def followed_spaces_conditions(follows)
      followed_spaces = follows.where(decidim_followable_type: participatory_space_classes)
      return [] if followed_spaces.empty?

      followed_spaces.group_by(&:decidim_followable_type).map do |type, grouped_follows|
        Decidim::ActionLog.arel_table[:participatory_space_type].eq(type).and(
          Decidim::ActionLog.arel_table[:participatory_space_id].in(grouped_follows.map(&:decidim_followable_id))
        )
      end
    end

    def participatory_space_classes
      Decidim.participatory_space_manifests.map(&:model_class_name)
    end
  end
end
