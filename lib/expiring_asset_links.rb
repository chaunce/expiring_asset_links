require 'active_record'

module ExpiringAssetLinks
  autoload :Version, 'expiring_asset_links/version'

  def self.extended(base)
    base.class_eval do
      @expiring_asset_link_attributes = []
      include InstanceMethods
    end
  end

  def attr_expiring_asset_links(*attributes)
    before_save :remove_all_asset_tags!
    attributes.each do |attribute|
      define_method(attribute) do
        add_asset_tags(attribute.to_sym)
      end

      expiring_asset_link_attributes << attribute.to_sym
    end
  end

  def attr_expiring_asset_links?(attribute)
    expiring_asset_link_attributes.include?(attribute.to_sym)
  end

  def expiring_asset_link_attributes
    @expiring_asset_link_attributes ||= superclass.expiring_asset_link_attributes.dup
  end

  module InstanceMethods
    protected

    def remove_asset_tags(attribute)
      self[attribute.to_sym].gsub(/https:\/\/#{CarrierWave::Uploader::Base.fog_directory}\.s3.\S+\/([a-z_]+)\/[a-z_]+\/(\d+)\/\S+Expires=[\d]{10}/) { "#{$1.classify}{{#{$2}}}" }
    end

    def add_asset_tags(attribute)
      self[attribute.to_sym].gsub(/([A-Za-z]+)\{\{(\d+)\}\}/) { $1.constantize.find($2).asset.url(:default) }
    end

    def remove_all_asset_tags!
      self.class.expiring_asset_link_attributes.each{ |attribute| self.send(:"#{attribute}=", remove_asset_tags(attribute.to_sym)) }
    end

  end
end

module AttrExpiringAssetLinks
  module ActiveRecord
    def self.extended(base) # :nodoc:
      base.class_eval do
        class << self
          alias_method_chain :attr_expiring_asset_links, :defined_attributes
        end
      end
    end

    protected

    def attr_expiring_asset_links_with_defined_attributes(*attrs)
      define_attribute_methods rescue nil
      attr_expiring_asset_links_without_defined_attributes *attrs
    end
  end

end

Object.extend ExpiringAssetLinks
ActiveRecord::Base.extend AttrExpiringAssetLinks::ActiveRecord
