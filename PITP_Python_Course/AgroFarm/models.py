from flask_sqlalchemy import SQLAlchemy
from flask_login import UserMixin
from datetime import datetime
import uuid

# Initialize SQLAlchemy
db = SQLAlchemy()

# ==============================
# User Model
# ==============================
class User(db.Model, UserMixin):
    __tablename__ = 'users'

    id = db.Column(db.Integer, primary_key=True)
    full_name = db.Column(db.String(150), nullable=False)
    email = db.Column(db.String(150), unique=True, nullable=False)
    password = db.Column(db.String(256), nullable=False)
    mobile = db.Column(db.String(50))
    location = db.Column(db.String(100))
    profession = db.Column(db.String(100))
    expertise = db.Column(db.String(100))
    is_admin = db.Column(db.Boolean, default=False)
    role = db.Column(db.String(20), default='user')
    is_seller = db.Column(db.Boolean, default=False)  # Added seller status

    # Relationships
    farms = db.relationship('Farm', back_populates='owner', cascade='all, delete-orphan')
    discussions = db.relationship('Discussion', back_populates='user', cascade='all, delete-orphan')
    replies = db.relationship('Reply', back_populates='user', cascade='all, delete-orphan')
    consultant_profile = db.relationship('Consultant', back_populates='user', uselist=False)
    farmer_profile = db.relationship('Farmer', back_populates='user', uselist=False)
    cart_items = db.relationship('Cart', back_populates='user', cascade='all, delete-orphan')
    
    # Blog relationships
    blogs = db.relationship('Blog', back_populates='author', cascade='all, delete-orphan')
    comments = db.relationship('Comment', back_populates='author', cascade='all, delete-orphan')
    likes = db.relationship('Like', back_populates='user', cascade='all, delete-orphan')

    def __repr__(self):
        return f"<User {self.full_name}>"

# ==============================
# KNOWLEDGE BASE Category Model 
# ==============================
class KBCategory(db.Model):
    __tablename__ = 'kb_categories'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), unique=True, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relationships
    blogs = db.relationship('Blog', back_populates='category_ref', lazy=True)

    def __repr__(self):
        return f"<KBCategory {self.name}>"

# ==============================
# CONSULTANT Category Model
# ==============================
class ConsultantCategory(db.Model):
    __tablename__ = 'consultant_categories'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), unique=True, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Relationships
    consultants = db.relationship('Consultant', back_populates='category', cascade='all, delete-orphan')

    def __repr__(self):
        return f"<ConsultantCategory {self.name}>"

# ==============================
# Blog Model for Knowledge Base
# ==============================
class Blog(db.Model):
    __tablename__ = 'blogs'
    
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    content = db.Column(db.Text, nullable=False)
    category = db.Column(db.String(100), nullable=False)  # Display name
    
    # File upload fields
    media_url = db.Column(db.String(500))
    media_type = db.Column(db.String(50))
    file_extension = db.Column(db.String(10))
    
    # Timestamps
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Foreign keys
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    category_id = db.Column(db.Integer, db.ForeignKey('kb_categories.id'))
    
    # Relationships
    author = db.relationship('User', back_populates='blogs')
    category_ref = db.relationship('KBCategory', back_populates='blogs')
    comments = db.relationship('Comment', back_populates='blog', lazy=True, cascade='all, delete-orphan')
    likes = db.relationship('Like', back_populates='blog', lazy=True, cascade='all, delete-orphan')

    def __repr__(self):
        return f"<Blog {self.title}>"

