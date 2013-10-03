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

  def test_class_id_path
    ExpiringAssetLinks.configure do |conf|
      conf.fog_directory = /\S+\/(?<name>[a-z_]+)\/[a-z_]+\/(?<id>\d+)/
    end

    file_attachment = FileAttachment.create(name: "test")
    file_path = "https://test.s3-us-east-1.amazonaws.com/uploads/test/file_attachment/asset/#{file_attachment.id}/sample.jpg"
    file_attachment.update_attributes({asset: AssetUploader.new(file_path)})
    document = Document.create(title: "This is the Document Title", body: "<h2>Section One</h2><p>This is the first section in the body of the document.  It includes an image.</p><img src=\"#{file_attachment.send(FileAttachment.uploaders.keys.first).url}\">")

    assert_equal "<h2>Section One</h2><p>This is the first section in the body of the document.  It includes an image.</p><img src=\"FileAttachment{{#{file_attachment.id}}}\">", Document.find(document.id).attributes["body"]
    assert_equal "<h2>Section One</h2><p>This is the first section in the body of the document.  It includes an image.</p><img src=\"#{file_path}?AWSAccessKeyId=XXXXXXXXXXXXXXXXXXXX&amp;Signature=XXXXXXXXXXXXXXXXXXXXXXXXXXX%3D&amp;Expires=2222222222\">", Document.find(document.id).body
  end

  def test_id_class_path
    ExpiringAssetLinks.configure do |conf|
      conf.fog_directory = /\S+\/(?<id>\d+)\/[a-z_]+\/(?<name>[a-z_]+)/
    end

    file_attachment = FileAttachment.create(name: "test")
    file_path = "https://test.s3-us-east-1.amazonaws.com/uploads/test/#{file_attachment.id}/asset/file_attachment/sample.jpg"
    file_attachment.update_attributes({asset: AssetUploader.new(file_path)})
    document = Document.create(title: "This is the Document Title", body: "<h2>Section One</h2><p>This is the first section in the body of the document.  It includes an image.</p><img src=\"#{file_attachment.send(FileAttachment.uploaders.keys.first).url}\">")

    assert_equal "<h2>Section One</h2><p>This is the first section in the body of the document.  It includes an image.</p><img src=\"FileAttachment{{#{file_attachment.id}}}\">", Document.find(document.id).attributes["body"]
    assert_equal "<h2>Section One</h2><p>This is the first section in the body of the document.  It includes an image.</p><img src=\"#{file_path}?AWSAccessKeyId=XXXXXXXXXXXXXXXXXXXX&amp;Signature=XXXXXXXXXXXXXXXXXXXXXXXXXXX%3D&amp;Expires=2222222222\">", Document.find(document.id).body
  end

  def test_default_configuration
    file_attachment = FileAttachment.create(name: "test")
    file_path = "https://test.s3-us-east-1.amazonaws.com/uploads/test/file_attachment/asset/#{file_attachment.id}/sample.jpg"
    file_attachment.update_attributes({asset: AssetUploader.new(file_path)})
    document = Document.create(title: "This is the Document Title", body: "<h2>Section One</h2><p>This is the first section in the body of the document.  It includes an image.</p><img src=\"#{file_attachment.send(FileAttachment.uploaders.keys.first).url}\">")

    assert_equal "<h2>Section One</h2><p>This is the first section in the body of the document.  It includes an image.</p><img src=\"FileAttachment{{#{file_attachment.id}}}\">", Document.find(document.id).attributes["body"]
    assert_equal "<h2>Section One</h2><p>This is the first section in the body of the document.  It includes an image.</p><img src=\"#{file_path}?AWSAccessKeyId=XXXXXXXXXXXXXXXXXXXX&amp;Signature=XXXXXXXXXXXXXXXXXXXXXXXXXXX%3D&amp;Expires=2222222222\">", Document.find(document.id).body
  end

  def test_wrong_type_fog_directory_configuration
    assert_raises(TypeError) { ExpiringAssetLinks.configure { |conf| conf.fog_directory = "" } }
    assert_raises(TypeError) { ExpiringAssetLinks.configure { |conf| conf.fog_directory = "test" } }
    assert_raises(TypeError) { ExpiringAssetLinks.configure { |conf| conf.fog_directory = "\S+\/(?<id>\d+)\/[a-z_]+\/(?<name>[a-z_]+)" } }
  end

  def test_invalid_fog_directory_configuration
    assert_raises(RegexpError) { ExpiringAssetLinks.configure { |conf| conf.fog_directory = // } }
    assert_raises(RegexpError) { ExpiringAssetLinks.configure { |conf| conf.fog_directory = /\S+\/(\d+)\/[a-z_]+\/([a-z_]+)/ } }
    assert_raises(RegexpError) { ExpiringAssetLinks.configure { |conf| conf.fog_directory = /\S+\/(\d+)\/[a-z_]+\/(?<name>[a-z_]+)/ } }
    assert_raises(RegexpError) { ExpiringAssetLinks.configure { |conf| conf.fog_directory = /\S+\/(?<id>\d+)\/[a-z_]+\/([a-z_]+)/ } }
    assert_raises(RegexpError) { ExpiringAssetLinks.configure { |conf| conf.fog_directory = /\S+\/(?<ids>\d+)\/[a-z_]+\/(?<name>[a-z_]+)/ } }
    assert_raises(RegexpError) { ExpiringAssetLinks.configure { |conf| conf.fog_directory = /\S+\/(?<id>\d+)\/[a-z_]+\/(?<names>[a-z_]+)/ } }
  end
  
  def test_extra_names_fog_directory_configuration
    ExpiringAssetLinks.configure do |conf|
      conf.fog_directory = /\S+\/(?<id>\d+)\/(?<mount>[a-z_]+)\/(?<name>[a-z_]+)/
    end

    file_attachment = FileAttachment.create(name: "test")
    file_path = "https://test.s3-us-east-1.amazonaws.com/uploads/test/#{file_attachment.id}/asset/file_attachment/sample.jpg"
    file_attachment.update_attributes({asset: AssetUploader.new(file_path)})
    document = Document.create(title: "This is the Document Title", body: "<h2>Section One</h2><p>This is the first section in the body of the document.  It includes an image.</p><img src=\"#{file_attachment.send(FileAttachment.uploaders.keys.first).url}\">")

    assert_equal "<h2>Section One</h2><p>This is the first section in the body of the document.  It includes an image.</p><img src=\"FileAttachment{{#{file_attachment.id}}}\">", Document.find(document.id).attributes["body"]
    assert_equal "<h2>Section One</h2><p>This is the first section in the body of the document.  It includes an image.</p><img src=\"#{file_path}?AWSAccessKeyId=XXXXXXXXXXXXXXXXXXXX&amp;Signature=XXXXXXXXXXXXXXXXXXXXXXXXXXX%3D&amp;Expires=2222222222\">", Document.find(document.id).body
  end

  def test_non_matching_fog_directory_configuration
    # there is essentially no way of knowing that a non-matching URL string should have matched the Regexp,
    # no validation of any type is performed when adding or removing asset links
    ExpiringAssetLinks.configure do |conf|
      conf.fog_directory = /\S+\/(?<id>\d+)\/[a-z_]+\/(?<name>[a-z_]+)\/error/
    end

    file_attachment = FileAttachment.create(name: "test")
    file_path = "https://test.s3-us-east-1.amazonaws.com/uploads/test/#{file_attachment.id}/asset/file_attachment/sample.jpg"
    file_attachment.update_attributes({asset: AssetUploader.new(file_path)})
    document = Document.create(title: "This is the Document Title", body: "<h2>Section One</h2><p>This is the first section in the body of the document.  It includes an image.</p><img src=\"#{file_attachment.send(FileAttachment.uploaders.keys.first).url}\">")

    assert_equal "<h2>Section One</h2><p>This is the first section in the body of the document.  It includes an image.</p><img src=\"#{file_attachment.send(FileAttachment.uploaders.keys.first).url}\">", Document.find(document.id).attributes["body"]
    assert_equal "<h2>Section One</h2><p>This is the first section in the body of the document.  It includes an image.</p><img src=\"#{file_attachment.send(FileAttachment.uploaders.keys.first).url}\">", Document.find(document.id).body
  end

  def test_multiple_assets
    ExpiringAssetLinks.configure do |conf|
      conf.fog_directory = /\S+\/(?<id>\d+)\/[a-z_]+\/(?<name>[a-z_]+)/
    end

    file_attachment_a = FileAttachment.create(name: "test")
    file_path_a = "https://test.s3-us-east-1.amazonaws.com/uploads/test/#{file_attachment_a.id}/asset/file_attachment/sample.jpg"
    file_attachment_a.update_attributes({asset: AssetUploader.new(file_path_a)})
    file_attachment_b = FileAttachment.create(name: "test")
    file_path_b = "https://test.s3-us-east-1.amazonaws.com/uploads/test/#{file_attachment_b.id}/asset/file_attachment/sample.jpg"
    file_attachment_b.update_attributes({asset: AssetUploader.new(file_path_b)})
    document = Document.create(title: "This is the Document Title", body: "<h2>Section One</h2><p>This is the first section in the body of the document.  It includes an image.</p><img src=\"#{file_attachment_a.send(FileAttachment.uploaders.keys.first).url}\"><p>And another image.</p><img src=\"#{file_attachment_b.send(FileAttachment.uploaders.keys.first).url}\">")

    assert_equal "<h2>Section One</h2><p>This is the first section in the body of the document.  It includes an image.</p><img src=\"FileAttachment{{#{file_attachment_a.id}}}\"><p>And another image.</p><img src=\"FileAttachment{{#{file_attachment_b.id}}}\">", Document.find(document.id).attributes["body"]
    assert_equal "<h2>Section One</h2><p>This is the first section in the body of the document.  It includes an image.</p><img src=\"#{file_path_a}?AWSAccessKeyId=XXXXXXXXXXXXXXXXXXXX&amp;Signature=XXXXXXXXXXXXXXXXXXXXXXXXXXX%3D&amp;Expires=2222222222\"><p>And another image.</p><img src=\"#{file_path_b}?AWSAccessKeyId=XXXXXXXXXXXXXXXXXXXX&amp;Signature=XXXXXXXXXXXXXXXXXXXXXXXXXXX%3D&amp;Expires=2222222222\">", Document.find(document.id).body
  end

  def test_with_leading_forward_slash_path
    ExpiringAssetLinks.configure do |conf|
      conf.fog_directory = /\/\S+\/(?<name>[a-z_]+)\/[a-z_]+\/(?<id>\d+)/
    end

    file_attachment = FileAttachment.create(name: "test")
    file_path = "https://test.s3-us-east-1.amazonaws.com/uploads/test/file_attachment/asset/#{file_attachment.id}/sample.jpg"
    file_attachment.update_attributes({asset: AssetUploader.new(file_path)})
    document = Document.create(title: "This is the Document Title", body: "<h2>Section One</h2><p>This is the first section in the body of the document.  It includes an image.</p><img src=\"#{file_attachment.send(FileAttachment.uploaders.keys.first).url}\">")

    assert_equal "<h2>Section One</h2><p>This is the first section in the body of the document.  It includes an image.</p><img src=\"FileAttachment{{#{file_attachment.id}}}\">", Document.find(document.id).attributes["body"]
    assert_equal "<h2>Section One</h2><p>This is the first section in the body of the document.  It includes an image.</p><img src=\"#{file_path}?AWSAccessKeyId=XXXXXXXXXXXXXXXXXXXX&amp;Signature=XXXXXXXXXXXXXXXXXXXXXXXXXXX%3D&amp;Expires=2222222222\">", Document.find(document.id).body
  end

end
