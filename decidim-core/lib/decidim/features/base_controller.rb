# frozen_string_literal: true
module Decidim
  module Features
    # Controller from which all component engines inherit from. It's in charge
    # of setting the appropiate layout, including necessary helpers, and overall
    # fooling the engine into thinking it's isolated.
    class BaseController < Decidim::ApplicationController
      layout "layouts/decidim/participatory_process"
      include NeedsParticipatoryProcess
      helper Decidim::TranslationsHelper

      skip_authorize_resource

      before_filter do
        authorize! :read, current_participatory_process
      end

      private

      def current_feature
        env["decidim.current_feature"]
      end

      def current_participatory_process
        env["decidim.current_participatory_process"]
      end
    end
  end
end
