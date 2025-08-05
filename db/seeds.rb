categories = [
  { name: "Web Development" },
  { name: "Mobile Apps" },
  { name: "Graphics & Design" },
  { name: "Photography" },
  { name: "Audio" },
  { name: "Video" },
  { name: "3D Models" },
  { name: "Fonts" }
]

created_categories = categories.map do |cat_data|
  Category.find_or_create_by(name: cat_data[:name])
end


# Tạo Users (Sellers & Buyers)
sellers_data = [
  { name: "Alice Johnson", email: "alice@gmail.com", role: "seller" },
  { name: "Bob Smith", email: "bob@gmail.com", role: "seller" },
  { name: "Carol Davis", email: "carol@gmail.com", role: "seller" },
  { name: "David Wilson", email: "david@gmail.com", role: "seller" },
  { name: "Eva Brown", email: "eva@gmail.com", role: "seller" }
]

buyers_data = [
  { name: "Frank Miller", email: "frank@gmail.com", role: "buyer" },
  { name: "Grace Lee", email: "grace@gmail.com", role: "buyer" },
  { name: "Henry Taylor", email: "henry@gmail.com", role: "buyer" }
]

admin_data = { name: "Admin User", email: "admin@gmail.com", role: "admin" }

# Tạo sellers
sellers = sellers_data.map do |seller_data|
  User.find_or_create_by(email: seller_data[:email]) do |user|
    user.name = seller_data[:name]
    user.role = seller_data[:role]
    user.password = "password123"
    user.password_confirmation = "password123"
  end
end

# Tạo buyers
buyers = buyers_data.map do |buyer_data|
  User.find_or_create_by(email: buyer_data[:email]) do |user|
    user.name = buyer_data[:name]
    user.role = buyer_data[:role]
    user.password = "password123"
    user.password_confirmation = "password123"
  end
end

# Tạo admin
admin = User.find_or_create_by(email: admin_data[:email]) do |user|
  user.name = admin_data[:name]
  user.role = admin_data[:role]
  user.password = "password123"
  user.password_confirmation = "password123"
end


