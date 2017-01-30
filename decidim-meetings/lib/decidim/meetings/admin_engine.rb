# frozen_string_literal: true
require "geocoder"

module Decidim
  module Meetings
    # This is the engine that runs on the public interface of `decidim-meetings`.
    # It mostly handles rendering the created meeting associated to a participatory
    # process.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Meetings::Admin

      paths["db/migrate"] = nil

      routes do
        resources :meetings do
          resources :meeting_closes, only: [:edit, :update]
          resources :attachments
        end
        root to: "meetings#index"
      end

      def load_seed
        nil
      end

      initializer "decidim_meetings.geocoder" do |_app|
        if Decidim.geocoder.present?
          Geocoder.configure(
            # geocoding service (see below for supported options):
            lookup: :here,

            # IP address geocoding service (see below for supported options):
            # :ip_lookup => :maxmind,

            # to use an API key:
            api_key: [Decidim.geocoder&.fetch(:here_app_id), Decidim.geocoder&.fetch(:here_app_code)]

            # geocoding service request timeout, in seconds (default 3):
            # :timeout => 5,

            # set default units to kilometers:
            # :units => :km,

            # caching (see below for details):
            # :cache => Redis.new,
            # :cache_prefix => "..."
          )
        end
      end
    end
  end
end
