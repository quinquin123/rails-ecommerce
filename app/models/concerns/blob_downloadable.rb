module BlobDownloadable
  extend ActiveSupport::Concern
  def download_blob_to_tempfile
    tempfile = Tempfile.new([blob.filename.base, blob.filename.extension_with_delimiter])
    tempfile.binwrite(blob.download)
    tempfile.close
    tempfile
  end
end
