# frozen_string_literal: true

module DownloadHelper
  TIMEOUT = 20
  PATH = Rails.root.join("tmp", "downloads").freeze

  def downloads
    Dir[PATH.join("*")]
  end

  def download_path
    wait_for_download
    downloads.first
  end

  def download_content
    wait_for_download
    File.read(download_path)
  end

  def wait_for_download
    Timeout.timeout(TIMEOUT) do
      sleep 0.1 until downloaded?
    end
  end

  def downloaded?
    downloads.any? && !downloading?
  end

  def downloading?
    downloads.grep(/\.crdownload$/).any?
  end

  def clear_downloads
    FileUtils.rm_f(downloads)
  end
end

RSpec.configure do |config|
  config.include DownloadHelper, download: true
  config.before :each, download: true do
    FileUtils.mkdir_p DownloadHelper::PATH.to_s
    page.driver.browser.download_path = DownloadHelper::PATH.to_s if page.driver.browser.respond_to?(:download_path=)
    clear_downloads
  end
end
