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
      raise TypeError, "expected fog_directory to be a Regexp" unless self.fog_directory.is_a?(Regexp)
      missing_names = ["name", "id"] - self.fog_directory.names
      raise RegexpError, "fog_directory must capture #{missing_names.join(' and ')}" unless missing_names.empty?
    end
  end
end
