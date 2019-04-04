# frozen_string_literal: true

module Decidim
  module Admin
    class NewsletterRecipients < Rectify::Query
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

      def user_id_of_followers
        return if spaces.blank?
        return unless @form.send_to_followers
        Decidim::Follow.user_follower_ids_for_participatory_spaces(spaces)
      end

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
