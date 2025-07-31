class ProductSerializer < ActiveModel::Serializer
  attributes :id, :title, :price, :description, :preview_image_url

  belongs_to :category

  def preview_image_url
    if object.preview_image.attached?
      Rails.application.routes.url_helpers.rails_blob_url(object.preview_image, only_path: true)
    else
      nil
    end
  end
end
