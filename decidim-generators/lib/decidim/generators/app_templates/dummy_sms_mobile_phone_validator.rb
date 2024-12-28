# frozen_string_literal: true

# This class overrides the two methods of the parent class ensuring that the
# user has a previous sms authorization with the same phone number provided in
# the initiative signature workflow. In this way only the sms code received in
# the phone is verified and no previous authorization is necessary.
class DummySmsMobilePhoneValidator < Decidim::Initiatives::ValidateMobilePhone
  def authorized? = true

  def phone_match? = true
end
