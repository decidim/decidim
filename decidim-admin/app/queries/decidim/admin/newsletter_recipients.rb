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

        if @form.send_to_followers
          recipients = recipients.where(id: user_id_of_followers)
        end

        if @form.send_to_participants
          #PEnding PArticipants
          # Qui es un participant?
          # - Ha comentat
          # - Ha creat una proposta
          # - Ha creat un debat
          # - Assisteix a un meeting.
        end

        if @form.scope_ids.present?
          recipients = recipients.interested_in_scopes(@form.scope_ids)
        end

        recipients
      end

      private

      def spaces
        return unless @form.participatory_space_types.present?

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

      def participants

      end
    end
  end
end
