# frozen_string_literal: true
module Decidim
  # The main application controller that inherits from Rails.
  class ApplicationController < ActionController::Base
    include Decidim::NeedsOrganization
    include Decidim::LocaleSwitcher
    include NeedsAuthorization
    protect_from_forgery with: :exception, prepend: true
    helper_method :current_participatory_process

    layout "layouts/decidim/application"

    def user_not_authorized_path
      decidim.root_path
    end

    private

    def current_participatory_process
      participatory_process
    end

    def participatory_process
      @participatory_process ||= ParticipatoryProcess.find(params[:participatory_process_id])
    end
  end
end
