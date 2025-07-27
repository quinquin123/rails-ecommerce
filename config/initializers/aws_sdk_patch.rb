# Aws::S3::Client.class_eval do
#   def put_object(params = {}, options = {})
#     params.delete(:checksum_algorithm)
#     super(params, options)
#   end
# end