# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents an object that are being implemented by Resourceable module.
    module ResourceableInterface
      include Decidim::Api::Types::BaseInterface
      description "An interface that can be used in display resource methods"
    end
  end
end
