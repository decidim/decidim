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

      host = "http://localhost:3000"
      urls = ["/"]
      urls << ::Decidim::ResourceLocatorPresenter.new(Decidim::ParticipatoryProcess.published.first).path
      urls << ::Decidim::ResourceLocatorPresenter.new(Decidim::Meetings::Meeting.published.first).path
      urls << ::Decidim::ResourceLocatorPresenter.new(Decidim::Proposals::Proposal.published.first).path

      # Update lighthouse configuration with the urls
      lighthouse_rc_path = Rails.root.join("../.lighthouserc.json")
      lighthouserc = JSON.parse(File.read(lighthouse_rc_path))
      lighthouserc["ci"]["collect"]["url"] = urls.map { |url| "#{host}#{url}" }
      File.write(lighthouse_rc_path, lighthouserc.to_json)
    end
  end
end
