# frozen_string_literal: true

module Decidim
  # Helpers related to icons
  module IconHelper
    include Decidim::LayoutHelper

    DEFAULT_RESOURCE_TYPE_ICONS = {
      "all" => "apps-2-line",
      "Decidim::Proposals::CollaborativeDraft" => "draft-line",
      "Decidim::Comments::Comment" => "chat-1-line",
      "Decidim::Debates::Debate" => "discuss-line",
      "Decidim::Initiative" => "lightbulb-flash-line",
      "Decidim::Meetings::Meeting" => "map-pin-line",
      "Decidim::Blogs::Post" => "pen-nib-line",
      "Decidim::Proposals::Proposal" => "chat-new-line",
      "Decidim::Budgets::Order" => "check-double-line",
      "Decidim::Budgets::Budget" => "coin-line",
      "Decidim::Budgets::Project" => "coin-line",
      "Decidim::Assembly" => "government-line",
      "Decidim::Amendment" => "git-branch-line",
      "Decidim::ParticipatoryProcess" => "treasure-map-line",
      "Decidim::Category" => "price-tag-3-line",
      "Decidim::Scope" => "scan-line",
      "Decidim::Conference" => "mic-line",
      "Decidim::Votings::Voting" => "check-double-fill",
      "Decidim::User" => "user-line",
      "Decidim::UserGroup" => "group-line",
      "comments_count" => "wechat-line",
      "upcoming" => "calendar-2-line",
      "past" => "calendar-check-line",
      "in_person" => "community-line",
      "online" => "webcam-line",
      "hybrid" => "home-wifi-line",
      "official" => "star-line",
      "participants" => "open-arm-line",
      "user_group" => "team-line",
      "user_groups" => "team-line",
      "images" => "image-line",
      "documents" => "file-text-line",
      "like" => "heart-add-line",
      "dislike" => "dislike-line",
      "follow" => "notification-3-line",
      "unfollow" => "notification-3-fill",
      "share" => "share-line",
      "other" => "question-line"
    }.freeze

    # Public: Returns an icon given an instance of a Component. It defaults to
    # a question mark when no icon is found.
    #
    # component - The component to generate the icon for.
    # options - a Hash with options
    #
    # Returns an HTML tag with the icon.
    def component_icon(component, options = {})
      manifest_icon(component.manifest, options)
    end

    # Public: Returns an icon given an instance of a Manifest. It defaults to
    # a question mark when no icon is found.
    #
    # manifest - The manifest to generate the icon for.
    # options - a Hash with options
    #
    # Returns an HTML tag with the icon.
    def manifest_icon(manifest, options = {})
      if manifest.respond_to?(:icon) && manifest.icon.present?
        external_icon manifest.icon, options
      else
        icon "question-mark", options
      end
    end

    # Public: Finds the correct icon for the given resource. If the resource has a
    # Component then it uses it to find the icon, otherwise checks for the resource
    # manifest to find the icon.
    #
    # resource - The resource to generate the icon for.
    # options - a Hash with options
    #
    # Returns an HTML tag with the icon.
    def resource_icon(resource, options = {})
      if resource.instance_of?(Decidim::Comments::Comment)
        icon "comment-square", options
      elsif resource.respond_to?(:component) && resource.component.present?
        component_icon(resource.component, options)
      elsif resource.respond_to?(:manifest) && resource.manifest.present?
        manifest_icon(resource.manifest, options)
      elsif resource.is_a?(Decidim::User)
        icon "person", options
      else
        icon "bell", options
      end
    end

    def resource_type_icon(resource_type, options = {})
      icon resource_type_icon_key(resource_type), options
    end

    def resource_type_icon_key(resource_type)
      DEFAULT_RESOURCE_TYPE_ICONS[resource_type.to_s] || DEFAULT_RESOURCE_TYPE_ICONS["other"]
    end

    def text_with_resource_icon(resource_name, text)
      output = ""
      output += resource_type_icon resource_name
      output += content_tag :span, text
      output.html_safe
    end
  end
end
