# frozen_string_literal: true

module Decidim
  module Design
    class ApplicationController < ::DecidimController
      include NeedsOrganization
    end
  end
end
