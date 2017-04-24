module AlertHelper
  def accept_alert
    page.driver.browser.switch_to.alert.accept if page.driver.class == Capybara::Selenium::Driver
  end
end