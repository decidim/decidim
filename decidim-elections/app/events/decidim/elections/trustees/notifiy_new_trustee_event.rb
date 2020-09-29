# frozen-string_literal: true

module Decidim
  module Elections
    module Trustees
      class NotifiyNewTrusteeEvent < Decidim::Events::SimpleEvent
        i18n_attributes :resource_name

        def resource_name
          @resource_name ||= translated_attribute(participatory_space.title)
        end

        def participatory_space
          @participatory_space ||= resource
        end
      end
    end
  end
end
