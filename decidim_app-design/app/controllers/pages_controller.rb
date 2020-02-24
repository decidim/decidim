# frozen_string_literal: true

class PagesController < ApplicationController
  layout :set_layout

  def show
    if request.format.pdf? && valid_path?
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

  def valid_path?
    file_path = Rails.root.join("app", "views", params[:layout], params[:id]).to_s
    file_path.dirname.to_s.start_with?(Rails.root.to_s)
  end

  def set_layout
    params[:layout] || "application"
  end
end
