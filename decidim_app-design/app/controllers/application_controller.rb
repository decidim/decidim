# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Decidim::NeedsSnippets

  include Decidim::RedesignLayout
  redesign active: true

  protect_from_forgery with: :exception
end
