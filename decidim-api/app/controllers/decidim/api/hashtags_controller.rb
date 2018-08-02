# frozen_string_literal: true

module Decidim
  module Api
    # This controller takes queries from an HTTP endpoint and sends them out to
    # the Schema to be executed, later returning the response as JSON.
    class HashtagsController < Api::ApplicationController
      def hashtags
        respond_to do |format|
          # format.json{ render :json => Hashtag.where(organization: current_organization).where('name like ?', "#{params[:q]}%").pluck(:name).compact}
          format.json{ render :json => Hashtag.where(organization: current_organization).where('name like ?', "#{params[:q]}%").as_json(:only => [:name])}
        end
      end
    end
  end
end
