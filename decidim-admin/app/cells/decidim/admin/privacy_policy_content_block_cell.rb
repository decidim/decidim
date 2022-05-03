# frozen_string_literal: true

module Decidim
  module Admin
    class PrivacyPolicyContentBlockCell < ContentBlockCell
      def edit_content_block_path
        decidim_admin.edit_organization_privacy_policy_content_block_path(manifest_name)
      end
    end
  end
end
