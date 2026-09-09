# frozen_string_literal: true

require "vips"

Vips.cache_set_max(0) # Disable all caching to avoid memory issues
Vips.cache_set_max_mem(0) # Disable memory caching to avoid memory issues
Vips.cache_set_max_files(0) # Disable file caching to avoid memory issues

# image_processing 2.x calls Vips.block_untrusted(true) on load as an XXE/SSRF mitigation,
# which blocks SVG loading. SharesController renders SVGs from our own ERB templates (not
# user-uploaded), so it's safe to unblock this loader specifically rather than disabling
# untrusted-input protection globally.
Vips.block("VipsForeignLoadSvg", false)
