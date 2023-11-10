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
      helper ActivitiesHelper
      helper TabPanelsHelper
      helper AuthorHelper
      helper AddressHelper
      helper FollowHelper
    end
  end
end
