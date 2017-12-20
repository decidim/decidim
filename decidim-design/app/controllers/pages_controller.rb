# frozen_string_literal: true

class PagesController < ApplicationController
  layout :layout_for_page

  def show
    render template: params[:id]
  end

  private

  def layout_for_page
    if params[:id].match?(/^email-/)
      "email"
    else
      "application"
    end
  end
end