# ==============================
# Comment Model for Knowledge Base
# ==============================
class Comment(db.Model):
    __tablename__ = 'kb_comments'
    
    id = db.Column(db.Integer, primary_key=True)
    text = db.Column(db.Text, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Foreign keys
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    blog_id = db.Column(db.Integer, db.ForeignKey('blogs.id'), nullable=False)
    
    # Relationships
    author = db.relationship('User', back_populates='comments')
    blog = db.relationship('Blog', back_populates='comments')

    def __repr__(self):
        return f"<Comment {self.id}>"

# ==============================
# Like Model for Knowledge Base
# ==============================
class Like(db.Model):
    __tablename__ = 'kb_likes'
    
    id = db.Column(db.Integer, primary_key=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Foreign keys
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    blog_id = db.Column(db.Integer, db.ForeignKey('blogs.id'), nullable=False)
    
    # Unique constraint to prevent duplicate likes
    __table_args__ = (db.UniqueConstraint('user_id', 'blog_id', name='unique_user_blog_like'),)
    
    # Relationships
    user = db.relationship('User', back_populates='likes')
    blog = db.relationship('Blog', back_populates='likes')

    def __repr__(self):
        return f"<Like {self.id}>"

# ==============================
# Farm Model
# ==============================
class Farm(db.Model):
    __tablename__ = 'farms'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(150), nullable=False)
    location = db.Column(db.String(150), nullable=False)
    owner_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)

    owner = db.relationship('User', back_populates='farms')

    def __repr__(self):
        return f"<Farm {self.name}>"

# ==============================
# Discussion Model
# ==============================
class Discussion(db.Model):
    __tablename__ = 'discussions'

    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    content = db.Column(db.Text, nullable=False)
    category = db.Column(db.String(100))
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    edited_by = db.Column(db.String(150), nullable=True)
    image = db.Column(db.String(100), nullable=True)

    # Relationships
    user = db.relationship('User', back_populates='discussions')
    replies = db.relationship('Reply', back_populates='discussion', cascade='all, delete-orphan')

    def can_edit(self, user):
        return user.is_authenticated and (user.is_admin or self.user_id == user.id)

    def can_delete(self, user):
        return self.can_edit(user)

    def can_reply(self, user):
        return user.is_authenticated

    def __repr__(self):
        return f"<Discussion {self.title}>"

# ==============================
# Reply Model
# ==============================
class Reply(db.Model):
    __tablename__ = 'replies'

    id = db.Column(db.Integer, primary_key=True)
    content = db.Column(db.Text, nullable=False)
    discussion_id = db.Column(db.Integer, db.ForeignKey('discussions.id'), nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)

    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    edited_by = db.Column(db.String(150), nullable=True)

    # Relationships
    user = db.relationship('User', back_populates='replies')
    discussion = db.relationship('Discussion', back_populates='replies')

    def can_edit(self, user):
        return user.is_authenticated and (user.is_admin or self.user_id == user.id)

    def can_delete(self, user):
        return self.can_edit(user)

    def __repr__(self):
        return f"<Reply {self.content[:30]}>"

# ==============================
# Consultant Model
# ==============================
class Consultant(db.Model):
    __tablename__ = 'consultants'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    category_id = db.Column(db.Integer, db.ForeignKey('consultant_categories.id'), nullable=False)
    expertise = db.Column(db.String(200), nullable=False)
    experience = db.Column(db.Text, nullable=False)
    approved = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    user = db.relationship('User', back_populates='consultant_profile')
    category = db.relationship('ConsultantCategory', back_populates='consultants')

    def __repr__(self):
        return f"<Consultant {self.user.full_name} | {self.expertise}>"

# ==============================
# E-COMMERCE MODELS
# ==============================

class ProductCategory(db.Model):
    __tablename__ = 'product_categories'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    parent_id = db.Column(db.Integer, db.ForeignKey('product_categories.id'), nullable=True)
    description = db.Column(db.Text)
    is_active = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    # Self-referential relationship for subcategories
    parent = db.relationship('ProductCategory', remote_side=[id], backref='subcategories')
    products = db.relationship('Product', back_populates='category')

    def __repr__(self):
        return f"<ProductCategory {self.name}>"

