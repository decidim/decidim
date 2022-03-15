# frozen_string_literal: true

module Decidim
  module Meetings
    # This cell renders the List Item Card (:list_item) meeting card
    # for an instance of a Meeting
    #
    # This cell must be wrapped in a "<div class="card card--list"></div>"
    class MeetingListItemCell < Decidim::Meetings::MeetingCell
      def show
        render
      end

      private

      def cache_hash
        hash = []
        hash.push(I18n.locale.to_s)
        hash.push(model.cache_key_with_version)
        hash.push(model.component.cache_key_with_version)
        hash.push(model.must_render_translation?(current_organization) ? 1 : 0) if model.respond_to?(:must_render_translation?)

        hash.join(Decidim.cache_key_separator)
      end

      def resource_path
        resource_locator(model).path
      end

      def title
        present(model).title
      end

      def resource_date_time
        str = l model.start_time, format: :decidim_day_of_year
        str += " - "
        str += l model.start_time, format: :time_of_day
        str += "-"
        str += l model.end_time, format: :time_of_day
        str
      end
    end
  end
end
