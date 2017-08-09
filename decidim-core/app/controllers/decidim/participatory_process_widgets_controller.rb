# frozen_string_literal: true

module Decidim
  class ParticipatoryProcessWidgetsController < Decidim::WidgetsController
    private

    def model
      @model ||= ParticipatoryProcess.find(params[:participatory_process_id])
    end

    def current_participatory_process
      model
    end

    def iframe_url
      @iframe_url ||= participatory_process_participatory_process_widget_url(model)
    end
  end
end
