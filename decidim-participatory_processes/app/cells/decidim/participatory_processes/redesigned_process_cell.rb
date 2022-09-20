# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This cell renders the process card for an instance of a Process
    # the default size is the Medium Card (:m)
    class RedesignedProcessCell < Decidim::RedesignedCardCell
      def metadata
        [{ icon: icon_name(:published_at), value: published_at }] + super
      end

      def stats
        @stats ||= ParticipatoryProcessStatsPresenter.new(participatory_process: model).card_collection
      end
    end
  end
end
