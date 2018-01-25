# frozen_string_literal: true

module Decidim
  module Debates
    #
    # Decorator for debates
    #
    class DebatePresenter < SimpleDelegator
      def author
        @author ||= if official?
                      Decidim::Debates::OfficialAuthorPresenter.new
                    elsif user_group
                      Decidim::UserGroupPresenter.new(user_group)
                    else
                      Decidim::UserPresenter.new(super)
                    end
      end
    end
  end
end
