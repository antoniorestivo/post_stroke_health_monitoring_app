Rails.application.config.content_security_policy do |policy|
  # Default: only load resources from our own origin
  policy.default_src :self

  # JavaScript: only from self (no inline scripts)
  policy.script_src :self

  # Styles: Tailwind injects some inline styles
  policy.style_src :self, :unsafe_inline

  # Images: allow self, https URLs, and data URIs (charts, icons, etc.)
  policy.img_src :self, :https, :data

  # Fonts (if any via Tailwind or browser defaults)
  policy.font_src :self, :https, :data

  # API / XHR / WebSocket connections
  connect_sources = [:self]
  frontend_origin = ENV["FRONTEND_APP_ORIGIN"]
  connect_sources << frontend_origin if frontend_origin.present?
  policy.connect_src(*connect_sources)

  # Disallow Flash, plugins, etc.
  policy.object_src :none

  # Prevent clickjacking
  policy.frame_ancestors :none

  # Base URI lockdown
  policy.base_uri :self

  # Form submissions only to self
  policy.form_action :self
end
