# frozen_string_literal: true

module ApplicationHelper
  def partial(name)
    render partial: "#{params[:layout]}/partials/#{name}"
  end

  def page_path(name)
    url_for(id: name)
  end
end
