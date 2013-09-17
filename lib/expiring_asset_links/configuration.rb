module ExpiringAssetLinks
  module Configuration
    VALID_CONFIG_KEYS = [:fog_directory].freeze
    DEFAULT_FOG_DIRECTORY ||= /\S+\/(?<name>[a-z_]+)\/[a-z_]+\/(?<id>\d+)/
    attr_accessor *VALID_CONFIG_KEYS

    def self.extended(base)
      base.reset
    end

    def reset
      self.fog_directory = DEFAULT_FOG_DIRECTORY
    end

    def configure
      yield self
      raise "The configuration option `fog_directory` must be assigned Regexp." unless self.fog_directory.is_a?(Regexp)
    end
  end
end
