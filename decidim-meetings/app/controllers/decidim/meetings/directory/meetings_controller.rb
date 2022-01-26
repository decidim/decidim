# frozen_string_literal: true

module Decidim
  module Meetings
    module Directory
      # Exposes the meeting resource so users can view them
      class MeetingsController < Decidim::Meetings::Directory::ApplicationController
        layout "layouts/decidim/application"

        include FilterResource
        include Filterable
        include Paginable

        helper Decidim::WidgetUrlsHelper
        helper Decidim::FiltersHelper
        helper Decidim::Meetings::MapHelper
        helper Decidim::ResourceHelper

        helper_method :meetings, :search

        def calendar
          render plain: CalendarRenderer.for(current_organization), content_type: "type/calendar"
        end

        private

        def meetings
          @meetings ||= paginate(search.result)
        end

        def search_collection
          Meeting.where(component: meeting_components).published.not_hidden.visible_meeting_for(current_user).availability(
            filter_params[:state]
          ).includes(
            :component,
            attachments: :file_attachment
          )
        end

        def default_filter_params
          {
            date: "upcoming",
            title_or_description_cont: "",
            activity: "all",
            with_any_scope: default_filter_scope_params,
            space: default_filter_space_params,
            type: default_filter_type_params,
            origin: default_filter_origin_params,
            with_any_global_category: default_filter_category_params
          }
        end

        def default_filter_category_params
          participatory_spaces = current_organization.public_participatory_spaces
          list_of_ps = []
          participatory_spaces.flat_map do |current_participatory_space|
            next unless current_participatory_space.respond_to?(:categories)

            key_point = current_participatory_space.class.name.gsub("::", "__") + current_participatory_space.id.to_s

            list_of_ps.push(key_point)
            list_of_ps += current_participatory_space.categories.pluck(:id).map(&:to_s)
          end

          ["all"] + list_of_ps
        end

        def default_filter_space_params
          %w(all) + current_organization.public_participatory_spaces.collect(&:model_name).uniq.collect(&:name).collect(&:underscore)
        end

        def default_filter_scope_params
          %w(all global) + current_organization.scopes.pluck(:id).map(&:to_s)
        end

        def meeting_components
          @meeting_components ||= Decidim::Component
                                  .where(manifest_name: "meetings")
                                  .where(participatory_space: participatory_spaces)
                                  .published
        end

        def participatory_spaces
          @participatory_spaces ||= current_organization.public_participatory_spaces
        end
      end
    end
  end
end
