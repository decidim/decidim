# frozen_string_literal: true

module Decidim
  class WidgetsController < Decidim::ApplicationController
    skip_authorization_check only: :show
    layout 'decidim/widget'
  end
end
