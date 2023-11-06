# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A controller concern to enable flagging capabilities to its resources. Only
  # affects the UI, so make sure you check the controller resources implement
  # the `Decidim::Reportable` model concern.
  module HasParticipatorySpaceContentBlocks
    extend ActiveSupport::Concern

    included do
      delegate :content_blocks_scope_name, to: :current_participatory_space_manifest

      helper_method :active_content_blocks

      def active_content_blocks
        @active_content_blocks ||= if current_participatory_space.present?
                                     Decidim::ContentBlock.published.for_scope(
                                       content_blocks_scope_name,
                                       organization: current_organization
                                     ).where(
                                       scoped_resource_id: current_participatory_space.id
                                     )
                                   else
                                     Decidim::ContentBlock.none
                                   end
      end
    end
  end
end
