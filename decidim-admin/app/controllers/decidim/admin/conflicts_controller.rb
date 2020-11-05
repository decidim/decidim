# frozen_string_literal: true

module Decidim
  module Admin
    class ConflictsController < Decidim::Admin::ApplicationController
      layout "decidim/admin/users"

      def index
        @conflicts = Decidim::Verifications::Conflict.all
      end

      def edit
        @conflict = Decidim::Verifications::Conflict.find(params[:id])
      end
    end
  end
end
