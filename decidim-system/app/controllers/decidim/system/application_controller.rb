# frozen_string_literal: true
module Decidim
  module System
    # The main application controller that inherits from Rails.
    class ApplicationController < ActionController::Base
      protect_from_forgery with: :exception, prepend: true

      helper Decidim::TranslationsHelper
    end
  end
end
