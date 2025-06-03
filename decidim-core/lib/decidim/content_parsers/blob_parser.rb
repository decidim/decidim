# frozen_string_literal: true

module Decidim
  module ContentParsers
    # Parses any blob URLs from the content and replaces them with references
    # to those blobs.
    class BlobParser < BaseParser
      # Matches all possible URLs pointing to ActiveStorage::Blob objects.
      #
      # Possible routes:
      # get "/blobs/redirect/:signed_id/*filename"
      # get "/blobs/proxy/:signed_id/*filename"
      # get "/blobs/:signed_id/*filename"
      # get "/representations/redirect/:signed_blob_id/:variation_key/*filename"
      # get "/representations/proxy/:signed_blob_id/:variation_key/*filename"
      # get "/representations/:signed_blob_id/:variation_key/*filename"
      # get  "/disk/:encoded_key/*filename"
      #
      # See:
      # https://github.com/rails/rails/blob/a7e379896552ce43b822385c03c37f2bd47739d3/activestorage/config/routes.rb#L5-L14
      BLOB_REGEX = %r{
        # Group 1: Host part
        (?<host_part>
          # Group 2: Domain and subpath part
          #{URI::DEFAULT_PARSER.make_regexp(%w(https http))}
        )?
        /rails/active_storage
        # Group 3: Blob path, representation path or disk service path
        /(?<type_part>blobs/redirect|blobs/proxy|blobs|representations/redirect|representations/proxy|representations|disk)
        # Group 4: Signed ID for blobs or encoded key for disk service
        /(?<key_part>[^/]+)
        # Group 5: Variation part (only for representations)
        (
          # Group 6: Variation key for representations
          /(?<variation_part>[\w.=-]+)
        )?
        # Group 7: Filename
        /([\w.=-]+)
      }x

      def rewrite
        replace_blobs(content)
      end

      private

      def replace_blobs(text)
        text.gsub(BLOB_REGEX) do |match|
          named_captures = Regexp.last_match.named_captures

          type_part = named_captures["type_part"]
          key_part = named_captures["key_part"]

          variation_key = nil
          blob =
            if type_part == "disk"
              # Disk service URL
              decoded = ActiveStorage.verifier.verified(key_part, purpose: :blob_key).with_indifferent_access
              ActiveStorage::Blob.find_by(key: decoded[:key]) if decoded
            else
              # Representation or blob
              if type_part.start_with?("representations")
                # Representation
                variation_part = named_captures["variation_part"]
                variation_key = generate_variation_key(variation_part)
              end

              ActiveStorage::Blob.find_signed(key_part)
            end
          next match unless blob

          "#{blob.to_global_id}#{"/#{variation_key}" if variation_key}"
        end
      end

      def generate_variation_key(variation_part)
        # The variation part has to be decoded because it will eventually
        # expire. This way we can preserve the variation information
        # longer.
        variation = ActiveStorage.verifier.verify(variation_part, purpose: :variation)
        return unless variation

        # Convert to base64 encoded JSON string for better representation within
        # the URLs. This manually encoded part will not expire as it is
        # persisted to the database.
        Base64.strict_encode64(ActiveSupport::JSON.encode(variation))
      rescue ActiveSupport::MessageVerifier::InvalidSignature
        # This happens if the variation key is already expired in which
        # case it cannot be represented and instead a URL to the blob is
        # created.
        variation_part
      end
    end
  end
end
