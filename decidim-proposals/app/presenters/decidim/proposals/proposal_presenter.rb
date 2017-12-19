# frozen_string_literal: true

module Decidim
  module Proposals
    #
    # Decorator for proposals
    #
    class ProposalPresenter < SimpleDelegator
      def author
        @author ||= if official?
                      Decidim::Proposals::OfficialAuthorPresenter.new
                    elsif user_group
                      Decidim::UserGroupPresenter.new(user_group)
                    else
                      Decidim::UserPresenter.new(super)
                    end
      end
    end
  end
end
