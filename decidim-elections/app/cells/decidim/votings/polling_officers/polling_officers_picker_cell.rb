# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Votings
    module PollingOfficers
      # This cell renders a polling officers picker.
      class PollingOfficersPickerCell < Decidim::ViewModel
        MAX_POLLING_OFFICERS = 1000

        def show
          return render :polling_officers if filtered?

          render
        end

        alias component model

        def filtered?
          !search_text.nil?
        end

        def picker_path
          request.path
        end

        def search_text
          params[:q]
        end

        def more_polling_officers?
          @more_polling_officers ||= more_polling_officers_count.positive?
        end

        def more_polling_officers_count
          @more_polling_officers_count ||= polling_officers_count - MAX_POLLING_OFFICERS
        end

        def polling_officers_count
          @polling_officers_count ||= filtered_polling_officers.count
        end

        def decorated_polling_officers
          filtered_polling_officers.limit(MAX_POLLING_OFFICERS)
        end

        def filtered_polling_officers
          @filtered_polling_officers ||= if filtered?
                                           query = polling_officers.joins(:user)
                                           if search_text.start_with?("@")
                                             query.where("nickname ILIKE ?", "#{search_text.delete("@")}%")
                                           else
                                             query.where("name ILIKE ?", "%#{search_text}%").or(
                                               query.where("email ILIKE ?", "%#{search_text}%")
                                             )
                                           end
                                         else
                                           polling_officers
                                         end
        end

        def polling_officers
          @polling_officers ||= model.available_polling_officers
        end

        def polling_officers_collection_name
          Decidim::Votings::PollingOfficer.model_name.human(count: 2)
        end
      end
    end
  end
end
