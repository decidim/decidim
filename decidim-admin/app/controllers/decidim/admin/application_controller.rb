# frozen_string_literal: true
module Decidim
  module Admin
    # The main application controller that inherits from Rails.
    class ApplicationController < ActionController::Base
      protect_from_forgery with: :exception, prepend: true
    end
  end
end
