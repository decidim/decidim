# frozen_string_literal: true

module Decidim
  module Amendable
    # This cell renders the button to amend the given resource.
    class AmendButtonCardCell < Decidim::ViewModel
      def show
        return unless amendments_enabled? && model.amendable?
        return unless current_component.current_settings.amendment_creation_enabled
        return unless can_participate_in_private_space?

        render
      end

      def model_name
        model.model_name.human
      end

      def current_component
        model.component
      end

      def new_amend_path
        decidim.new_amend_path(amendable_gid: model.to_sgid.to_s)
      end
    end
  end
end
