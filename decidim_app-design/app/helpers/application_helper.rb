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

  def random_string(length, include_uppercase = true, include_lowercase = true, include_numbers = false)
    o = []
    o.push ('a'..'z') if include_uppercase
    o.push ('A'..'Z') if include_lowercase

    o.push (0..9) if include_numbers
    o = o.map { |i| i.to_a }.flatten
    string = (0...length).map { o[rand(o.length)] }.join
  end
end
