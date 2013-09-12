# expiring_asset_links

CarrierWave FOG Expiring Asset Links

Handles storing and generating CarrierWave FOG expiring asset link stored in string and text attributes of ActiveRecord objects

This is helpful when using a WYSIWYG that inserts and previews assets directly from S3 using full S3 URLs.  These URLs need to be updated each time the object is reloaded.  When used in conjunction with CarrierWave and FOG gems, this gem will automatically update these links for you.

## Installation

    gem install expiring_asset_links

## Usage

### name your uploader mount `:asset`

    class Images
      mount_uploader :asset, ImageUploader
      
    end

### specify the fields that will contain :asset links

    class Document
      attr_expiring_asset_links :body
      
    end
    
    class Article
      attr_expiring_asset_links :summary, :body
      
    end
