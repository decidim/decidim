module AlertHelper
  def accept_alert_dialogue
    page.driver.browser.switch_to.alert.accept unless page.driver.browser.browser == :phantomjs
  end
end

RSpec.configure do |config|
  config.include AlertHelper
end