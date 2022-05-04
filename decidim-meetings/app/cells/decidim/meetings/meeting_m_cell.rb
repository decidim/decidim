# frozen_string_literal: true

module Decidim
  module Meetings
    # This cell renders the Medium (:m) meeting card
    # for an given instance of a Meeting
    class MeetingMCell < Decidim::CardMCell
      include MeetingCellsHelper

      def has_authors?
        true
      end

      def render_authorship
        cell "decidim/author", author_presenter_for(model.normalized_author)
      end

      def date
        render
      end

      def address
        decidim_html_escape(render)
      end

      def title
        present(model).title
      end

      def description
        present(model).description(strip_tags: true).truncate(120, separator: /\s/)
      end

      def badge
        render if has_badge?
      end

      def has_badge?
        withdrawn?
      end

      def state_classes
        ["alert"]
      end

      delegate :online_meeting?, to: :model

      private

      def cache_hash
        hash = []
        hash << I18n.locale.to_s
        hash << model.cache_key_with_version
        hash << Digest::MD5.hexdigest(model.component.cache_key_with_version)
        hash << Digest::MD5.hexdigest(resource_image_path) if resource_image_path
        hash << model.comments_count
        hash << model.follows_count
        hash << render_space? ? 1 : 0

        if current_user
          hash << current_user.cache_key_with_version
          hash << current_user.follows?(model) ? 1 : 0
        end
        hash << Digest::MD5.hexdigest(model.author.cache_key_with_version)
        hash << (model.must_render_translation?(current_organization) ? 1 : 0) if model.respond_to?(:must_render_translation?)

        hash.join(Decidim.cache_key_separator)
      end

      def has_state?
        withdrawn?
      end

      def resource_image_path
        model.photo&.url
      end

      def has_image?
        true
      end

      def spans_multiple_dates?
        start_date != end_date
      end

      def meeting_date
        return render(:multiple_dates) if spans_multiple_dates?

        render(:single_date)
      end

      def formatted_start_time
        model.start_time.strftime("%H:%M")
      end

      def formatted_end_time
        model.end_time.strftime("%H:%M")
      end

      def start_date
        model.start_time.to_date
      end

      def end_date
        model.end_time.to_date
      end

      def can_join?
        model.can_be_joined_by?(current_user)
      end

      def show_footer_actions?
        options[:show_footer_actions]
      end

      def statuses
        [:follow, :comments_count]
      end
    end
  end
end
