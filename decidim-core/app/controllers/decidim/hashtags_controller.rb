# frozen_string_literal: true

module Decidim
  class HashtagsController < Decidim::ApplicationController
    include Decidim::ResourceHelper

    skip_authorization_check

    helper_method :hashtag

    def index
      @hashtags ||= collection
    end

    def show
      @hashtagged = hashtag.hashtaggables if hashtag
    end

    def hashtag
      @hashtag ||= collection.find_by(name: params[:hashtag])
    end

    private

    def collection
      Hashtag.where(organization: current_organization)
    end
  end
end
