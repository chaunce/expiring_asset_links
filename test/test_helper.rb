$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift(File.dirname(__FILE__))
require 'expiring_asset_links'

require 'active_record'
require 'sqlite3'
require 'carrierwave'
require 'fog'
require 'test/unit'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

ActiveRecord::Schema.define(:version => 1) do
  create_table :documents do |t|
    t.integer :id
    t.string :title
    t.text :body
  end
  create_table :file_attachments do |t|
    t.integer :id
    t.integer :name
    t.binary  :asset
  end
  create_table :image_attachments do |t|
    t.integer :id
    t.integer :name
    t.binary  :asset
  end
end

module HasAssets
  module ClassMethods
    def serialize_asset
      serialize :asset
    end
    def uploaders
      { asset: AssetUploader }
    end
  end

  def self.included(base)
    base.extend(ClassMethods).serialize_asset
  end
end

class Document < ActiveRecord::Base
  attr_expiring_asset_links :body
end

class FileAttachment < ActiveRecord::Base
  include HasAssets
end

class ImageAttachment < ActiveRecord::Base
  include HasAssets
end

class AssetUploader < Struct.new(:my_url)
  def url(*ignore)
    "#{self.my_url}?AWSAccessKeyId=XXXXXXXXXXXXXXXXXXXX&amp;Signature=XXXXXXXXXXXXXXXXXXXXXXXXXXX%3D&amp;Expires=2222222222"
  end
end
    
  
