# frozen_string_literal: true

module Decidim
  class ParticipatoryProcessWidgetsController < Decidim::WidgetsController
    helper_method :model

    private

    def model
      @model ||= ParticipatoryProcess.find(params[:participatory_process_id])
    end

    def iframe_url
      @iframe_url ||= participatory_process_participatory_process_widget_url(model)
    end
  end
end
