# frozen_string_literal: true

module Decidim
  module Design
    class ComponentsController < Decidim::Design::ApplicationController
      include Decidim::ControllerHelpers
      include Decidim::Design::HasTemplates

      helper ButtonsHelper
      helper CardsHelper
      helper ShareHelper
      helper AnnouncementHelper
      helper ActivityHelper
      helper TabPanelsHelper
    end
  end
end
