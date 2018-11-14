require "json"
require "selenium-webdriver"
require "rspec"
include RSpec::Expectations

describe "TESTMAINDISPLAY" do

  before(:each) do
    @driver = Selenium::WebDriver.for :firefox
    @base_url = "https://www.katalon.com/"
    @accept_next_alert = true
    @driver.manage.timeouts.implicit_wait = 30
    @verification_errors = []
  end
  
  after(:each) do
    @driver.quit
    @verification_errors.should == []
  end
  
  it "test_m_a_i_n_d_i_s_p_l_a_y" do
    @driver.get "http://localhost:4567/"
    element_present?(:name, "ts").should be_true
    # Warning: assertTextNotPresent may require manual changes
    @driver.find_element(:css, "BODY").text.should_not =~ /^[\s\S]*name=ts[\s\S]*$/
    element_present?(:name, "fs").should be_true
    # Warning: assertTextNotPresent may require manual changes
    @driver.find_element(:css, "BODY").text.should_not =~ /^[\s\S]*name=fs[\s\S]*$/
    element_present?(:name, "s").should be_true
    # Warning: assertTextNotPresent may require manual changes
    @driver.find_element(:css, "BODY").text.should_not =~ /^[\s\S]*name=s[\s\S]*$/
    element_present?(:name, "submit").should be_true
  end
  
  def element_present?(how, what)
    ${receiver}.find_element(how, what)
    true
  rescue Selenium::WebDriver::Error::NoSuchElementError
    false
  end
  
  def alert_present?()
    ${receiver}.switch_to.alert
    true
  rescue Selenium::WebDriver::Error::NoAlertPresentError
    false
  end
  
  def verify(&blk)
    yield
  rescue ExpectationNotMetError => ex
    @verification_errors << ex
  end
  
  def close_alert_and_get_its_text(how, what)
    alert = ${receiver}.switch_to().alert()
    alert_text = alert.text
    if (@accept_next_alert) then
      alert.accept()
    else
      alert.dismiss()
    end
    alert_text
  ensure
    @accept_next_alert = true
  end
end
