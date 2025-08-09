# frozen_string_literal: true

Vips.cache_set_max(0) # Disable all caching to avoid memory issues
Vips.cache_set_max_mem(0) # Disable memory caching to avoid memory issues
Vips.cache_set_max_files(0) # Disable file caching to avoid memory issues
