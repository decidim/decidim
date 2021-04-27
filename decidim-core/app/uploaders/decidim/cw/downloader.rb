# frozen_string_literal: true

module Decidim::Cw
  class Downloader < CarrierWave::Downloader::Base
    def skip_ssrf_protection?(_uri)
      true
    end
  end
end
