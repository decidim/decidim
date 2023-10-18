# frozen_string_literal: true

module Decidim
  module Design
    class FoundationsController < Decidim::Design::ApplicationController
      include Decidim::ControllerHelpers
      include Decidim::Design::HasTemplates
    end
  end
end
