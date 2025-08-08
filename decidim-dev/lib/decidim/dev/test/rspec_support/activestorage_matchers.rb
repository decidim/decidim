# frozen_string_literal: true

module ActiveStorageMatchers
  def be_blob_url(expected)
    BeBlobUrl.new(expected)
  end

  def include_blob_urls(*expected)
    IncludeBlobUrls.new(expected)
  end

  class BlobMatch
    BLOB_URL_MATCHERS = {
      redirect: %r{/rails/active_storage/blobs/redirect/([^/]+)/([^/]+)$},
      representation: %r{/rails/active_storage/representations/redirect/([^/]+)/([^/]+)/([^/]+)$},
      disk: %r{/rails/active_storage/disk/([^/]+)/([^/]+)$}
    }.freeze

    def initialize(url)
      @url = url
    end

    def blob
      return unless key_match

      @blob ||=
        case url_type
        when :redirect, :representation
          ActiveStorage::Blob.find_signed(key_match)
        when :disk
          decoded = ActiveStorage.verifier.verified(key_match, purpose: :blob_key).with_indifferent_access
          ActiveStorage::Blob.find_by(key: decoded[:key]) if decoded
        end
    end

    def variation
      return unless variation_match

      blob.representation(variation_match)
    end

    def key_match
      return unless match

      match[1]
    end

    def variation_match
      return unless match

      match[2] if url_type == :representation
    end

    def filename_match
      return unless match

      case url_type
      when :representation
        match[3]
      else
        match[2]
      end
    end

    private

    attr_reader :url, :url_type

    def match
      return @match if @url_type

      @url_type = :none
      @match = nil
      BLOB_URL_MATCHERS.each do |type, matcher|
        @match = url.match(matcher)
        if @match
          @url_type = type
          break
        end
      end

      @match
    end
  end

  class BeBlobUrl
    def initialize(expected)
      @expected = expected
    end

    def description
      "be a blob URL"
    end

    def matches?(actual)
      @actual = actual
      match = BlobMatch.new(actual)
      match.blob == expected
    end

    def failure_message
      "expected #{actual} to match blob with ID #{expected.id}"
    end

    def failure_message_when_negated
      "expected #{actual} not to match blob with ID #{expected.id}"
    end

    private

    attr_reader :expected, :actual
  end

  class IncludeBlobUrls
    def initialize(expected)
      @expected = expected
    end

    def description
      "include blob URLs"
    end

    def matches?(actual)
      @actual = actual

      actual.all? do |url|
        match = BlobMatch.new(url)
        expected.include?(match.blob)
      end
    end

    def failure_message
      "expected #{actual.inspect} to match blobs with ID #{expected.map(&:id).join(", ")}"
    end

    def failure_message_when_negated
      "expected #{actual.inspect} not to match blobs with ID #{expected.map(&:id).join(", ")}"
    end

    private

    attr_reader :expected, :actual
  end
end

RSpec.configure do |config|
  config.include ActiveStorageMatchers
end
