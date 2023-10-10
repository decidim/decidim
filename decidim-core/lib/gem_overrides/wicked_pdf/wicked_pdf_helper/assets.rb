# frozen_string_literal: true

require "#{Gem.loaded_specs["wicked_pdf"].full_gem_path}/lib/wicked_pdf/wicked_pdf_helper/assets"

module WickedPdf
  module WickedPdfHelper
    module Assets
      def wicked_pdf_asset_pack_path(asset)
        return unless defined?(Shakapacker)

        if running_in_development?
          asset_pack_path(asset)
        else
          wicked_pdf_asset_path webpacker_source_url(asset)
        end
      end

      def running_in_development?
        return unless webpacker_version
        
        if Shakapacker.respond_to?(:dev_server)
          Shakapacker.dev_server.running?
        else
          Rails.env.development? || Rails.env.test?
        end
      end

      def webpacker_version
        pp "got here"
        return unless defined?(Shakapacker)

        # If webpacker is used, need to check for version
        require 'shakapacker/version'

        Shakapacker::VERSION
      end
    end
  end
end
