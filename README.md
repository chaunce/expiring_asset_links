# expiring_asset_links

CarrierWave FOG Expiring Asset Links

Handles storing and generating CarrierWave FOG expiring asset link stored in string and text attributes of ActiveRecord objects

This is helpful when using a WYSIWYG that inserts and previews assets directly from S3 using full S3 URLs.  These URLs need to be updated each time the object is reloaded.  When used in conjunction with CarrierWave and FOG gems, this gem will automatically update these links for you.

## Installation

  gem install expiring_asset_links

## Usage

### Your model

    class Document
      attr_expiring_asset_links :body
      
    end

