# frozen_string_literal: true

class PagesController < ApplicationController
  layout :set_layout

  def show
    render template: "#{params[:layout]}/#{params[:id]}"
  end

  private

  def set_layout
    params[:layout] || "application"
  end
end
