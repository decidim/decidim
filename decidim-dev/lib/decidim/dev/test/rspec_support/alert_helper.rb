module AlertHelper
  def accept_alert
    page.driver.browser.switch_to.alert.accept unless page.driver.browser.browser == :phantomjs
  end
end