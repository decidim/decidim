# frozen_string_literal: true

module Decidim
  # This cell is intended to be used on profiles.
  class GroupInvitesCell < Decidim::ViewModel
    include Decidim::Core::Engine.routes.url_helpers

    def show
      render :show
    end
  end
end
