# frozen_string_literal: true

module Decidim
  module Elections
    module AdminLog
      class ElectionPresenter < Decidim::Log::BasePresenter
        private

        def diff_fields_mapping
          {
            title: :i18n,
            description: :i18n,
            start_at: :date,
            end_at: :date
          }
        end
      end
    end
  end
end
