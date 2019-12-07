# frozen_string_literal: true

module Decidim
  # This cell renders the endrosement button and the endorsements count.
  # It only supports one row of buttons per page due to current tag ids used by javascript.
  class EndorsementButtonsCell < Decidim::ViewModel
    include LayoutHelper
    include CellsHelper
    include EndorsableHelper

    delegate :current_user, to: :controller, prefix: false
    delegate :current_settings, to: :controller, prefix: false
    delegate :current_component, to: :controller, prefix: false
    delegate :allowed_to?, to: :controller, prefix: false

    def show
      render
    end

    # The resource being un/endorsed is the Cell's model.
    def resource
      model
    end

    def reveal_identities_url
      decidim.identities_endorsement_path(resource.to_gid.to_param)
    end

    def endorsement_identity_presenter(endorsement)
      if endorsement.user_group
        Decidim::UserGroupPresenter.new(endorsement.user_group)
      else
        Decidim::UserPresenter.new(endorsement.author)
      end
    end

    #-----------------------------------------------------

    private

    #-----------------------------------------------------

    def raw_model
      model.try(:__getobj__) || model
    end
  end
end