class Farmer(db.Model):
    __tablename__ = 'farmers'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    farm_name = db.Column(db.String(200), nullable=False)
    location = db.Column(db.String(200), nullable=False)
    contact_email = db.Column(db.String(100), nullable=False)
    contact_phone = db.Column(db.String(50))
    farm_description = db.Column(db.Text)
    photo = db.Column(db.String(500))
    products_count = db.Column(db.Integer, default=0)
    status = db.Column(db.String(20), default='active')
    joined_at = db.Column(db.DateTime, default=datetime.utcnow)
    verified = db.Column(db.Boolean, default=False)

    user = db.relationship('User', back_populates='farmer_profile')
    products = db.relationship('Product', back_populates='farmer')

    def __repr__(self):
        return f"<Farmer {self.farm_name}>"

class Product(db.Model):
    __tablename__ = 'products'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text, nullable=False)
    price = db.Column(db.Float, nullable=False)
    category_id = db.Column(db.Integer, db.ForeignKey('product_categories.id'), nullable=False)
    farmer_id = db.Column(db.Integer, db.ForeignKey('farmers.id'), nullable=False)
    stock_quantity = db.Column(db.Integer, default=0)
    unit = db.Column(db.String(50), default='kg')
    badge = db.Column(db.String(50))
    discount = db.Column(db.String(50))
    photo = db.Column(db.String(500))
    contact_email = db.Column(db.String(100), nullable=False)
    specifications = db.Column(db.JSON)
    status = db.Column(db.String(20), default='active')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    expires_at = db.Column(db.DateTime, nullable=False)
    views_count = db.Column(db.Integer, default=0)
    
    # Relationships
    category = db.relationship('ProductCategory', back_populates='products')
    farmer = db.relationship('Farmer', back_populates='products')
    order_items = db.relationship('OrderItem', back_populates='product')
    in_carts = db.relationship('Cart', back_populates='product')

    def __repr__(self):
        return f"<Product {self.name}>"

class Order(db.Model):
    __tablename__ = 'orders'
    id = db.Column(db.String(50), primary_key=True)
    customer_name = db.Column(db.String(100), nullable=False)
    customer_email = db.Column(db.String(100), nullable=False)
    customer_phone = db.Column(db.String(50))
    customer_address = db.Column(db.Text)
    total_amount = db.Column(db.Float, nullable=False)
    status = db.Column(db.String(20), default='pending')
    payment_status = db.Column(db.String(20), default='pending')
    payment_method = db.Column(db.String(50))
    notes = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    items = db.relationship('OrderItem', back_populates='order', cascade='all, delete-orphan')

    def __repr__(self):
        return f"<Order {self.id}>"

class OrderItem(db.Model):
    __tablename__ = 'order_items'
    id = db.Column(db.Integer, primary_key=True)
    order_id = db.Column(db.String(50), db.ForeignKey('orders.id'), nullable=False)
    product_id = db.Column(db.Integer, db.ForeignKey('products.id'), nullable=False)
    quantity = db.Column(db.Integer, nullable=False)
    unit_price = db.Column(db.Float, nullable=False)
    total_price = db.Column(db.Float, nullable=False)

    order = db.relationship('Order', back_populates='items')
    product = db.relationship('Product', back_populates='order_items')

    def __repr__(self):
        return f"<OrderItem {self.id}>"

class Cart(db.Model):
    __tablename__ = 'carts'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    product_id = db.Column(db.Integer, db.ForeignKey('products.id'), nullable=False)
    quantity = db.Column(db.Integer, default=1)
    added_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    user = db.relationship('User', back_populates='cart_items')
    product = db.relationship('Product', back_populates='in_carts')

    def __repr__(self):
        return f"<Cart {self.id}>"

class MarketplaceNotification(db.Model):
    __tablename__ = 'marketplace_notifications'
    id = db.Column(db.Integer, primary_key=True)
    type = db.Column(db.String(20), default='info')
    title = db.Column(db.String(200), nullable=False)
    message = db.Column(db.Text, nullable=False)
    recipient_type = db.Column(db.String(20), default='all')
    recipient_id = db.Column(db.Integer, nullable=True)
    read = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def __repr__(self):
        return f"<MarketplaceNotification {self.title}>"

