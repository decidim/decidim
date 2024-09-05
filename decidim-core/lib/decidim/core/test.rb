# frozen_string_literal: true

require "decidim/core/test/shared_examples/acts_as_author_examples"
require "decidim/core/test/shared_examples/admin_log_presenter_examples"
require "decidim/core/test/shared_examples/authorable"
require "decidim/core/test/shared_examples/authorization_shared_context"
require "decidim/core/test/shared_examples/coauthorable"
require "decidim/core/test/shared_examples/editor_shared_examples"
require "decidim/core/test/shared_examples/endorsable"
require "decidim/core/test/shared_examples/publicable"
require "decidim/core/test/shared_examples/localised_email"
require "decidim/core/test/shared_examples/logo_email"
require "decidim/core/test/shared_examples/has_attachments"
require "decidim/core/test/shared_examples/has_attachment_collections"
require "decidim/core/test/shared_examples/has_component"
require "decidim/core/test/shared_examples/has_taxonomies"
require "decidim/core/test/shared_examples/has_scope"
require "decidim/core/test/shared_examples/has_category"
require "decidim/core/test/shared_examples/has_reference"
require "decidim/core/test/shared_examples/comments_examples"
require "decidim/core/test/shared_examples/counts_commentators_as_newsletter_participants"
require "decidim/core/test/shared_examples/announcements_examples"
require "decidim/core/test/shared_examples/process_announcements_examples"
require "decidim/core/test/shared_examples/reportable"
require "decidim/core/test/shared_examples/reports_examples"
require "decidim/core/test/shared_examples/comments_reports_examples"
require "decidim/core/test/shared_examples/paginated_resource_examples"
require "decidim/core/test/shared_examples/errors"
require "decidim/core/test/shared_examples/scope_helper_examples"
require "decidim/core/test/shared_examples/follows_examples"
require "decidim/core/test/shared_examples/simple_event"
require "decidim/core/test/shared_examples/component_type"
require "decidim/core/test/shared_examples/taxonomizable_resource_examples"
require "decidim/core/test/shared_examples/scopable_resource_examples"
require "decidim/core/test/shared_examples/fingerprint_examples"
require "decidim/core/test/shared_examples/searchable_results_examples"
require "decidim/core/test/shared_examples/has_space_in_mcell_examples"
require "decidim/core/test/shared_examples/railtie_examples"
require "decidim/core/test/shared_examples/edit_link_shared_examples"
require "decidim/core/test/shared_examples/endorsements_controller_shared_context"
require "decidim/core/test/shared_examples/amendable/create_amendment_draft_examples"
require "decidim/core/test/shared_examples/amendable/update_amendment_draft_examples"
require "decidim/core/test/shared_examples/amendable/destroy_amendment_draft_examples"
require "decidim/core/test/shared_examples/amendable/publish_amendment_draft_examples"
require "decidim/core/test/shared_examples/amendable/withdraw_amendment_examples"
require "decidim/core/test/shared_examples/amendable/reject_amendment_examples"
require "decidim/core/test/shared_examples/amendable/promote_amendment_examples"
require "decidim/core/test/shared_examples/amendable/amendment_form_examples"
require "decidim/core/test/shared_examples/amendable/accept_amendment_examples"
require "decidim/core/test/shared_examples/resourceable"
require "decidim/core/test/shared_examples/taxonomy_settings"
require "decidim/core/test/shared_examples/amendable/amendment_created_event_examples"
require "decidim/core/test/shared_examples/amendable/amendment_event_examples"
require "decidim/core/test/shared_examples/amendable/amendment_promoted_event_examples"
require "decidim/core/test/shared_examples/uncommentable_component_examples"
require "decidim/core/test/shared_examples/searchable_resources_shared_context"
require "decidim/core/test/shared_examples/searchable_participatory_space_examples"
require "decidim/core/test/shared_examples/has_private_users"
require "decidim/core/test/shared_examples/with_endorsable_permissions_examples"
require "decidim/core/test/shared_examples/system_endorse_resource_examples"
require "decidim/core/test/shared_examples/rich_text_editor_examples"
require "decidim/core/test/shared_examples/permissions"
require "decidim/core/test/shared_examples/admin_resource_gallery_examples"
require "decidim/core/test/shared_examples/map_examples"
require "decidim/core/test/shared_examples/preview_component_with_share_token_examples"
require "decidim/core/test/shared_examples/manage_component_share_tokens"
require "decidim/core/test/shared_examples/metric_manage_shared_context"
require "decidim/core/test/shared_examples/resource_search_examples"
require "decidim/core/test/shared_examples/static_pages_examples"
require "decidim/core/test/shared_examples/controller_render_views"
require "decidim/core/test/shared_examples/share_link_examples"
require "decidim/core/test/shared_examples/categories_container_examples"
require "decidim/core/test/shared_examples/assembly_announcements_examples"
require "decidim/core/test/shared_examples/translated_event_examples"
require "decidim/core/test/shared_examples/conversations_examples"
require "decidim/core/test/shared_examples/resource_endorsed_event_examples"
require "decidim/core/test/shared_examples/versions_controller_examples"
require "decidim/core/test/shared_examples/mcell_examples"
require "decidim/core/test/shared_examples/digest_mail_examples"
require "decidim/core/test/shared_examples/hideable_resource_examples"
require "decidim/core/test/shared_examples/active_support_examples"
require "decidim/core/test/shared_examples/statistics_cell_examples"
require "decidim/core/test/shared_examples/resource_locator_presenter_examples"
