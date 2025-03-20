# frozen_string_literal: true

require "shellwords"

module Decidim
  class SevenZipWrapper
    class << self
      def compress_and_encrypt(filename:, password:, input_directory:)
        run("cd #{escape(input_directory)} && 7z a -tzip -p#{escape(password)} -mem=AES256 #{escape(filename)} .")
      end

      def extract_and_decrypt(filename:, password:, output_directory:)
        run("7z x -tzip #{escape(filename)} -o#{escape(output_directory)} -p#{escape(password)}")
      end

      private

      def run(command)
        success = system(command)

        raise "Command failed: #{command}" unless success
      end

      def escape(string)
        Shellwords.escape(string)
      end
    end
  end
end
