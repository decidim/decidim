# frozen_string_literal: true

module ApplicationHelper
  def partial(name, opts = {})
    render partial: "#{params[:layout]}/partials/#{name}", locals: opts
  end

  def page_path(name)
    url_for(id: name)
  end

  def is(mod)
    request.path_info.include?(mod)
  end
end
