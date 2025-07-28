require 'rails_helper'

RSpec.describe Product, type: :model do
  let(:seller) { create(:user) }
  let(:category) { create(:category) }
  let(:product) { build(:product, seller: seller, category: category) }

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:price) }
    it { should validate_presence_of(:status) }

    it "defines string-backed enum for status" do
      expect(Product.statuses).to eq({ "active" => "active", "moderated" => "moderated", "deleted" => "deleted" })
    end

    it 'validates media presence' do
      product.preview_image.detach
      product.video.detach
      product.valid?
      expect(product.errors[:base]).to include("You must attach either a video or an image")
    end

    it 'validates video format' do
      video = fixture_file_upload('test.txt', 'text/plain')
      product.video.attach(video)
      product.valid?
      expect(product.errors[:video]).to include("must be a MP4, MOV or AVI file")
    end

    it 'validates image format' do
      image = fixture_file_upload('test.txt', 'text/plain')
      product.preview_image.attach(image)
      product.valid?
      expect(product.errors[:preview_image]).to include("must be a JPEG, PNG or GIF file")
    end
  end

  describe 'associations' do
    it { should belong_to(:seller).class_name('User') }
    it { should belong_to(:category) }
    it { should have_many(:cart_items) }
    it { should have_many(:reviews).dependent(:destroy) }
    it { should have_many(:order_items).dependent(:destroy) }
  end

  describe 'attachments' do
    it { should have_one_attached(:video) }
    it { should have_one_attached(:preview_image) }
    it { should have_one_attached(:downloadable_asset) }
    it { should have_one_attached(:video_thumbnail) }
  end

  describe '#media_type' do
    it 'returns :video if video attached' do
      video = fixture_file_upload(Rails.root.join('spec/fixtures/files/sample.mp4'), 'video/mp4')
      product.video.attach(video)
      expect(product.media_type).to eq(:video)
    end

    it 'returns :image if only image is attached' do
      image = fixture_file_upload(Rails.root.join('spec/fixtures/files/image.jpg'), 'image/jpeg')
      product.preview_image.attach(image)
      expect(product.media_type).to eq(:image)
    end
  end

  describe '#downloadable_by?' do
    let(:buyer) { create(:user) }

    it 'returns true if price is zero' do
      product = build(:product, seller: seller, category: category, price: 0)
      expect(product.downloadable_by?(buyer)).to be true
    end

    it 'returns true if user is seller' do
      product = build(:product, seller: seller, category: category, price: 100)
      expect(product.downloadable_by?(seller)).to be true
    end

    it 'returns true if user purchased product' do
      product = create(:product, seller: seller, category: category)
      order = create(:order, buyer: buyer, status: "success")
      create(:order_item, order: order, product: product)

      expect(product.downloadable_by?(buyer)).to be true
    end

    it 'returns false otherwise' do
      product = build(:product, seller: seller, category: category, price: 100)
      expect(product.downloadable_by?(buyer)).to be false
    end
  end

  describe 'callbacks' do
    it 'generates thumbnail for video after create' do
      ActiveJob::Base.queue_adapter = :test

      video_path = Rails.root.join('spec/fixtures/files/sample.mp4')
      product = create(:product, seller: seller, category: category)
      product.video.attach(
        io: File.open(video_path),
        filename: 'sample.mp4',
        content_type: 'video/mp4'
      )
      expect {
        product.save!
      }.to have_enqueued_job(VideoThumbnailJob).with(product.id)
    end

    it 'stores URLs after save when attachments present' do
      image = fixture_file_upload(Rails.root.join('spec/fixtures/files/image.jpg'), 'image/jpeg')
      asset = fixture_file_upload(Rails.root.join('spec/fixtures/files/page.pdf'), 'application/pdf')
      
      product.preview_image.attach(image)
      product.downloadable_asset.attach(asset)
      
      # Debug: kiểm tra attachments có được attach không
      expect(product.preview_image.attached?).to be true
      expect(product.downloadable_asset.attached?).to be true
      
      product.save!
      product.reload
      
      # Debug: in ra giá trị thực tế
      puts "Preview URL: #{product.preview_url}"
      puts "Download URL: #{product.download_url}"
      
      expect(product.preview_url).not_to be_nil
      expect(product.download_url).not_to be_nil
    end
  end
end