# Tạo Products 
products_data = [
  {
    title: "Modern React Dashboard Template",
    description: "A comprehensive dashboard template built with React, featuring dark/light mode, responsive design, and modern UI components. Perfect for admin panels and business applications.",
    price: 49.99,
    category: "Web Development",
    seller_email: "alice@gmail.com",
    preview_url: "https://via.placeholder.com/400x300/667eea/ffffff?text=React+Dashboard",
    download_url: "https://example.com/downloads/react-dashboard.zip",
    tags: ["react", "dashboard", "responsive", "modern", "dark-mode"],
    status: "active",
    average_rating: 4.8,
    reviews_count: 23
  },
  {
    title: "E-commerce Website Template",
    description: "Complete e-commerce solution with shopping cart, payment integration, and admin panel. Built with HTML5, CSS3, and JavaScript.",
    price: 79.99,
    category: "Web Development", 
    seller_email: "bob@gmail.com",
    preview_url: "https://via.placeholder.com/400x300/764ba2/ffffff?text=E-commerce",
    download_url: "https://example.com/downloads/ecommerce-template.zip",
    tags: ["ecommerce", "html5", "css3", "responsive", "professional"],
    status: "active",
    average_rating: 4.6,
    reviews_count: 31
  },
  {
    title: "Mobile App UI Kit",
    description: "Beautiful iOS and Android app UI kit with 50+ screens, components, and design elements. Sketch and Figma files included.",
    price: 34.99,
    category: "Mobile Apps",
    seller_email: "carol@gmail.com",
    preview_url: "https://via.placeholder.com/400x300/f093fb/ffffff?text=Mobile+UI+Kit",
    download_url: "https://example.com/downloads/mobile-ui-kit.zip",
    tags: ["mobile-first", "ui-kit", "ios", "android", "components"],
    status: "active",
    average_rating: 4.9,
    reviews_count: 15
  },
  {
    title: "Vector Icon Collection",
    description: "Premium collection of 500+ vector icons in multiple formats (SVG, PNG, AI). Perfect for web and mobile applications.",
    price: 24.99,
    category: "Graphics & Design",
    seller_email: "david@gmail.com",
    preview_url: "https://via.placeholder.com/400x300/fbbf24/ffffff?text=Icon+Collection",
    download_url: "https://example.com/downloads/vector-icons.zip",
    tags: ["icons", "vector", "svg", "premium", "creative"],
    status: "active",
    average_rating: 4.7,
    reviews_count: 42
  },
  {
    title: "Stock Photography Bundle",
    description: "High-quality stock photos for business, technology, and lifestyle. 100 images in 4K resolution with commercial license.",
    price: 59.99,
    category: "Photography",
    seller_email: "eva@gmail.com",
    preview_url: "https://via.placeholder.com/400x300/10b981/ffffff?text=Stock+Photos",
    download_url: "https://example.com/downloads/stock-photos.zip",
    tags: ["photography", "4k", "commercial", "business", "lifestyle"],
    status: "moderated", 
    average_rating: 0.0,
    reviews_count: 0
  },
  {
    title: "Vue.js Portfolio Template",
    description: "Clean and modern portfolio template for developers and designers. Built with Vue.js and includes smooth animations.",
    price: 39.99,
    category: "Web Development",
    seller_email: "alice@gmail.com",
    preview_url: "https://via.placeholder.com/400x300/8b5cf6/ffffff?text=Vue+Portfolio",
    download_url: "https://example.com/downloads/vue-portfolio.zip",
    tags: ["vue", "portfolio", "clean", "animations", "developer"],
    status: "active",
    average_rating: 4.5,
    reviews_count: 18
  },
  {
    title: "Bootstrap Admin Panel",
    description: "Comprehensive admin panel template with Bootstrap 5, charts, tables, and form components. Fully responsive and customizable.",
    price: 44.99,
    category: "Web Development",
    seller_email: "bob@gmail.com",
    preview_url: "https://via.placeholder.com/400x300/ef4444/ffffff?text=Bootstrap+Admin",
    download_url: "https://example.com/downloads/bootstrap-admin.zip",
    tags: ["bootstrap", "admin-panel", "responsive", "customizable", "charts"],
    status: "active",
    average_rating: 4.4,
    reviews_count: 27
  },
  {
    title: "3D Character Models Pack",
    description: "Collection of 10 low-poly 3D character models, rigged and ready for animation. Compatible with Blender, Maya, and Unity.",
    price: 89.99,
    category: "3D Models",
    seller_email: "carol@gmail.com",
    preview_url: "https://via.placeholder.com/400x300/06b6d4/ffffff?text=3D+Characters",
    download_url: "https://example.com/downloads/3d-characters.zip",
    tags: ["3d", "characters", "low-poly", "rigged", "unity"],
    status: "deleted", 
    average_rating: 0.0,
    reviews_count: 0
  },
  {
    title: "Modern Font Family",
    description: "Contemporary font family with 8 weights and italic versions. Perfect for branding, web design, and print materials.",
    price: 29.99,
    category: "Fonts",
    seller_email: "david@gmail.com",
    preview_url: "https://via.placeholder.com/400x300/84cc16/ffffff?text=Font+Family",
    download_url: "https://example.com/downloads/modern-fonts.zip",
    tags: ["fonts", "typography", "modern", "branding", "print"],
    status: "active",
    average_rating: 4.6,
    reviews_count: 12
  },
  {
    title: "Ambient Music Collection",
    description: "Royalty-free ambient music tracks perfect for videos, podcasts, and presentations. High-quality WAV and MP3 formats.",
    price: 19.99,
    category: "Audio",
    seller_email: "eva@gmail.com",
    preview_url: "https://via.placeholder.com/400x300/f59e0b/ffffff?text=Ambient+Music",
    download_url: "https://example.com/downloads/ambient-music.zip",
    tags: ["ambient", "royalty-free", "music", "wav", "mp3"],
    status: "active",
    average_rating: 4.8,
    reviews_count: 9
  },
  {
    title: "Landing Page Template",
    description: "High-converting landing page template with call-to-action sections, testimonials, and contact forms. SEO optimized.",
    price: 54.99,
    category: "Web Development",
    seller_email: "alice@gmail.com",
    preview_url: "https://via.placeholder.com/400x300/ec4899/ffffff?text=Landing+Page",
    download_url: "https://example.com/downloads/landing-page.zip",
    tags: ["landing-page", "conversion", "seo-friendly", "testimonials", "forms"],
    status: "moderated", 
    average_rating: 0.0,
    reviews_count: 0
  },
  {
    title: "Video Intro Templates",
    description: "Professional video intro templates for YouTube, social media, and presentations. After Effects project files included.",
    price: 37.99,
    category: "Video",
    seller_email: "bob@gmail.com",
    preview_url: "https://via.placeholder.com/400x300/6366f1/ffffff?text=Video+Intros",
    download_url: "https://example.com/downloads/video-intros.zip",
    tags: ["video", "intro", "after-effects", "youtube", "social-media"],
    status: "active",
    average_rating: 4.3,
    reviews_count: 8
  },
  {
    title: "WordPress Blog Theme",
    description: "Minimalist WordPress theme for bloggers and writers. Optimized for speed and SEO with multiple layout options.",
    price: 42.99,
    category: "Web Development",
    seller_email: "carol@gmail.com",
    preview_url: "https://via.placeholder.com/400x300/22c55e/ffffff?text=WordPress+Theme",
    download_url: "https://example.com/downloads/wordpress-theme.zip",
    tags: ["wordpress", "blog", "minimal", "seo-friendly", "fast-loading"],
    status: "deleted", 
    average_rating: 4.2,
    reviews_count: 14
  },
  {
    title: "Digital Art Brushes Pack",
    description: "Collection of digital art brushes for Photoshop and Procreate. Includes texture, watercolor, and sketch brushes.",
    price: 18.99,
    category: "Graphics & Design",
    seller_email: "david@gmail.com",
    preview_url: "https://via.placeholder.com/400x300/a855f7/ffffff?text=Art+Brushes",
    download_url: "https://example.com/downloads/art-brushes.zip",
    tags: ["digital-art", "brushes", "photoshop", "procreate", "texture"],
    status: "active",
    average_rating: 4.7,
    reviews_count: 21
  },
  {
    title: "Corporate Presentation Template",
    description: "Professional PowerPoint and Google Slides template for business presentations. Includes charts, infographics, and layouts.",
    price: 26.99,
    category: "Graphics & Design",
    seller_email: "eva@gmail.com",
    preview_url: "https://via.placeholder.com/400x300/f97316/ffffff?text=Presentation",
    download_url: "https://example.com/downloads/presentation-template.zip",
    tags: ["presentation", "powerpoint", "business", "professional", "charts"],
    status: "active",
    average_rating: 4.1,
    reviews_count: 6
  }
]
# Tạo products
products_data.each do |product_data|
  category = created_categories.find { |cat| cat.name == product_data[:category] }
  seller = User.find_by(email: product_data[:seller_email])
  
  # Debug info
  unless category
    puts "Category '#{product_data[:category]}' not found for product: #{product_data[:title]}"
    next
  end
  
  unless seller
    puts "Seller '#{product_data[:seller_email]}' not found for product: #{product_data[:title]}"
    next
  end
  
  product = Product.create!(
    title: product_data[:title],
    description: product_data[:description],
    price: product_data[:price],
    category: category,
    seller: seller,
    preview_url: product_data[:preview_url],
    download_url: product_data[:download_url],
    tags: product_data[:tags],
    status: product_data[:status],
    average_rating: product_data[:average_rating],
    reviews_count: product_data[:reviews_count]
  )
  
  puts "Created product: #{product.title} (ID: #{product.id})"
rescue ActiveRecord::RecordInvalid => e
  puts "Validation failed for product: #{product_data[:title]}"
  puts "  Errors: #{e.record.errors.full_messages.join(', ')}"
rescue StandardError => e
  puts "Failed to create product: #{product_data[:title]}"
  puts "Error: #{e.message}"
  puts "Backtrace: #{e.backtrace.first(3).join("\n")}"
end

puts "Mock data created successfully!"
puts "Categories: #{Category.count}"
puts "Users: #{User.count}"
puts "Products: #{Product.count}"
puts ""
puts "Products by status:"
puts "- Active: #{Product.where(status: 'active').count}"
puts "- Moderated: #{Product.where(status: 'moderated').count}"
puts "- Deleted: #{Product.where(status: 'deleted').count}"
puts ""
puts "Sample login credentials:"
puts "Seller: alice@gmail.com / password123"
puts "Buyer: frank@gmail.com / password123" 
puts "Admin: admin@gmail.com / password123"
puts ""
puts "Policy behavior:"
puts "- Guest users: see only active products"
puts "- Buyers: see only active products"
puts "- Sellers: see only their own products (all statuses)"
puts "- Admin: see all products"