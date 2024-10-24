# frozen_string_literal: true

class EphemeralDummyAuthorizationHandler < DummyAuthorizationHandler
  # This method is set to use the same partial as DummyAuthorizationHandler
  # instead of inferring it from the class name
  def to_partial_path
    "dummy_authorization/form"
  end
end
