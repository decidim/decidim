Decidim::Core::Engine.routes.draw do
  mount Decidim::Api::Engine => "/api"

  get '/dummy/:id' => 'dummy#show', as: :dummy
end

class Decidim::DummyController < Decidim::ApplicationController
  helper Decidim::Comments::CommentsHelper
  skip_authorization_check

  def show
    @participatory_process = Decidim::ParticipatoryProcess.find(params[:id])
    @options = params.slice(:arguable, :votable)
    @options.each { |key, val| @options[key] = val === 'true' }
    render inline: %{
      <%= javascript_include_tag 'application' %>
      <%= comments_for(@participatory_process, @options) %>
    }.html_safe
  end
end