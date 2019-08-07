# frozen_string_literal: true

class PagesController < ApplicationController
  layout :set_layout

  def show
    if request.format.pdf?
      send_file(
        Rails.root.join("app", "views", params[:layout], params[:id]).to_s,
        filename: params[:id].split("/").last,
        type: "application/pdf",
        disposition: :inline
      )
    else
      render template: "#{params[:layout]}/#{params[:id]}"
    end
  end

  private

  def set_layout
    params[:layout] || "application"
  end
end
