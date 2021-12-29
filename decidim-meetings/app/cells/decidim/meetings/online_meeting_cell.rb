# frozen_string_literal: true

module Decidim
  module Meetings
    # This cell defines methods required for other cells to render
    # online meeting urls
    class OnlineMeetingCell < Decidim::ViewModel
      delegate :live?, to: :model

      def show
        return if model.iframe_embed_type_none?
        return unless model.iframe_access_level_allowed_for_user?(current_user)
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

      def future?
        Time.current <= model.start_time && !live?
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
