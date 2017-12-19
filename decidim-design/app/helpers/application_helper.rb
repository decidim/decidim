module ApplicationHelper
  def current_page
    controller.send(:current_page)
  end

  def partial(name)
    render partial: "#{name.gsub("partials/_", "partials/")}"
  end
end
