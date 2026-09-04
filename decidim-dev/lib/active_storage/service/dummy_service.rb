# frozen_string_literal: true

module ActiveStorage
  # A dummy "external" ActiveStorage service for testing asset serving using an
  # external service instead of the local DiskService.
  class Service::DummyService < Service
    attr_reader :host

    # Initializes the service.
    #
    # @param host [String] The full host with protocol for the service URL
    # @param public [Boolean] Whether this service is public or not
    def initialize(host:, public: true, **)
      @host = host
      @name = :dummy
      @public = public
      @storage = {}
    end

    # @see ActiveStorage::Service#upload
    def upload(key, io, checksum: nil, **)
      @upload_mutex ||= Mutex.new
      @upload_mutex.synchronize do
        raise ActiveStorage::IntegrityError if exist?(key)

        instrument :upload, key:, checksum: do
          stored = StringIO.new("".b)
          IO.copy_stream(io, stored)
          stored.string.freeze
          stored.rewind
          @storage[key] = stored
        end
      end
    ensure
      io.rewind
    end

    # @see ActiveStorage::Service#download
    def download(key)
      io = io_for(key)
      if block_given?
        instrument :streaming_download, key: do
          buffer = "".b
          yield buffer while io.read(5.megabytes, buffer)
        end
      else
        instrument :download, key: do
          io.read
        end
      end
    ensure
      io&.rewind
    end

    # @see ActiveStorage::Service#download_chunk
    def download_chunk(key, range)
      io = io_for(key)
      instrument :download_chunk, key:, range: do
        return "".b if range.size <= 0

        io.seek(range.begin)
        io.read(range.size)
      end
    ensure
      io&.rewind
    end

    # @see ActiveStorage::Service#delete
    def delete(key)
      return unless exist?(key)

      @storage.delete(key)
    end

    # @see ActiveStorage::Service#exist?
    def exist?(key)
      @storage.has_key?(key)
    end

    private

    # Finds the IO object for the key or raises if it does not exist. Creates a
    # new copy of the item so that the position is not mixed with concurrent
    # read operations.
    #
    # @raise [ActiveStorage::FileNotFoundError] If the key does not exist
    # @return [StringIO] The IO object for the key
    def io_for(key)
      raise ActiveStorage::FileNotFoundError unless exist?(key)

      StringIO.new(@storage[key].string)
    end

    # Generates a private URL for the key.
    #
    # @return [String] The private URL for the key
    def private_url(key, **)
      "#{host}/private/#{key}"
    end

    # Generates a public URL for the key.
    #
    # @return [String] The public URL for the key
    def public_url(key, **)
      "#{host}/public/#{key}"
    end
  end
end
