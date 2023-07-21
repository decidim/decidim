# frozen_string_literal: true

namespace :decidim do
  namespace :lighthouse do
    desc "Prepares seeds for Lighthouse report"
    task prepare_urls: :environment do
      # Lighhouse report is executed in CI and should check:
      # - homepage
      # - a participatory process page
      # - a meeting page
      # - a proposal page
      #
      # Because seeds make urls dynamic, this task updates the lighthouse configuration
      # to add dynamically the urls to check.

      # Update lighthouse configuration with the urls
      lighthouse_rc_path = Rails.root.join("../.lighthouserc.json")
      lighthouserc = JSON.parse(File.read(lighthouse_rc_path))
      lighthouserc["ci"]["collect"]["url"] = lighthouse_urls
      File.write(lighthouse_rc_path, lighthouserc.to_json)
    end

    desc "Warms up the URLs to be requested"
    task warmup: :environment do
      lighthouse_urls.each do |url|
        uri = URI.parse(url)
        connection = Net::HTTP.new(uri.host, uri.port)
        connection.start do |http|
          puts "Warming up #{uri.path}"
          response = http.get(uri.path)
          puts "--HTTP STATUS: #{response.code}"
        end
      end
    end

    private

    def lighthouse_urls
      host = "http://localhost:3000"
      lighthouse_paths.map { |path| "#{host}#{path}" }
    end

    def lighthouse_paths
      ["/"].tap do |urls|
        urls << Decidim::ResourceLocatorPresenter.new(Decidim::ParticipatoryProcess.published.first).path
        urls << Decidim::ResourceLocatorPresenter.new(Decidim::Meetings::Meeting.published.first).path
        urls << Decidim::ResourceLocatorPresenter.new(Decidim::Proposals::Proposal.published.first).path
      end
    end
  end
end
