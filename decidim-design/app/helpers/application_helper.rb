# frozen_string_literal: true

module ApplicationHelper
  def partial(name)
    render partial: "#{params[:layout]}/partials/#{name}"
  end
end
