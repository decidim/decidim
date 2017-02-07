# frozen_string_literal: true
module Decidim
  module System
    # The main application controller that inherits from Rails.
    class ApplicationController < ActionController::Base
      include FormFactory
      protect_from_forgery with: :exception, prepend: true

      helper Decidim::TranslationsHelper
      helper Decidim::DecidimFormHelper
    end
  end
end
