# frozen_string_literal: true
require_dependency "decidim/application_controller"

module Decidim
  # This controller serves static pages using HighVoltage.
  class PagesController < ApplicationController
    include HighVoltage::StaticPage
  end
end
