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
    t.integer :url
  end
  create_table :image_attachments do |t|
    t.integer :id
    t.integer :url
  end
end

class Document < ActiveRecord::Base
  attr_expiring_asset_links :body
end
class FileAttachment < ActiveRecord::Base
end
class ImageAttachment < ActiveRecord::Base
end
