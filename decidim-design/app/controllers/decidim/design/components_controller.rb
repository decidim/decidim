# frozen_string_literal: true

module Decidim
  module Design
    class ComponentsController < Decidim::Design::ApplicationController
      include Decidim::ControllerHelpers
      include Decidim::Design::HasTemplates

      helper ButtonsHelper
      helper CardsHelper
      helper AnnouncementHelper
      helper ShareHelper
      helper AuthorHelper
      helper ActivitiesHelper
      helper TabPanelsHelper
      helper ReportHelper
      helper AddressHelper
      helper FollowHelper
    end
  end
end
