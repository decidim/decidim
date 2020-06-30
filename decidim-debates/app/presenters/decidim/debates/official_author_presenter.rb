# frozen_string_literal: true

module Decidim
  module Debates
    #
    # A dummy presenter to abstract out the author of an official debate.
    #
    class OfficialAuthorPresenter < Decidim::OfficialAuthorPresenter
      def name
        I18n.t("decidim.debates.models.debate.fields.official_debate")
      end
    end
  end
end
