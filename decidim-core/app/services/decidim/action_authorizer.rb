module Decidim
  class ActionAuthorizer
    def initialize(user, feature, action)
      @user = user
      @feature = feature
      @action = action.to_s
    end

    def authorized?
    end
  end
end
