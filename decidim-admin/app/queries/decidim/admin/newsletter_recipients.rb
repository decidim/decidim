# frozen_string_literal: true

module Decidim
  module Admin
    # A class used to find the recipients of the
    # Newsletter depending on the params of the form
    class NewsletterRecipients < Decidim::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # form - params to filter the query
      def self.for(form)
        new(form).query
      end

      # Initializes the class.
      #
      # form - params to filter the query
      def initialize(form)
        @form = form
      end

      def query
        recipients = recipients_base_query

        return recipients if @form.send_to_all_users
        return verified_users if @form.send_to_verified_users

        if filters_present?
          filtered_recipients = apply_filters(recipients)
          return recipients.none if filtered_recipients.empty?

          return filtered_recipients
        end

        recipients
      end

      private

      def recipients_base_query
        Decidim::User.available
                     .where(organization: @form.current_organization)
                     .where.not(newsletter_notifications_at: nil)
                     .where.not(email: nil)
                     .confirmed
      end

      def filters_present?
        @form.send_to_followers || @form.send_to_participants || @form.send_to_private_members
      end

      def apply_filters(recipients)
        filters = [
          user_id_of_followers,
          participant_ids,
          private_member_ids
        ].compact.flatten.uniq

        filters.empty? ? recipients.none : recipients.where(id: filters)
      end

      # Return the ids of the ParticipatorySpace selected
      # in form, grouped by type
      # This will be used to take followers and
      # participants of each ParticipatorySpace
      def spaces
        return [] if @form.participatory_space_types.blank?

        @spaces ||= @form.participatory_space_types.map do |type|
          next if type.ids.blank?

          ids = type.ids

          object_class = Decidim.participatory_space_registry.find(type.manifest_name).model_class_name.constantize

          ids.include?("all") ? object_class.where(organization: @form.organization) : object_class.where(id: ids.compact_blank)
        end.flatten.compact
      end

      def verified_users
        users = recipients_base_query

        verified_users = Decidim::Authorization.select(:decidim_user_id)
                                               .where(decidim_user_id: users.select(:id))
                                               .where.not(granted_at: nil)
                                               .where(name: @form.verification_types)
                                               .distinct
        users.where(id: verified_users)
      end

      # Return the ids of Users that are following
      # the spaces selected in form
      def user_id_of_followers
        return if spaces.blank?
        return unless @form.send_to_followers

        Decidim::Follow.user_follower_ids_for_participatory_spaces(spaces)
      end

      # Return the ids of Users that have participated in
      # the spaces selected in form
      def participant_ids
        return if spaces.blank?
        return unless @form.send_to_participants

        participant_ids = []
        spaces.each do |space|
          next unless defined? space.component_ids

          available_components = Decidim.component_manifests.map { |m| m.name.to_s if m.newsletter_participant_entities.present? }.compact
          Decidim::Component.where(id: space.component_ids, manifest_name: available_components).published.each do |component|
            Decidim.find_component_manifest(component.manifest_name).try(&:newsletter_participant_entities).flatten.each do |object|
              klass = Object.const_get(object)
              participant_ids |= klass.newsletter_participant_ids(component)
            end
          end
        end

        participant_ids.flatten.compact.uniq
      end

      def private_spaces
        return [] if spaces.blank?

        spaces.select { |space| space.try(:private_space?) }
      end

      def private_member_ids
        return unless @form.send_to_private_members
        return [] if private_spaces.blank?

        Decidim::ParticipatorySpacePrivateUser.private_user_ids_for_participatory_spaces(private_spaces)
      end
    end
  end
end
