# frozen_string_literal: true

module Decidim
  # This cell is intended to be used on profiles.
  # Lists the members of the given user group.
  class MembersCell < Decidim::ViewModel
    include Decidim::CellsPaginateHelper
    include Decidim::ApplicationHelper
    include Decidim::Core::Engine.routes.url_helpers
    include Decidim::CardHelper

    def show
      render :show
    end

    def members
      @members ||= model.users.page(params[:page]).per(20)
    end
  end
end
