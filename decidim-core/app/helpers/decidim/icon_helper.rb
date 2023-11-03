# frozen_string_literal: true

module Decidim
  # Helpers related to icons
  module IconHelper
    include Decidim::LayoutHelper

    DEFAULT_RESOURCE_TYPE_ICONS = {
      "Decidim::Proposals::CollaborativeDraft" => { icon: "draft-line", description: "Collaborative draft", category: "activity" },
      "Decidim::Proposals::Proposal" => { icon: "chat-new-line", description: "Proposal", category: "activity" },
      "Decidim::Amendment" => { icon: "git-branch-line", description: "Amendment", category: "activity" },
      "Decidim::ParticipatoryProcess" => { icon: "treasure-map-line", description: "Participatory Process", category: "activity" },
      "Decidim::Budgets::Budget" => { icon: "coin-line", description: "Budget", category: "activity" },
      "Decidim::Budgets::Project" => { icon: "coin-line", description: "Project (Budgets)", category: "activity" },
      "Decidim::Accountability::Result" => { icon: "briefcase-2-line", description: "Result / project (Accountability)", category: "activity" },
      "Decidim::Initiative" => { icon: "lightbulb-flash-line", description: "Initiative", category: "activity" },
      "Decidim::Blogs::Post" => { icon: "pen-nib-line", description: "Blogs post", category: "activity" },
      "Decidim::Assembly" => { icon: "government-line", description: "Assembly", category: "activity" },
      "Decidim::Budgets::Order" => { icon: "check-double-fill", description: "Budget voting", category: "activity" },
      "Decidim::Debates::Debate" => { icon: "discuss-line", description: "Debate", category: "activity" },
      "Decidim::Meetings::Meeting" => { icon: "map-pin-line", description: "Meeting", category: "activity" },
      "Decidim::Conference" => { icon: "mic-line", description: "Conference", category: "activity" },
      "Decidim::Votings::Voting" => { icon: "check-double-fill", description: "Voting", category: "activity" },
      "Decidim::Elections::Election" => { icon: "chat-poll-line", description: "Election", category: "activity" },
      "Decidim::Comments::Comment" => { icon: "chat-1-line", description: "Comment", category: "activity" },
      "Decidim::Category" => { icon: "price-tag-3-line", description: "Category", category: "activity" },
      "Decidim::Scope" => { icon: "scan-line", description: "Scope", category: "activity" },
      "Decidim::User" => { icon: "user-line", description: "User", category: "activity" },
      "Decidim::UserGroup" => { icon: "group-line", description: "User Group", category: "activity" },
      "comments_count" => { icon: "wechat-line", description: "Comments Count", category: "activity" },

      "like" => { icon: "heart-add-line", description: "Like", category: "action" },
      "dislike" => { icon: "dislike-line", description: "Dislike", category: "action" },
      "follow" => { icon: "notification-3-line", description: "Follow", category: "action" },
      "unfollow" => { icon: "notification-3-fill", description: "Unfollow", category: "action" },
      "share" => { icon: "share-line", description: "Share", category: "action" },

      "nickname" => { icon: "account-pin-circle-line", description: "Nickname", category: "profile" },
      "badges" => { icon: "award-line", description: "Badges", category: "profile" },
      "profile" => { icon: "team-line", description: "Groups", category: "profile" },
      "user_group" => { icon: "team-line", description: "Groups", category: "profile" },
      "profile" => { icon: "link", description: "web / URL", category: "profile" },
      "following" => { icon: "eye-2-line", description: "Following", category: "profile" },
      "activity" => { icon: "bubble-chart-line", description: "Activity", category: "profile" },
      "followers" => { icon: "group-line", description: "Followers", category: "profile" },

      "official" => { icon: "star-line", description: "Official", category: "origin" },
      "participants" => { icon: "open-arm-line", description: "Participants", category: "origin" },

      "documents" => { icon: "file-text-line", description: "Document", category: "documents" },
      "folder_open" => { icon: "folder-open-line", description: "Folder open", category: "documents" },
      "folder_close" => { icon: "folder-line", description: "Folder close", category: "documents" },
      "document_weight" => { icon: "scales-2-line", description: "Doc. weight (kb/mb)", category: "documents" },
      "document_download" => { icon: "download-line", description: "Download", category: "documents" },
      "images" => { icon: "image-line", description: "Images", category: "documents" },

      "in_person" => { icon: "community-line", description: "In person", category: "type" },
      "online" => { icon: "webcam-line", description: "Online", category: "type" },
      "hybrid" => { icon: "home-wifi-line", description: "Hybrid", category: "type" },

      "accepted" => { icon: "checkbox-circle-line", description: "Accepted", category: "status" },
      "evaluating" => { icon: "eye-line", description: "Evaluating", category: "status" },
      "unanswered" => { icon: "message-3-line", description: "No answer", category: "status" },
      "rejected" => { icon: "delete-back-2-line", description: "Rejected / Cancelled", category: "status" },
      "active" => { icon: "pulse-line", description: "Active", category: "status" },
      "next" => { icon: "calendar-2-line", description: "Next", category: "status" },
      "closed" => { icon: "calendar-check-line", description: "Closed / Finished", category: "status" },

      "all" => { icon: "apps-2-line", description: "All", category: "other" },
      "other" => { icon: "question-line", description: "Other", category: "other" },

      "assembly_type" => { icon: "group-2-line", description: "Type", category: "assemblies" },

      "conference_speaker" => { icon: "user-voice-line", description: "Speaker", category: "conferences" },

      "participatory_texts_item" => { icon: "bookmark-line", description: "Index item", category: "participatory_texts" }
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
      DEFAULT_RESOURCE_TYPE_ICONS[resource_type.to_s][:icon] || DEFAULT_RESOURCE_TYPE_ICONS["other"][:icon]
    end

    def text_with_resource_icon(resource_name, text)
      output = ""
      output += resource_type_icon resource_name
      output += content_tag :span, text
      output.html_safe
    end
  end
end
