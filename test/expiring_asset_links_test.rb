require File.expand_path('../test_helper', __FILE__)

class ExpiringAssetLinksTest < Test::Unit::TestCase

  def setup
    CarrierWave.configure do |config|
      # config.cache_dir = "#{Rails.root}/tmp/assets"
      # 
      # config.root = Rails.root.join('tmp')
      # config.cache_dir = "assets"
      # config.fog_credentials = {
      #   :provider               => 'AWS',
      #   :aws_access_key_id      => ENV['AWS_KEY'],
      #   :aws_secret_access_key  => ENV['S3_SECRET'],
      #   :region                 => 'us-west-1'
      # }
      config.fog_directory  = "test"
      # config.fog_public     = false
    end
  end

  def test_should_assert_true
    file_attachment = FileAttachment.create(name: "test", asset: AssetUploader.new("https://test.s3-us-east-1.amazonaws.com/uploads/test/file_attachment/asset/1/sample.jpg"))
    document = Document.create(title: "This is the Document Title", body: "<h2>Section One</h2><p>This is the first section in the body of the document.  It includes an image.</p><img src=\"#{file_attachment.asset.url}\">")

    assert_equal "<h2>Section One</h2><p>This is the first section in the body of the document.  It includes an image.</p><img src=\"FileAttachment{{1}}\">", Document.find(document.id).attributes["body"]
    assert_equal "<h2>Section One</h2><p>This is the first section in the body of the document.  It includes an image.</p><img src=\"https://test.s3-us-east-1.amazonaws.com/uploads/test/file_attachment/asset/1/sample.jpg?AWSAccessKeyId=XXXXXXXXXXXXXXXXXXXX&amp;Signature=XXXXXXXXXXXXXXXXXXXXXXXXXXX%3D&amp;Expires=2222222222\">", Document.find(document.id).body
  end

end
