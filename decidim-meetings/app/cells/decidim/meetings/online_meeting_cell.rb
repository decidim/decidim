# frozen_string_literal: true

module Decidim
  module Meetings
    # This cell defines methods required for other cells to render
    # online meeting urls
    class OnlineMeetingCell < Decidim::ViewModel
      def show
        return if model.iframe_embed_type_none?
        return unless iframe_access_level_allowed?
        return unless assembly_privacy_allowed?

        render
      end

      protected

      def embedder
        @embedder ||= MeetingIframeEmbedder.new(model.online_meeting_url)
      end

      delegate :embeddable?, to: :embedder

      def live_event_url
        if embeddable? && !model.iframe_embed_type_open_in_new_tab?
          Decidim::EngineRouter.main_proxy(model.component).meeting_live_event_path(meeting_id: model.id)
        else
          model.online_meeting_url
        end
      end

      def live?
        model.start_time &&
          model.end_time &&
          Time.current >= (model.start_time - 10.minutes) &&
          Time.current <= model.end_time
      end

      def future?
        Time.current <= model.start_time && !live?
      end

      def iframe_access_level_allowed?
        case model.iframe_access_level
        when "all"
          true
        when "signed_in"
          current_user.present?
        else
          model.has_registration_for?(current_user)
        end
      end

      def assembly_privacy_allowed?
        return true if !private_transparent_assembly? || current_user&.admin?

        model.participatory_space.users.include?(current_user)
      end

      def private_transparent_assembly?
        return unless model.participatory_space.is_a?(Decidim::Assembly)

        model.participatory_space.private_space? && model.participatory_space.is_transparent?
      end
    end
  end
end
