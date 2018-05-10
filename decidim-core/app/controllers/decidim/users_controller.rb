# frozen_string_literal: true

module Decidim
  class UsersController < Decidim::ApplicationController
    def index
      respond_to do |format|
        format.json do
          render json: [] && return if params.fetch(:term, "").empty?

          query = current_organization.users.order(name: :asc)
          term = params[:term]
          if term&.start_with?("@")
            term.delete!("@")
            query = query.where("nickname ILIKE ?", "#{term}%")
          else
            query = query.where("name ILIKE ?", "%#{params[:term]}%")
          end
          render json: query.pluck(:id, :name, :nickname)
        end
      end
    end
  end
end
