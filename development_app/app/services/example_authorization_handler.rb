# frozen_string_literal: true

# An example authorization handler used so that users can be verified against
# third party systems.
#
# You should probably rename this class and file to match your needs.
#
# If you need a custom form to be rendered, you can create a file matching the
# class name named "_form".
#
# Example:
#
#   A handler named Decidim::CensusHandler would look for its partial in:
#   decidim/census/form
#
# When testing your authorization handler, add this line to be sure it has a
# valid public api:
#
#   it_behaves_like "an authorization handler"
#
# See Decidim::AuthorizationHandler for more documentation.
class ExampleAuthorizationHandler < Decidim::AuthorizationHandler
  # Define the attributes you need for this authorization handler. Attributes
  # are defined using Virtus.
  #
  # Example:
  # attribute :document_number, String
  # attribute :birthday, Date
  #
  # You can (and should) also define validations on each attribute:
  #
  # validates :document_number, presence: true
  # validate :custom_method_to_validate_an_attribute

  # The only method that needs to be implemented for an authorization handler.
  # Here you can add your business logic to check if the authorization should
  # be created or not, you should return a Boolean value.
  #
  # Note that if you set some validations and overwrite this method, then the
  # validations will not run, so it's easier to remove this method and rewrite
  # your logic using ActiveModel validations.
  def valid?
    raise NotImplementedError
  end

  # If you need to store any of the defined attributes in the authorization you
  # can do it here.
  #
  # You must return a Hash that will be serialized to the authorization when
  # it's created, and available though authorization.metadata
  #
  # def metadata
  #   {}
  # end
end
