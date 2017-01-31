Decidim::Core::Engine.routes.draw do
  mount Decidim::Api::Engine => "/api"

  get '/dummy/:id' => 'dummy#show', as: :dummy
end

class Decidim::DummyController < Decidim::ApplicationController
  helper Decidim::Comments::CommentsHelper
  skip_authorization_check

  def show
    @commentable = Decidim::DummyResource.find(params[:id])
    @options = params.slice(:arguable, :votable)
    @options.each { |key, val| @options[key] = val === 'true' }
    render inline: %{
      <%= javascript_include_tag 'application' %>
      <%= comments_for(@commentable, @options) %>
    }.html_safe
  end
end