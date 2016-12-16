Decidim::Core::Engine.routes.draw do
  mount Decidim::Api::Engine => "/api"

  get '/dummy/:id' => 'dummy#show', as: :dummy
end

class Decidim::DummyController < Decidim::ApplicationController
  helper Decidim::Comments::CommentsHelper
  skip_authorization_check

  def show
    @participatory_process = Decidim::ParticipatoryProcess.find(params[:id])
    @options = params.slice(:arguable)
    @options.each { |key, val| @options[key] = val === 'true' }
    render inline: "<%= comments_for(@participatory_process, @options) %>".html_safe
  end
end