class VideoThumbnailJob < ApplicationJob
  queue_as :default
  FFMPEG_OPTIONS = {
    quality: 2,          
    seek_time: '00:00:01', 
    resolution: '800x600' 
  }.freeze

  def perform(product_id)
    product = Product.find(product_id)
    return unless product.video.attached?
    temp_video = download_video(product)
    thumbnail_path = generate_thumbnail(temp_video)
    attach_thumbnail(product, thumbnail_path)
  rescue => e
    Rails.logger.error "Thumbnail generation failed: #{e.message}"
    AdminMailer.thumbnail_error(product, e.message).deliver_later
  ensure
    cleanup_temp_files(temp_video, thumbnail_path)
  end
  private
  def download_video(product)
    product.video.download_blob_to_tempfile
  end

  def generate_thumbnail(video_file)
    output_path = "#{Dir.tmpdir}/#{SecureRandom.uuid}.jpg"
    command = [
      'ffmpeg',
      '-i', video_file.path,
      '-ss', FFMPEG_OPTIONS[:seek_time],
      '-vframes', '1',
      '-q:v', FFMPEG_OPTIONS[:quality].to_s,
      '-s', FFMPEG_OPTIONS[:resolution],
      '-y', 
      output_path
    ].join(' ')
    success = system(command)
    raise "FFmpeg failed with exit status #{$?.exitstatus}" unless success && File.exist?(output_path)
    output_path
  end

  def attach_thumbnail(product, thumbnail_path)
    product.video_thumbnail.attach(
      io: File.open(thumbnail_path),
      filename: "#{product.video.filename.base}.jpg",
      content_type: 'image/jpeg'
    )
  end
  
  def cleanup_temp_files(*files)
    files.each do |file|
      next unless file && File.exist?(file)
      File.delete(file)
    rescue => e
      Rails.logger.error "Failed to cleanup temp file #{file}: #{e.message}"
    end
  end
end