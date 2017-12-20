class PagesController < ApplicationController
  include HighVoltage::StaticPage

  layout :layout_for_page

  private

  def layout_for_page
    if params[:id].match?(/^email-/)
      'email'
    else
      'application'
    end
  end
end
