# frozen_string_literal: true

require "action_dispatch/system_testing/test_helpers/screenshot_helper"

module ActionDispatch
  module SystemTesting
    module TestHelpers
      module ScreenshotHelper
        def take_screenshot
          save_image
          save_page
          # rubocop:disable Rails/Output
          puts display_screenshot
          # rubocop:enable Rails/Output
        end

        private

        def image_path
          @image_path ||= absolute_image_path.to_s
        end

        def page_path
          @page_path ||= absolute_page_path.to_s
        end

        def absolute_page_path
          Rails.root.join("tmp/screenshots/#{image_name}.html")
        end

        def save_page
          page.save_page(absolute_page_path)
        end

        def display_screenshot
          message = "[Image screenshot]: file://#{image_path}\n"
          message += "       [Page HTML]: file://#{page_path}\n"

          case output_type
          when "artifact"
            message << "\e]1338;url=artifact://#{absolute_image_path}\a\n"
          when "inline"
            name = inline_base64(File.basename(absolute_image_path))
            image = inline_base64(File.read(absolute_image_path))
            message << "\e]1337;File=name=#{name};height=400px;inline=1:#{image}\a\n"
          end

          message
        end
      end
    end
  end
end
