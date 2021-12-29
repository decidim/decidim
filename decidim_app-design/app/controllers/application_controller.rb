# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Decidim::NeedsSnippets

  protect_from_forgery with: :exception
end
