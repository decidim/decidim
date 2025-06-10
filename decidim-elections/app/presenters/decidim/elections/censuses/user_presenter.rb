# frozen_string_literal: true

module Decidim
  module Elections
    module Censuses
      class UserPresenter < SimpleDelegator
        def user
          __getobj__
        end

        def identifier
          if user.respond_to?(:identifier)
            user.identifier
          elsif user.respond_to?(:name)
            user.name
          elsif user.respond_to?(:email)
            user.email
          elsif user.respond_to?(:user_name)
            user.user_name
          else
            user.to_s
          end
        end

        def date_created
          if user.respond_to?(:created_at)
            I18n.l(user.created_at, format: :short)
          elsif user.respond_to?(:date_created)
            I18n.l(user.date_created, format: :short)
          else
            ""
          end
        end
      end
    end
  end
end