class MarketplaceSettings(db.Model):
    __tablename__ = 'marketplace_settings'
    id = db.Column(db.Integer, primary_key=True)
    key = db.Column(db.String(100), unique=True, nullable=False)
    value = db.Column(db.Text, nullable=False)
    description = db.Column(db.Text)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def __repr__(self):
        return f"<MarketplaceSettings {self.key}>"
    
# ==============================
# CONSULTATION MODELS
# ==============================

class ConsultationRequest(db.Model):
    __tablename__ = 'consultation_requests'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    issue_type = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text, nullable=False)
    urgency = db.Column(db.String(20), nullable=False)
    status = db.Column(db.String(20), default='pending')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def __repr__(self):
        return f"<ConsultationRequest {self.id}>"

class VideoCall(db.Model):
    __tablename__ = 'video_calls'
    
    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    expert_name = db.Column(db.String(100), nullable=False)
    call_status = db.Column(db.String(20), default='active')
    started_at = db.Column(db.DateTime, default=datetime.utcnow)
    ended_at = db.Column(db.DateTime, nullable=True)

    def __repr__(self):
        return f"<VideoCall {self.id}>"

class Expert(db.Model):
    __tablename__ = 'experts'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    specialty = db.Column(db.String(100), nullable=False)
    rating = db.Column(db.Float, default=0.0)
    is_online = db.Column(db.Boolean, default=False)
    experience = db.Column(db.String(100))

    def __repr__(self):
        return f"<Expert {self.name}>"

# ==============================
# SELLER APPLICATION & REVIEW MODELS
# ==============================

class SellerApplication(db.Model):
    __tablename__ = 'seller_applications'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    store_name = db.Column(db.String(200), nullable=False)
    store_category = db.Column(db.String(100), nullable=False)
    phone = db.Column(db.String(20), nullable=False)
    address = db.Column(db.Text, nullable=False)
    description = db.Column(db.Text)
    status = db.Column(db.String(20), default='pending')  # pending, approved, rejected
    applied_at = db.Column(db.DateTime, default=datetime.utcnow)
    reviewed_at = db.Column(db.DateTime)
    reviewed_by = db.Column(db.Integer, db.ForeignKey('users.id'))
    
    user = db.relationship('User', foreign_keys=[user_id], backref='seller_applications')
    reviewer = db.relationship('User', foreign_keys=[reviewed_by])

    def __repr__(self):
        return f"<SellerApplication {self.store_name}>"

class ProductReview(db.Model):
    __tablename__ = 'product_reviews'
    
    id = db.Column(db.Integer, primary_key=True)
    product_id = db.Column(db.Integer, db.ForeignKey('products.id'), nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    rating = db.Column(db.Integer, nullable=False)  # 1-5
    review_text = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    product = db.relationship('Product', backref='reviews')
    user = db.relationship('User', backref='product_reviews')

    def __repr__(self):
        return f"<ProductReview {self.id}>"

# ==============================
# Helper functions to initialize default categories
# ==============================
def init_default_kb_categories():
    """Initialize default categories for the knowledge base"""
    default_categories = [
        'Crop Cultivation',
        'Livestock', 
        'Irrigation',
        'Soil Management',
        'Pest Control',
        'Organic Farming',
        'Technology in Agriculture',
        'Market Trends'
    ]
    
    for category_name in default_categories:
        category = KBCategory.query.filter_by(name=category_name).first()
        if not category:
            category = KBCategory(name=category_name)
            db.session.add(category)
    
    db.session.commit()
    print("✅ Knowledge Base categories initialized!")

def init_default_consultant_categories():
    """Initialize default categories for consultants"""
    default_categories = [
        'Agronomy',
        'Livestock',
        'Irrigation & Water Management',
        'Soil Science',
        'Pest Control',
        'Organic Farming'
    ]
    
    for category_name in default_categories:
        category = ConsultantCategory.query.filter_by(name=category_name).first()
        if not category:
            category = ConsultantCategory(name=category_name)
            db.session.add(category)
    
    db.session.commit()
    print("✅ Consultant categories initialized!")