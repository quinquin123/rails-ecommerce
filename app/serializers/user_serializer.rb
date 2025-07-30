class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :name, :role, :status, :created_at, :updated_at
end
