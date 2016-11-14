# frozen_string_literal: true
module Decidim
  module Components
    class BaseController < Decidim::ApplicationController
      layout "layouts/decidim/participatory_process"
      include NeedsParticipatoryProcess
      helper Decidim::TranslationsHelper

      skip_authorize_resource

      before_filter do
        authorize! :read, current_participatory_process
      end
    end
  end
end
