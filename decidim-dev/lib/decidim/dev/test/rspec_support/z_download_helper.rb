# frozen_string_literal: true

module DownloadHelper
  TIMEOUT = 10
  PATH = Rails.root.join("tmp/downloads").freeze

  def downloads(name = nil)
    Dir[PATH.join(name || "*")]
  end

  def download_path(name = nil)
    wait_for_download(name)
    downloads(name).first
  end

  def download_content(name = nil)
    wait_for_download(name)
    File.read(download_path(name))
  end

  def wait_for_download(name = nil)
    Timeout.timeout(TIMEOUT) do
      sleep 0.1 until downloaded?(name)
    end
  end

  def downloaded?(name = nil)
    downloads(name).any? && !downloading?
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
    page.driver.browser.download_path = DownloadHelper::PATH.to_s
    clear_downloads
  end
end
