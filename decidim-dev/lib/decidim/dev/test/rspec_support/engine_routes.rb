# frozen_string_literal: true

module Decidim
  # This is a quick hack so all controller specs have their engine's routes
  # included as well as our Devise mapping.
  module ControllerRequests
    extend ActiveSupport::Concern

    included do
      begin
        engine = (ENV["ENGINE_NAME"].to_s.split("-").map(&:capitalize).join("::") + "::Engine").constantize

        load_routes engine if engine.respond_to?(:routes)
      rescue NameError => _exception
        puts "Failed to automatically inject routes for engine #{ENV["ENGINE_NAME"]}"
      end
    end

    class_methods do
      def load_routes(klass)
        routes do
          klass.routes
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include Decidim::ControllerRequests, type: :controller

  config.before :each, type: :controller do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
end
