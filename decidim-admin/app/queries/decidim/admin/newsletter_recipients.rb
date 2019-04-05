# frozen_string_literal: true

module Decidim
  module Admin
    # A class used to find the recipients of the
    # Newsletter depending on the params of the form
    class NewsletterRecipients < Rectify::Query
      # newsletter - the Newsletter that will be send and needs to be selected the recipients.
      # form - params to filter the query
      def initialize(newsletter, form)
        @newsletter = newsletter
        @form = form
      end

      def query
        recipients = Decidim::User.where(organization: @newsletter.organization)
                                  .where.not(newsletter_notifications_at: nil, email: nil, confirmed_at: nil)
                                  .not_deleted

        recipients = recipients.where(id: user_id_of_followers) if @form.send_to_followers

        recipients = recipients.where(id: participant_ids) if @form.send_to_participants

        recipients = recipients.interested_in_scopes(@form.scope_ids) if @form.scope_ids.present?

        recipients
      end

      private

      # Return the ids of the ParticipatorySpace selected
      # in form, grouped by type
      # This will be used to take followers and
      # participants of each ParticipatorySpace
      def spaces
        return if @form.participatory_space_types.blank?

        @form.participatory_space_types.map do |type|
          next if type.ids.blank?
          object_class = "Decidim::#{type.manifest_name.classify}"
          if type.ids.include?("all")
            object_class.constantize.where(organization: @organization)
          else
            object_class.constantize.where(id: type.ids.reject(&:blank?))
          end
        end.flatten.compact
      end

      # Return the ids of Users that are following
      # the spaces selected in form
      def user_id_of_followers
        return if spaces.blank?
        return unless @form.send_to_followers
        Decidim::Follow.user_follower_ids_for_participatory_spaces(spaces)
      end

      # Return the ids of Users that have participate
      # the spaces selected in form
      def participant_ids
        return if spaces.blank?
        return unless @form.send_to_participants

        participant_ids = []
        spaces.each do |space|
          available_components = Decidim.component_manifests.map { |m| m.name.to_s if m.newsletter_participant_entities.present? }.compact
          Decidim::Component.where(id: space.component_ids, manifest_name: available_components).published.each do |component|
            Decidim.find_component_manifest(component.manifest_name).try(&:newsletter_participant_entities).flatten.each do |object|
              klass = Object.const_get(object)
              participant_ids << klass.newsletter_participant_ids(component)
            end
          end
          next unless defined?(Decidim::Comments)
          Decidim::Comments.newsletter_participant_entities.flatten.each do |object|
            klass = Object.const_get(object)
            participant_ids << klass.newsletter_participant_ids(space)
          end
        end
        participant_ids.flatten.compact.uniq
      end
    end
  end
end
