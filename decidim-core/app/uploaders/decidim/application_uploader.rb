# frozen_string_literal: true

module Decidim
  # This class deals with uploading files to Decidim. It is intended to just
  # hold the uploads configuration, so you should inherit from this class and
  # then tweak any configuration you need.
  class ApplicationUploader
    def initialize(model, mounted_as)
      @model = model
      @mounted_as = mounted_as
    end

    attr_reader :validable_dimensions, :model, :mounted_as, :content_type_allowlist, :content_type_denylist

    delegate :variants, to: :class

    # Override the directory where uploaded files will be stored.
    # This is a sensible default for uploaders that are meant to be mounted:
    def store_dir
      default_path = "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"

      return File.join(Decidim.base_uploads_path, default_path) if Decidim.base_uploads_path.present?

      default_path
    end

    def variant(key)
      if key && variants[key].present?
        model.send(mounted_as).variant(variants[key])
      else
        model.send(mounted_as)
      end
    end

    def attached?
      model.send(mounted_as).attached?
    end

    def url(options = {})
      representable = model.send(mounted_as)
      return super unless representable.is_a? ActiveStorage::Attached

      variant_url(options.delete(:variant), **options)
    end

    def variant_url(key, options = {})
      return unless attached?

      representable = variant(key)
      AssetRouter::Storage.new(representable).url(**options)
    end

    def path(options = {})
      representable = model.send(mounted_as)
      return super() unless representable.is_a? ActiveStorage::Attached

      variant_path(options.delete(:variant), **options)
    end

    def variant_path(key, options = {})
      variant_url(key, **options.merge(only_path: true))
    end

    def remote_url=(url)
      uri = URI.parse(url)
      filename = File.basename(uri.path)
      file = URI.parse(url).open
      model.send(mounted_as).attach(io: file, filename: filename)
    rescue URI::InvalidURIError
      model.errors.add(mounted_as, :invalid)
    end

    class << self
      # Each class inherits variants from parents and can define their own
      # variants with the set_variants class method
      def variants
        @variants ||= {}
      end

      def set_variants
        return unless block_given?

        variants.merge!(yield)
      end
    end
  end
end
