# frozen_string_literal: true

module Decidim
  module Admin
    class ContentBlockCell < Decidim::ViewModel
      include Decidim::IconHelper

      delegate :public_name_key, :has_settings?, to: :model
      delegate :content_block_destroy_confirmation_text, to: :controller

      def edit_content_block_path
        raise "#{self.class.name} is expected to implement #edit_content_block_path"
      end

      def content_block_path
        raise "#{self.class.name} is expected to implement #content_block_path"
      end
    end
  end
end
