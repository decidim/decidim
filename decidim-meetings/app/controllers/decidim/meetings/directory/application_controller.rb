# frozen_string_literal: true

module Decidim
  module Meetings
    # This controller is the abstract class from which all other controllers of
    # this engine inherit.
    #
    # Note that it inherits from `Decidim::Components::BaseController`, which
    # override its layout and provide all kinds of useful methods.
    module Directory
      class ApplicationController < Decidim::ApplicationController
        include HasSpecificBreadcrumb

        helper Decidim::Meetings::Directory::ApplicationHelper

        private

        def breadcrumb_item
          {
            label: t("decidim.pages.home.extended.meetings"),
            url: root_path,
            active: true
          }
        end
      end
    end
  end
end
