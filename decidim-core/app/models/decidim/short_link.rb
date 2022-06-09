# frozen_string_literal: true

module Decidim
  # Short links are a way to reference specific locations within Decidim with
  # shorted URLs, similar to the popular link shortening services. The original
  # reason for creating the feature was to reference long calendar URLs in a
  # more compact way for the URLs to be compatible with the calendar programs.
  # When the URL is long with lots of filtering parameters included in it, it
  # may be too long for specific 3rd party programs.
  #
  # This feature can be used to link to any URLs or resources in Decidim with a
  # short reference.
  class ShortLink < ApplicationRecord
    belongs_to :organization, foreign_key: "decidim_organization_id", class_name: "Decidim::Organization"
    belongs_to :target, polymorphic: true

    validates :identifier, presence: true, uniqueness: true

    before_validation :generate_identifier

    # Finds a matching short link to the same target with exactly the same
    # parameters if it already exists or creates a new one if it doesn't exist.
    #
    # @param target [ActiveRecord::Base] The target where this short link should
    #   link to. Most of the times [Decidim::Organization], [Decidim::Component]
    #   or some other top-level record.
    # @param mounted_engine [String] The mounted engine helper name that will be
    #   used to generate the link.
    # @param route_name [String, nil] The route name to be linked to. If not
    #   defined, the short link will be generated for the root URL for the
    #   mounted engine.
    # @param params [Hash] The query parameters that should be included in the
    #   URL where this short link will redirect to.
    # @return [Decidim::ShortLink] The short link instance to link to.
    def self.to(target, mounted_engine, route_name: nil, params: {})
      organization =
        if target.is_a?(Decidim::Organization)
          target
        else
          target.try(:organization)
        end

      values = {
        organization: organization,
        target: target,
        mounted_engine_name: mounted_engine,
        route_name: route_name
      }
      existing =
        if params
          where(values).find_by("params = ?::jsonb", params.to_json)
        else
          find_by(values.merge(params: nil))
        end

      existing || create!(values.merge(params: params))
    end

    # Creates a random unique identifier for any new links. Raises an
    # OutOfCandidatesError if a free candidate cannot be found with 20 tries.
    # In this situation the older records should be removed from the database.
    #
    # @return [String] A new unique identifier.
    def self.unique_identifier_within(organization)
      1.step do |n|
        raise OutOfCandidatesError if n > 20

        # A-Z, a-z and 0-9
        # 26 + 26 + 10 = 62 possibilities per character
        # 62^10 ≈ 8×10¹⁷ total possibilities
        candidate = SecureRandom.alphanumeric(10)
        next if where(organization: organization, identifier: candidate).any?

        return candidate
      end
    end

    # Overrides the route_name method to add a default route name for the "root"
    # path in case the route name is not defined for the record.
    #
    # @return [String] The route name to link to.
    def route_name
      super || "root"
    end

    # Generates the short URL referencing this link.
    #
    # @return [String] The short URL that can be used to link to the target.
    def short_url
      EngineRouter.new("decidim", default_url_options).short_link_url(id: identifier)
    end

    # Generates the full long URL to the resource matching this short link.
    #
    # @return [String] The target full URL that the short link should link to.
    def target_url
      url_helpers.send("#{route_name}_url", **params)
    end

    private

    # Generates a new identifier for new records.
    #
    # @return [void]
    def generate_identifier
      return if identifier.present?

      self.identifier = self.class.unique_identifier_within(organization)
    end

    # Returns the default URL options for the organization. The participatory
    # space and component related parameters are excluded from the
    # default_url_options because these are also needed for the short URL
    # generation.
    #
    # @return [Hash] A hash of the default URL options for the links.
    def default_url_options
      { host: organization&.host }.compact
    end

    # Returns the options for the URL helper call against the routes proxy.
    # The options include the mounted params for the target, such as
    # participatory space slug and component ID, depending what the target is.
    #
    # @return [Hash] The mounted options for the target record that will be used
    #   to generate the final link.
    def mounted_options
      if target.is_a?(Decidim::Participable)
        # The mounted_params method returns always e.g. participatory_space_slug
        # assembly_slug, etc. But when we want to link to the space itself, we
        # only need the `slug` parameter.
        { host: target.organization.host, slug: target.slug }
      elsif target.respond_to?(:mounted_params)
        target.mounted_params
      elsif target.respond_to?(:component)
        target.component.mounted_params.merge(id: target.id)
      elsif target.respond_to?(:participatory_space)
        target.participatory_space.mounted_params
      elsif target.respond_to?(:slug)
        # E.g. Decidim::StaticPage uses the slug as the `:id` parameter.
        default_url_options.merge(id: target.slug)
      elsif !target.is_a?(Decidim::Organization)
        default_url_options.merge(id: target.id)
      else
        default_url_options
      end
    end

    # Returns the routes helpers for the target engine.
    #
    # @return [Decidim::EngineRouter] An instance of the engine router that will
    #   be used to generate the links to the correct context.
    def url_helpers
      @url_helpers ||= EngineRouter.new(mounted_engine_name, mounted_options)
    end

    # The OutOfCandidatesError is an error class that will be raised when the
    # short link identifiers are running out and the short link cannot be
    # generated.
    class OutOfCandidatesError < StandardError; end
  end
end
