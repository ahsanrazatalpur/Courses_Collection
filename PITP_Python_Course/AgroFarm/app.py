from flask import (
    Flask,
    render_template,
    request,
    redirect,
    flash,
    url_for,
    session,
    jsonify,
)
from flask_migrate import Migrate
from flask_login import (
    LoginManager,
    login_user,
    login_required,
    logout_user,
    current_user,
    UserMixin,
)
from werkzeug.utils import secure_filename
from werkzeug.security import generate_password_hash, check_password_hash
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime, timedelta
from sqlalchemy import or_
import os
from werkzeug.utils import secure_filename
from sqlalchemy.orm import joinedload
import json
import uuid


# ===========================
# Initialize extensions
# ===========================
db = SQLAlchemy()
migrate = Migrate()
login_manager = LoginManager()


# ===========================
# MODELS
# ===========================
class User(db.Model, UserMixin):
    __tablename__ = "users"
    id = db.Column(db.Integer, primary_key=True)
    full_name = db.Column(db.String(150), nullable=False)
    email = db.Column(db.String(150), unique=True, nullable=False)
    password = db.Column(db.String(256), nullable=False)
    mobile = db.Column(db.String(50))
    location = db.Column(db.String(100))
    profession = db.Column(db.String(100))
    expertise = db.Column(db.String(100))
    is_admin = db.Column(db.Boolean, default=False)

    discussions = db.relationship(
        "Discussion", back_populates="user", cascade="all, delete"
    )
    replies = db.relationship("Reply", back_populates="user", cascade="all, delete")

    def __repr__(self):
        return f"<User {self.full_name}>"


class Discussion(db.Model):
    __tablename__ = "discussions"
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    content = db.Column(db.Text, nullable=False)
    category = db.Column(db.String(100))
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(
        db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow
    )
    edited_by = db.Column(db.String(150), nullable=True)
    image = db.Column(db.String(300), nullable=True)

    user = db.relationship("User", back_populates="discussions")
    replies = db.relationship(
        "Reply", back_populates="discussion", cascade="all, delete"
    )

    def __repr__(self):
        return f"<Discussion {self.title}>"


class Reply(db.Model):
    __tablename__ = "replies"
    id = db.Column(db.Integer, primary_key=True)
    content = db.Column(db.Text, nullable=False)
    discussion_id = db.Column(
        db.Integer, db.ForeignKey("discussions.id"), nullable=False
    )
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    updated_at = db.Column(
        db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow
    )
    edited_by = db.Column(db.String(150), nullable=True)

    user = db.relationship("User", back_populates="replies")
    discussion = db.relationship("Discussion", back_populates="replies")

    def __repr__(self):
        return f"<Reply {self.content[:30]}>"


# ==============================
# Consultant & Category Models
# ==============================
class Category(db.Model):
    __tablename__ = "categories"
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False, unique=True)
    consultants = db.relationship("Consultant", back_populates="category")


class Consultant(db.Model):
    __tablename__ = "consultants"
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    category_id = db.Column(db.Integer, db.ForeignKey("categories.id"), nullable=False)
    expertise = db.Column(db.String(200), nullable=False)
    experience = db.Column(db.Text, nullable=False)
    approved = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    user = db.relationship("User", backref="consultant_profile")
    category = db.relationship("Category", back_populates="consultants")

    def __repr__(self):
        return f"<Consultant {self.user.full_name} | {self.expertise}>"


# ===========================
# E-COMMERCE MODELS
# ===========================


class ProductCategory(db.Model):
    __tablename__ = "product_categories"
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    parent_id = db.Column(
        db.Integer, db.ForeignKey("product_categories.id"), nullable=True
    )
    description = db.Column(db.Text)
    is_active = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    # Self-referential relationship for subcategories
    parent = db.relationship(
        "ProductCategory", remote_side=[id], backref="subcategories"
    )
    products = db.relationship("Product", back_populates="category")

    def __repr__(self):
        return f"<ProductCategory {self.name}>"


class Farmer(db.Model):
    __tablename__ = "farmers"
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    farm_name = db.Column(db.String(200), nullable=False)
    location = db.Column(db.String(200), nullable=False)
    contact_email = db.Column(db.String(100), nullable=False)
    contact_phone = db.Column(db.String(50))
    farm_description = db.Column(db.Text)
    photo = db.Column(db.String(500))
    products_count = db.Column(db.Integer, default=0)
    status = db.Column(db.String(20), default="active")  # active, inactive, suspended
    joined_at = db.Column(db.DateTime, default=datetime.utcnow)
    verified = db.Column(db.Boolean, default=False)

    user = db.relationship("User", backref="farmer_profile")
    products = db.relationship("Product", back_populates="farmer")

    def __repr__(self):
        return f"<Farmer {self.farm_name}>"


class Product(db.Model):
    __tablename__ = "products"
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text, nullable=False)
    price = db.Column(db.Float, nullable=False)
    category_id = db.Column(
        db.Integer, db.ForeignKey("product_categories.id"), nullable=False
    )
    farmer_id = db.Column(db.Integer, db.ForeignKey("farmers.id"), nullable=False)
    stock_quantity = db.Column(db.Integer, default=0)
    unit = db.Column(db.String(50), default="kg")  # kg, piece, bunch, etc.
    badge = db.Column(db.String(50))  # Organic, Fresh, Best Seller, etc.
    discount = db.Column(db.String(50))  # 10% OFF, etc.
    photo = db.Column(db.String(500))
    contact_email = db.Column(db.String(100), nullable=False)
    specifications = db.Column(db.JSON)  # Store as JSON for flexible product specs
    status = db.Column(db.String(20), default="active")  # active, inactive, sold_out
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    expires_at = db.Column(db.DateTime, nullable=False)
    views_count = db.Column(db.Integer, default=0)

    # Relationships
    category = db.relationship("ProductCategory", back_populates="products")
    farmer = db.relationship("Farmer", back_populates="products")

    def __repr__(self):
        return f"<Product {self.name}>"


class Order(db.Model):
    __tablename__ = "orders"
    id = db.Column(db.String(50), primary_key=True)  # ORD-001, etc.
    customer_name = db.Column(db.String(100), nullable=False)
    customer_email = db.Column(db.String(100), nullable=False)
    customer_phone = db.Column(db.String(50))
    customer_address = db.Column(db.Text)
    total_amount = db.Column(db.Float, nullable=False)
    status = db.Column(
        db.String(20), default="pending"
    )  # pending, confirmed, shipped, delivered, cancelled
    payment_status = db.Column(
        db.String(20), default="pending"
    )  # pending, paid, failed, refunded
    payment_method = db.Column(db.String(50))  # cash, card, bank_transfer
    notes = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(
        db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow
    )

    items = db.relationship("OrderItem", back_populates="order", cascade="all, delete")

    def __repr__(self):
        return f"<Order {self.id}>"


class OrderItem(db.Model):
    __tablename__ = "order_items"
    id = db.Column(db.Integer, primary_key=True)
    order_id = db.Column(db.String(50), db.ForeignKey("orders.id"), nullable=False)
    product_id = db.Column(db.Integer, db.ForeignKey("products.id"), nullable=False)
    quantity = db.Column(db.Integer, nullable=False)
    unit_price = db.Column(db.Float, nullable=False)
    total_price = db.Column(db.Float, nullable=False)

    order = db.relationship("Order", back_populates="items")
    product = db.relationship(
        "Product"
    )  # REMOVED back_populates to avoid circular reference

    def __repr__(self):
        return f"<OrderItem {self.id}>"


class MarketplaceNotification(db.Model):
    __tablename__ = "marketplace_notifications"
    id = db.Column(db.Integer, primary_key=True)
    type = db.Column(db.String(20), default="info")  # info, success, warning, error
    title = db.Column(db.String(200), nullable=False)
    message = db.Column(db.Text, nullable=False)
    recipient_type = db.Column(
        db.String(20), default="all"
    )  # all, admin, farmer, customer
    recipient_id = db.Column(db.Integer, nullable=True)  # Specific user ID if needed
    read = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def __repr__(self):
        return f"<MarketplaceNotification {self.title}>"


class MarketplaceSettings(db.Model):
    __tablename__ = "marketplace_settings"
    id = db.Column(db.Integer, primary_key=True)
    key = db.Column(db.String(100), unique=True, nullable=False)
    value = db.Column(db.Text, nullable=False)
    description = db.Column(db.Text)
    updated_at = db.Column(
        db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow
    )

    def __repr__(self):
        return f"<MarketplaceSettings {self.key}>"


# ==============================
# Category Initialization Function
# ==============================
def init_categories():
    """Initialize categories if they don't exist"""
    try:
        categories = ["Agronomy", "Livestock", "Irrigation & Water"]
        categories_created = 0

        for cat_name in categories:
            if not Category.query.filter_by(name=cat_name).first():
                category = Category(name=cat_name)
                db.session.add(category)
                categories_created += 1
                print(f"Created category: {cat_name}")

        db.session.commit()

        if categories_created > 0:
            print(
                f"Categories initialization completed: {categories_created} categories created"
            )
        else:
            print("All categories already exist")

        # Print all available categories for verification
        all_categories = Category.query.all()
        print("Available categories in database:")
        for cat in all_categories:
            print(f"  ID: {cat.id}, Name: {cat.name}")

        return True
    except Exception as e:
        print(f"Error initializing categories: {e}")
        db.session.rollback()
        return False


def init_product_categories():
    """Initialize product categories if they don't exist"""
    try:
        categories = [
            {"name": "Vegetables", "description": "Fresh farm vegetables"},
            {"name": "Fruits", "description": "Seasonal fruits"},
            {"name": "Grains & Cereals", "description": "Organic grains and cereals"},
            {
                "name": "Dairy Products",
                "description": "Milk, cheese and dairy products",
            },
            {"name": "Livestock", "description": "Farm animals and poultry"},
            {"name": "Seeds & Plants", "description": "Seeds, seedlings and plants"},
            {"name": "Fertilizers", "description": "Organic and chemical fertilizers"},
            {"name": "Farm Equipment", "description": "Farming tools and equipment"},
        ]

        categories_created = 0

        for cat_data in categories:
            if not ProductCategory.query.filter_by(name=cat_data["name"]).first():
                category = ProductCategory(
                    name=cat_data["name"], description=cat_data["description"]
                )
                db.session.add(category)
                categories_created += 1
                print(f"Created product category: {cat_data['name']}")

        db.session.commit()

        if categories_created > 0:
            print(
                f"Product categories initialization completed: {categories_created} categories created"
            )
        else:
            print("All product categories already exist")

        return True
    except Exception as e:
        print(f"Error initializing product categories: {e}")
        db.session.rollback()
        return False


def init_marketplace_settings():
    """Initialize marketplace settings if they don't exist"""
    try:
        settings = [
            {
                "key": "auto_remove_days",
                "value": "30",
                "description": "Automatically remove posts after X days",
            },
            {
                "key": "auto_remove_enabled",
                "value": "true",
                "description": "Enable auto-remove functionality",
            },
            {
                "key": "enable_farmer_posting",
                "value": "true",
                "description": "Allow farmers to post products",
            },
            {
                "key": "marketplace_name",
                "value": "AgroFarm Marketplace",
                "description": "Name of the marketplace",
            },
            {
                "key": "contact_email",
                "value": "admin@agrofarm.com",
                "description": "Admin contact email",
            },
            {
                "key": "max_products_per_farmer",
                "value": "50",
                "description": "Maximum products a farmer can list",
            },
        ]

        settings_created = 0

        for setting_data in settings:
            if not MarketplaceSettings.query.filter_by(key=setting_data["key"]).first():
                setting = MarketplaceSettings(
                    key=setting_data["key"],
                    value=setting_data["value"],
                    description=setting_data["description"],
                )
                db.session.add(setting)
                settings_created += 1
                print(f"Created marketplace setting: {setting_data['key']}")

        db.session.commit()

        if settings_created > 0:
            print(
                f"Marketplace settings initialization completed: {settings_created} settings created"
            )
        else:
            print("All marketplace settings already exist")

        return True
    except Exception as e:
        print(f"Error initializing marketplace settings: {e}")
        db.session.rollback()
        return False


# ===========================
# CREATE APP
# ===========================
def create_app():
    app = Flask(__name__, static_folder="static", template_folder="templates")
    app.config.from_object("config.Config")
    app.secret_key = "supersecretkey"

    # E-commerce configuration
    app.config.update(
        AUTO_REMOVE_DAYS=30,
        AUTO_REMOVE_ENABLED=True,
        ENABLE_FARMER_POSTING=True,
        MARKETPLACE_NAME="AgroFarm Marketplace",
    )

    db.init_app(app)
    migrate.init_app(app, db)
    login_manager.init_app(app)
    login_manager.login_view = "login"
    login_manager.login_message_category = "info"

    # ===========================
    # Admin Credentials
    # ===========================
    ADMIN_EMAIL = "ahsanrazatalpur01@gmail.com"
    ADMIN_PASSWORD = "@57219297AlgoFarm"

    # ===========================
    # User Loader
    # ===========================
    @login_manager.user_loader
    def load_user(user_id):
        return User.query.get(int(user_id))

    # ==============================
    # Flask CLI Commands
    # ==============================
    @app.cli.command("init-categories")
    def init_categories_command():
        """Initialize the categories."""
        if init_categories():
            print("✅ Categories initialized successfully.")
        else:
            print("❌ Failed to initialize categories.")

    @app.cli.command("init-ecommerce")
    def init_ecommerce_command():
        """Initialize e-commerce data."""
        if init_product_categories() and init_marketplace_settings():
            print("✅ E-commerce data initialized successfully.")
        else:
            print("❌ Failed to initialize e-commerce data.")

    @app.cli.command("list-categories")
    def list_categories_command():
        """List all categories in the database."""
        categories = Category.query.all()
        if categories:
            print("📋 Available categories:")
            for cat in categories:
                print(f"   ID: {cat.id}, Name: {cat.name}")
        else:
            print("❌ No categories found in database.")

    # ===========================
    # ROUTES
    # ===========================
    @app.route("/")
    def index():
        threads = Discussion.query.order_by(Discussion.created_at.desc()).all()
        return render_template("index.html", user=current_user, threads=threads)

    @app.route("/register", methods=["GET", "POST"])
    def register():
        if current_user.is_authenticated:
            flash("You are already logged in!", "info")
            return redirect(url_for("index"))

        if request.method == "POST":
            full_name = request.form.get("full_name")
            email = request.form.get("email")
            mobile = request.form.get("mobile")
            location = request.form.get("location")
            profession = request.form.get("profession")
            expertise = request.form.get("expertise")
            password = request.form.get("password")

            if User.query.filter_by(email=email).first():
                flash("Email already registered!", "error")
                return redirect(url_for("register"))

            hashed_pw = generate_password_hash(password)
            new_user = User(
                full_name=full_name,
                email=email,
                mobile=mobile,
                location=location,
                profession=profession,
                expertise=expertise,
                password=hashed_pw,
            )
            db.session.add(new_user)
            db.session.commit()
            flash("✅ Registration successful! Please log in.", "success")
            return redirect(url_for("login"))

        return render_template("register.html")

    @app.route("/login", methods=["GET", "POST"])
    def login():
        if current_user.is_authenticated:
            return redirect(url_for("index"))

        if request.method == "POST":
            email = request.form.get("email")
            password = request.form.get("password")

            # Admin login
            if email == ADMIN_EMAIL and password == ADMIN_PASSWORD:
                admin_user = User.query.filter_by(email=ADMIN_EMAIL).first()
                if not admin_user:
                    admin_user = User(
                        full_name="Admin",
                        email=ADMIN_EMAIL,
                        password=generate_password_hash(ADMIN_PASSWORD),
                        profession="Administrator",
                        expertise="All",
                        mobile="N/A",
                        location="N/A",
                        is_admin=True,
                    )
                    db.session.add(admin_user)
                    db.session.commit()
                login_user(admin_user)
                session["is_admin"] = True
                flash("✅ Admin login successful!", "success")
                return redirect(url_for("index"))

            user = User.query.filter_by(email=email).first()
            if user and check_password_hash(user.password, password):
                login_user(user)
                session["is_admin"] = user.is_admin
                session["user_id"] = user.id
                flash(f"✅ Welcome back, {user.full_name}!", "success")
                return redirect(url_for("index"))

            flash("❌ Invalid email or password!", "error")
            return redirect(url_for("login"))

        return render_template("login.html")

    @app.route("/logout", methods=["POST"])
    @login_required
    def logout():
        logout_user()
        session.clear()
        flash("You have been logged out successfully.", "info")
        return redirect(url_for("index"))

    @app.route("/profile", methods=["GET", "POST"])
    @login_required
    def profile():
        if request.method == "POST":
            current_user.full_name = request.form.get("full_name")
            current_user.mobile = request.form.get("mobile")
            current_user.location = request.form.get("location")
            current_user.profession = request.form.get("profession")
            current_user.expertise = request.form.get("expertise")
            db.session.commit()
            flash("✅ Profile updated successfully!", "success")
            return redirect(url_for("profile"))
        return render_template("profile.html", user=current_user)

    # ===========================
    # DISCUSSION ROUTES
    # ===========================
    # ===========================
    # DISCUSSION ROUTES
    # ===========================
    @app.route("/api/discussions", methods=["GET", "POST"])
    @login_required
    def discussions_api():
        if request.method == "GET":
            search_query = request.args.get("q", "").strip()
            category_filter = request.args.get("category", "").strip()
            sort_by = request.args.get("sort", "newest")

            # Base query
            query = Discussion.query

            # Apply search filter
            if search_query:
                query = query.join(User).filter(
                    or_(
                        Discussion.title.ilike(f"%{search_query}%"),
                        Discussion.content.ilike(f"%{search_query}%"),
                        User.full_name.ilike(f"%{search_query}%"),
                    )
                )

            # Apply category filter
            if category_filter:
                query = query.filter(Discussion.category == category_filter)

            # Apply sorting
            if sort_by == "popular":
                # Sort by number of replies (most popular first)
                query = (
                    query.outerjoin(Reply)
                    .group_by(Discussion.id)
                    .order_by(
                        db.func.count(Reply.id).desc(), Discussion.created_at.desc()
                    )
                )
            else:  # newest first (default)
                query = query.order_by(Discussion.created_at.desc())

            discussions = query.all()

            return jsonify(
                [
                    {
                        "id": d.id,
                        "title": d.title,
                        "category": d.category,
                        "content": d.content,
                        "author": d.user.full_name,
                        "author_id": d.user_id,
                        "user_id": d.user_id,  # For consistency
                        "is_author": d.user_id == current_user.id,
                        "is_admin": current_user.is_admin,
                        "created_at": d.created_at.strftime("%Y-%m-%d %H:%M"),
                        "updated_at": (
                            d.updated_at.strftime("%Y-%m-%d %H:%M")
                            if d.updated_at
                            else None
                        ),
                        "edited_by": d.edited_by,
                        "reply_count": len(d.replies),
                        "replies": [
                            {
                                "id": r.id,
                                "author": r.user.full_name,
                                "author_id": r.user_id,
                                "content": r.content,
                                "is_author": r.user_id == current_user.id,
                                "is_admin": current_user.is_admin,
                                "created_at": r.created_at.strftime("%Y-%m-%d %H:%M"),
                                "updated_at": (
                                    r.updated_at.strftime("%Y-%m-%d %H:%M")
                                    if r.updated_at
                                    else None
                                ),
                                "edited_by": r.edited_by,
                            }
                            for r in d.replies
                        ],
                    }
                    for d in discussions
                ]
            )

        if request.method == "POST":
            data = request.get_json()
            if not data:
                return jsonify({"success": False, "message": "No data provided"}), 400

            title = data.get("title", "").strip()
            category = data.get("category", "").strip()
            content = data.get("content", "").strip()

            # Validation
            if not title:
                return jsonify({"success": False, "message": "Title is required"}), 400
            if not category:
                return (
                    jsonify({"success": False, "message": "Category is required"}),
                    400,
                )
            if not content:
                return (
                    jsonify({"success": False, "message": "Content is required"}),
                    400,
                )

            if len(title) > 200:
                return (
                    jsonify(
                        {
                            "success": False,
                            "message": "Title too long (max 200 characters)",
                        }
                    ),
                    400,
                )
            if len(content) > 2000:
                return (
                    jsonify(
                        {
                            "success": False,
                            "message": "Content too long (max 2000 characters)",
                        }
                    ),
                    400,
                )

            try:
                discussion = Discussion(
                    title=title,
                    category=category,
                    content=content,
                    user_id=current_user.id,
                )
                db.session.add(discussion)
                db.session.commit()
                return jsonify(
                    {
                        "success": True,
                        "id": discussion.id,
                        "message": "Discussion created successfully",
                    }
                )
            except Exception as e:
                db.session.rollback()
                print(f"Error creating discussion: {str(e)}")
                return (
                    jsonify({"success": False, "message": "Error creating discussion"}),
                    500,
                )

    @app.route("/api/discussions/<int:discussion_id>", methods=["DELETE", "PUT"])
    @login_required
    def modify_discussion(discussion_id):
        discussion = Discussion.query.get_or_404(discussion_id)

        # Check permissions - admin OR original author
        if not (current_user.is_admin or discussion.user_id == current_user.id):
            return jsonify({"success": False, "message": "Permission denied"}), 403

        if request.method == "DELETE":
            try:
                # Also delete all replies associated with this discussion
                Reply.query.filter_by(discussion_id=discussion_id).delete()
                db.session.delete(discussion)
                db.session.commit()
                return jsonify(
                    {"success": True, "message": "Discussion deleted successfully"}
                )
            except Exception as e:
                db.session.rollback()
                print(f"Error deleting discussion: {str(e)}")
                return (
                    jsonify({"success": False, "message": "Error deleting discussion"}),
                    500,
                )

        if request.method == "PUT":
            data = request.get_json()
            if not data:
                return jsonify({"success": False, "message": "No data provided"}), 400

            title = data.get("title", "").strip()
            content = data.get("content", "").strip()

            # Validation
            if not title:
                return jsonify({"success": False, "message": "Title is required"}), 400
            if not content:
                return (
                    jsonify({"success": False, "message": "Content is required"}),
                    400,
                )

            if len(title) > 200:
                return (
                    jsonify(
                        {
                            "success": False,
                            "message": "Title too long (max 200 characters)",
                        }
                    ),
                    400,
                )
            if len(content) > 2000:
                return (
                    jsonify(
                        {
                            "success": False,
                            "message": "Content too long (max 2000 characters)",
                        }
                    ),
                    400,
                )

            try:
                discussion.title = title
                discussion.content = content
                discussion.edited_by = current_user.full_name
                discussion.updated_at = datetime.utcnow()
                db.session.commit()
                return jsonify(
                    {"success": True, "message": "Discussion updated successfully"}
                )
            except Exception as e:
                db.session.rollback()
                print(f"Error updating discussion: {str(e)}")
                return (
                    jsonify({"success": False, "message": "Error updating discussion"}),
                    500,
                )

    @app.route("/api/discussions/<int:discussion_id>/reply", methods=["POST"])
    @login_required
    def reply_discussion(discussion_id):
        discussion = Discussion.query.get_or_404(discussion_id)
        data = request.get_json()

        if not data:
            return jsonify({"success": False, "message": "No data provided"}), 400

        content = data.get("content", "").strip()

        if not content:
            return jsonify({"success": False, "message": "Reply cannot be empty"}), 400

        if len(content) > 1000:
            return (
                jsonify(
                    {
                        "success": False,
                        "message": "Reply too long (max 1000 characters)",
                    }
                ),
                400,
            )

        try:
            reply = Reply(
                content=content, discussion_id=discussion.id, user_id=current_user.id
            )
            db.session.add(reply)
            db.session.commit()
            return jsonify(
                {
                    "success": True,
                    "id": reply.id,
                    "message": "Reply posted successfully",
                }
            )
        except Exception as e:
            db.session.rollback()
            print(f"Error posting reply: {str(e)}")
            return jsonify({"success": False, "message": "Error posting reply"}), 500

    @app.route(
        "/api/discussions/<int:discussion_id>/reply/<int:reply_id>",
        methods=["PUT", "DELETE"],
    )
    @login_required
    def modify_reply(discussion_id, reply_id):
        reply = Reply.query.get_or_404(reply_id)

        # Verify reply belongs to the discussion
        if reply.discussion_id != discussion_id:
            return (
                jsonify(
                    {"success": False, "message": "Reply not found in this discussion"}
                ),
                404,
            )

        # Check permissions - admin OR original author
        if not (current_user.is_admin or reply.user_id == current_user.id):
            return jsonify({"success": False, "message": "Permission denied"}), 403

        if request.method == "PUT":
            data = request.get_json()
            if not data:
                return jsonify({"success": False, "message": "No data provided"}), 400

            content = data.get("content", "").strip()

            if not content:
                return (
                    jsonify({"success": False, "message": "Reply cannot be empty"}),
                    400,
                )

            if len(content) > 1000:
                return (
                    jsonify(
                        {
                            "success": False,
                            "message": "Reply too long (max 1000 characters)",
                        }
                    ),
                    400,
                )

            try:
                reply.content = content
                reply.edited_by = current_user.full_name
                reply.updated_at = datetime.utcnow()
                db.session.commit()
                return jsonify(
                    {"success": True, "message": "Reply updated successfully"}
                )
            except Exception as e:
                db.session.rollback()
                print(f"Error updating reply: {str(e)}")
                return (
                    jsonify({"success": False, "message": "Error updating reply"}),
                    500,
                )

        if request.method == "DELETE":
            try:
                db.session.delete(reply)
                db.session.commit()
                return jsonify(
                    {"success": True, "message": "Reply deleted successfully"}
                )
            except Exception as e:
                db.session.rollback()
                print(f"Error deleting reply: {str(e)}")
                return (
                    jsonify({"success": False, "message": "Error deleting reply"}),
                    500,
                )

    # Additional endpoint for forum statistics
    @app.route("/api/forum/stats")
    @login_required
    def forum_stats():
        total_discussions = Discussion.query.count()
        total_replies = Reply.query.count()
        total_users = User.query.count()

        # Latest discussions for sidebar
        latest_discussions = (
            Discussion.query.order_by(Discussion.created_at.desc()).limit(5).all()
        )

        latest_posts = [
            {
                "title": d.title,
                "author": d.user.full_name,
                "created_at": d.created_at.strftime("%Y-%m-%d %H:%M"),
            }
            for d in latest_discussions
        ]

        return jsonify(
            {
                "total_discussions": total_discussions,
                "total_replies": total_replies,
                "total_users": total_users,
                "latest_posts": latest_posts,
            }
        )

    # Blog
        # Knowledge Base / Blog Routes - UPDATED FOR YOUR SCHEMA
    # ===========================

    # Add these imports at the top of your Flask file if not already present
    import time
    import uuid
    from werkzeug.utils import secure_filename

    # Config
    UPLOAD_FOLDER = "static/uploads/blogs"
    ALLOWED_EXTENSIONS = {
        "images": ["jpg", "jpeg", "png", "gif", "bmp", "webp"],
        "pdf": ["pdf"],
        "presentations": ["ppt", "pptx"],
        "videos": ["mp4", "avi", "mov", "wmv", "flv", "webm"],
        "audio": ["mp3", "wav", "ogg", "flac"],
    }
    app.config["UPLOAD_FOLDER"] = UPLOAD_FOLDER
    app.config["MAX_CONTENT_LENGTH"] = 50 * 1024 * 1024  # 50MB max file size
    os.makedirs(app.config["UPLOAD_FOLDER"], exist_ok=True)  # Ensure folder exists

    # ===========================
    # KNOWLEDGE BASE MODELS
    # ===========================
    class KBCategory(db.Model):
        __tablename__ = "kb_categories"
        id = db.Column(db.Integer, primary_key=True)
        name = db.Column(db.String(100), nullable=False, unique=True)
        created_at = db.Column(db.DateTime, default=datetime.utcnow)
        
        # Relationship to blogs
        blogs = db.relationship('Blog', back_populates='kb_category', lazy=True)

        def __repr__(self):
            return f"<KBCategory {self.name}>"

    class Blog(db.Model):
        __tablename__ = "blogs"
        id = db.Column(db.Integer, primary_key=True)
        title = db.Column(db.String(200), nullable=False)
        content = db.Column(db.Text, nullable=False)
        category = db.Column(db.String(100))  # Category name for display
        category_id = db.Column(db.Integer, db.ForeignKey('kb_categories.id'))
        media_url = db.Column(db.String(500))
        media_type = db.Column(db.String(50))
        file_extension = db.Column(db.String(10))
        user_id = db.Column(db.Integer, db.ForeignKey('users.id'))
        created_at = db.Column(db.DateTime, default=datetime.utcnow)
        updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
        
        # Relationships
        user = db.relationship('User', backref=db.backref('blogs', lazy=True))
        kb_category = db.relationship('KBCategory', back_populates='blogs')
        likes = db.relationship('Like', back_populates='blog', cascade='all, delete-orphan')
        comments = db.relationship('Comment', back_populates='blog', cascade='all, delete-orphan')

        def __repr__(self):
            return f"<Blog {self.title}>"

    class Like(db.Model):
        __tablename__ = "likes"
        id = db.Column(db.Integer, primary_key=True)
        user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
        blog_id = db.Column(db.Integer, db.ForeignKey('blogs.id'), nullable=False)
        created_at = db.Column(db.DateTime, default=datetime.utcnow)
        
        # Relationships
        user = db.relationship('User', backref=db.backref('likes', lazy=True))
        blog = db.relationship('Blog', back_populates='likes')

        def __repr__(self):
            return f"<Like user:{self.user_id} blog:{self.blog_id}>"

    class Comment(db.Model):
        __tablename__ = "comments"
        id = db.Column(db.Integer, primary_key=True)
        text = db.Column(db.Text, nullable=False)
        user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
        blog_id = db.Column(db.Integer, db.ForeignKey('blogs.id'), nullable=False)
        created_at = db.Column(db.DateTime, default=datetime.utcnow)
        updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
        
        # Relationships
        user = db.relationship('User', backref=db.backref('comments', lazy=True))
        blog = db.relationship('Blog', back_populates='comments')

        def __repr__(self):
            return f"<Comment {self.text[:50]}>"

    # Helper to check allowed files
    def allowed_file(filename):
        if not filename or "." not in filename:
            return False
        return filename.rsplit(".", 1)[1].lower() in [
            ext for extensions in ALLOWED_EXTENSIONS.values() for ext in extensions
        ]

    # Helper to get file type
    def get_file_type(filename):
        if not filename:
            return "generic"

        ext = filename.rsplit(".", 1)[1].lower() if "." in filename else ""

        if ext in ALLOWED_EXTENSIONS["images"]:
            return "image"
        elif ext in ALLOWED_EXTENSIONS["pdf"]:
            return "pdf"
        elif ext in ALLOWED_EXTENSIONS["presentations"]:
            return "presentation"
        elif ext in ALLOWED_EXTENSIONS["videos"]:
            return "video"
        elif ext in ALLOWED_EXTENSIONS["audio"]:
            return "audio"
        else:
            return "generic"

    # --------------------------
    # Initialize KB Categories - IMPROVED VERSION
    # --------------------------
    def init_kb_categories():
        """Initialize knowledge base categories"""
        try:
            default_categories = [
                "Crop Cultivation",
                "Livestock", 
                "Irrigation",
                "Soil Management",
                "Pest Control",
                "Organic Farming"
            ]
            
            categories_created = 0
            for category_name in default_categories:
                # Check if category already exists
                existing = KBCategory.query.filter_by(name=category_name).first()
                if not existing:
                    category = KBCategory(name=category_name)
                    db.session.add(category)
                    categories_created += 1
                    print(f"✅ Created KB category: {category_name}")
            
            db.session.commit()
            
            if categories_created > 0:
                print(f"✅ KB categories initialization completed: {categories_created} categories created")
            else:
                print("ℹ️ All KB categories already exist")
                
            # Verify by printing all categories
            all_categories = KBCategory.query.all()
            print("📋 Available KB categories:")
            for cat in all_categories:
                print(f"   ID: {cat.id}, Name: {cat.name}")
                
            return True
            
        except Exception as e:
            print(f"❌ Error initializing KB categories: {e}")
            db.session.rollback()
            return False

    # --------------------------
    # Debug route to check categories
    # --------------------------
    @app.route("/api/debug/kb_categories")
    def debug_kb_categories():
        """Debug endpoint to check KB categories"""
        try:
            categories = KBCategory.query.all()
            return jsonify({
                "success": True,
                "total_categories": len(categories),
                "categories": [{"id": c.id, "name": c.name} for c in categories]
            })
        except Exception as e:
            return jsonify({"success": False, "error": str(e)})

    # --------------------------
    # Manual initialization route (for testing)
    # --------------------------
    @app.route("/api/kb_init")
    def manual_kb_init():
        """Manually initialize KB categories"""
        try:
            if init_kb_categories():
                return jsonify({"success": True, "message": "KB categories initialized successfully"})
            else:
                return jsonify({"success": False, "message": "Failed to initialize KB categories"})
        except Exception as e:
            return jsonify({"success": False, "message": f"Error: {str(e)}"})

    # --------------------------
    # Main Knowledge Base page
    # --------------------------
    @app.route("/knowledge_base")
    @login_required
    def knowledge_base():
        # Get recent blogs and categories
        recent_blogs = Blog.query.order_by(Blog.created_at.desc()).limit(10).all()
        categories = KBCategory.query.order_by(KBCategory.name).all()

        return render_template(
            "knowledge_base.html",  # Make sure this template exists
            user=current_user,
            recent_blogs=recent_blogs,
            categories=categories,
        )

    # --------------------------
    # API: Get all KB categories - IMPROVED VERSION
    # --------------------------
    @app.route("/api/kb_categories")
    @login_required
    def api_kb_categories():
        try:
            categories = KBCategory.query.order_by(KBCategory.name).all()
            
            # If no categories exist, create default ones
            if not categories:
                print("⚠️ No KB categories found, creating default categories...")
                init_kb_categories()
                categories = KBCategory.query.order_by(KBCategory.name).all()
            
            return jsonify([{"id": c.id, "name": c.name} for c in categories])
            
        except Exception as e:
            print(f"Error loading KB categories: {e}")
            # Return default categories as fallback
            default_categories = [
                {"id": 1, "name": "Crop Cultivation"},
                {"id": 2, "name": "Livestock"},
                {"id": 3, "name": "Irrigation"},
                {"id": 4, "name": "Soil Management"},
                {"id": 5, "name": "Pest Control"},
            ]
            return jsonify(default_categories)

    # --------------------------
    # API: Add new KB category (admin only)
    # --------------------------
    @app.route("/api/kb_categories", methods=["POST"])
    @login_required
    def add_kb_category():
        if not current_user.is_admin:
            return (
                jsonify({"success": False, "error": "Only admins can manage categories."}),
                403,
            )

        try:
            data = request.get_json()
            if not data:
                return jsonify({"success": False, "error": "No data provided."}), 400

            category_name = data.get("name", "").strip()

            if not category_name:
                return (
                    jsonify({"success": False, "error": "Category name is required."}),
                    400,
                )

            # Check if category already exists
            existing_category = KBCategory.query.filter_by(name=category_name).first()
            if existing_category:
                return jsonify({"success": False, "error": "Category already exists."}), 400

            # Create new category
            category = KBCategory(name=category_name)
            db.session.add(category)
            db.session.commit()

            return jsonify(
                {"success": True, "category": {"id": category.id, "name": category.name}}
            )
        except Exception as e:
            db.session.rollback()
            print(f"Error adding KB category: {e}")
            return jsonify({"success": False, "error": "Server error occurred."}), 500

    # --------------------------
    # API: Delete KB category (admin only)
    # --------------------------
    @app.route("/api/kb_categories/<int:category_id>", methods=["DELETE"])
    @login_required
    def delete_kb_category(category_id):
        if not current_user.is_admin:
            return (
                jsonify({"success": False, "error": "Only admins can manage categories."}),
                403,
            )

        try:
            category = KBCategory.query.get_or_404(category_id)

            # Check if category is used in any blogs
            blog_count = Blog.query.filter_by(category_id=category_id).count()
            if blog_count > 0:
                return (
                    jsonify(
                        {
                            "success": False,
                            "error": f"Cannot delete category. It is used in {blog_count} blog(s).",
                        }
                    ),
                    400,
                )

            db.session.delete(category)
            db.session.commit()

            return jsonify({"success": True, "message": "Category deleted successfully."})
        except Exception as e:
            db.session.rollback()
            print(f"Error deleting KB category: {e}")
            return jsonify({"success": False, "error": "Server error occurred."}), 500

    # --------------------------
    # Post a new blog (all users can post)
    # --------------------------
    @app.route("/knowledge_base/post", methods=["POST"])
    @login_required
    def post_blog():
        try:
            print("=== POST BLOG STARTED ===")

            # Get form data
            title = request.form.get("title", "").strip()
            content = request.form.get("content", "").strip()
            category_name = request.form.get("category", "").strip()
            media_url = request.form.get("media_url", "").strip()
            file = request.files.get("media_file")

            print(f"Received - Title: '{title}', Category: '{category_name}'")

            # Basic validation
            if not title:
                return jsonify({"success": False, "error": "Title is required."}), 400
            if not content:
                return jsonify({"success": False, "error": "Content is required."}), 400
            if not category_name:
                return jsonify({"success": False, "error": "Category is required."}), 400

            # Check if category exists
            category = KBCategory.query.filter_by(name=category_name).first()
            print(f"Category lookup: {category}")

            if not category:
                # Create the category if it doesn't exist (admin only) or return error
                if current_user.is_admin:
                    category = KBCategory(name=category_name)
                    db.session.add(category)
                    db.session.commit()
                    print(f"Created new KB category: {category_name}")
                else:
                    return (
                        jsonify({"success": False, "error": "Invalid category selected."}),
                        400,
                    )

            # Handle file upload (optional)
            final_media_url = None
            media_type = None
            file_extension = None

            if file and file.filename:
                print(f"Processing file: {file.filename}")
                if not allowed_file(file.filename):
                    return (
                        jsonify({"success": False, "error": "File type not allowed."}),
                        400,
                    )

                # Generate unique filename
                file_extension = file.filename.rsplit(".", 1)[1].lower()
                unique_filename = (
                    f"blog_{int(time.time())}_{uuid.uuid4().hex[:8]}.{file_extension}"
                )
                filename = secure_filename(unique_filename)
                file_path = os.path.join(app.config["UPLOAD_FOLDER"], filename)

                print(f"Saving file to: {file_path}")
                file.save(file_path)

                final_media_url = f"/static/uploads/blogs/{filename}"
                media_type = get_file_type(file.filename)
                print(f"File saved successfully: {final_media_url}")

            elif media_url:
                print(f"Using media URL: {media_url}")
                final_media_url = media_url
                # Determine media type from URL
                if any(ext in media_url.lower() for ext in ALLOWED_EXTENSIONS["images"]):
                    media_type = "image"
                elif any(ext in media_url.lower() for ext in ALLOWED_EXTENSIONS["pdf"]):
                    media_type = "pdf"
                elif any(
                    ext in media_url.lower() for ext in ALLOWED_EXTENSIONS["presentations"]
                ):
                    media_type = "presentation"
                elif any(ext in media_url.lower() for ext in ALLOWED_EXTENSIONS["videos"]):
                    media_type = "video"
                elif any(ext in media_url.lower() for ext in ALLOWED_EXTENSIONS["audio"]):
                    media_type = "audio"
                else:
                    media_type = "generic"

            # Create blog post
            print("Creating blog object...")
            blog = Blog(
                title=title,
                content=content,
                category=category_name,
                category_id=category.id,
                media_url=final_media_url,
                media_type=media_type,
                file_extension=file_extension,
                user_id=current_user.id,
            )

            print("Adding to database...")
            db.session.add(blog)
            db.session.commit()
            print(f"Blog created successfully with ID: {blog.id}")

            return jsonify(
                {
                    "success": True,
                    "message": "Blog posted successfully!",
                    "blog_id": blog.id,
                }
            )

        except Exception as e:
            db.session.rollback()
            print(f"!!! SERVER ERROR in post_blog: {str(e)}")
            import traceback
            print(f"Full traceback: {traceback.format_exc()}")
            return jsonify({"success": False, "error": f"Database error: {str(e)}"}), 500

    # --------------------------
    # Edit blog (admin or blog owner)
    # --------------------------
    @app.route("/knowledge_base/edit/<int:blog_id>", methods=["POST"])
    @login_required
    def edit_blog(blog_id):
        try:
            blog = Blog.query.get_or_404(blog_id)

            # Check permissions
            if not current_user.is_admin and current_user.id != blog.user_id:
                return jsonify({"success": False, "error": "Permission denied."}), 403

            title = request.form.get("title", "").strip()
            content = request.form.get("content", "").strip()
            category_name = request.form.get("category", "").strip()
            media_url = request.form.get("media_url", "").strip()
            file = request.files.get("media_file")

            if not title or not content or not category_name:
                return jsonify({"success": False, "error": "All fields are required."}), 400

            # Validate category exists
            category = KBCategory.query.filter_by(name=category_name).first()
            if not category:
                return (
                    jsonify({"success": False, "error": "Invalid category selected."}),
                    400,
                )

            blog.title = title
            blog.content = content
            blog.category = category_name
            blog.category_id = category.id

            # Update media only if new file/URL is provided
            if file and file.filename:
                if not allowed_file(file.filename):
                    return (
                        jsonify({"success": False, "error": "File type not allowed."}),
                        400,
                    )

                # Delete old file if it exists locally
                if blog.media_url and blog.media_url.startswith("/static/uploads/blogs/"):
                    old_file_path = blog.media_url.replace("/static/uploads/blogs/", "")
                    full_old_path = os.path.join(app.config["UPLOAD_FOLDER"], old_file_path)
                    if os.path.exists(full_old_path):
                        os.remove(full_old_path)

                # Save new file
                file_extension = file.filename.rsplit(".", 1)[1].lower()
                unique_filename = (
                    f"blog_{int(time.time())}_{uuid.uuid4().hex[:8]}.{file_extension}"
                )
                filename = secure_filename(unique_filename)
                file_path = os.path.join(app.config["UPLOAD_FOLDER"], filename)
                file.save(file_path)

                blog.media_url = f"/static/uploads/blogs/{filename}"
                blog.media_type = get_file_type(file.filename)
                blog.file_extension = file_extension

            elif media_url:
                # If switching from file to URL, delete the old file
                if blog.media_url and blog.media_url.startswith("/static/uploads/blogs/"):
                    old_file_path = blog.media_url.replace("/static/uploads/blogs/", "")
                    full_old_path = os.path.join(app.config["UPLOAD_FOLDER"], old_file_path)
                    if os.path.exists(full_old_path):
                        os.remove(full_old_path)

                blog.media_url = media_url
                # Determine media type from URL
                if any(ext in media_url.lower() for ext in ALLOWED_EXTENSIONS["images"]):
                    blog.media_type = "image"
                elif any(ext in media_url.lower() for ext in ALLOWED_EXTENSIONS["pdf"]):
                    blog.media_type = "pdf"
                elif any(
                    ext in media_url.lower() for ext in ALLOWED_EXTENSIONS["presentations"]
                ):
                    blog.media_type = "presentation"
                elif any(ext in media_url.lower() for ext in ALLOWED_EXTENSIONS["videos"]):
                    blog.media_type = "video"
                elif any(ext in media_url.lower() for ext in ALLOWED_EXTENSIONS["audio"]):
                    blog.media_type = "audio"
                else:
                    blog.media_type = "generic"

                blog.file_extension = None

            db.session.commit()
            return jsonify({"success": True, "message": "Blog updated successfully!"})

        except Exception as e:
            db.session.rollback()
            print(f"Error editing blog: {str(e)}")
            return jsonify({"success": False, "error": "Server error occurred."}), 500

    # --------------------------
    # Delete blog (admin or blog owner)
    # --------------------------
    @app.route("/knowledge_base/delete/<int:blog_id>", methods=["POST"])
    @login_required
    def delete_blog(blog_id):
        try:
            blog = Blog.query.get_or_404(blog_id)

            # Check permissions
            if not current_user.is_admin and current_user.id != blog.user_id:
                return jsonify({"success": False, "error": "Permission denied."}), 403

            # Delete media file if it's a local file
            if blog.media_url and blog.media_url.startswith("/static/uploads/blogs/"):
                try:
                    file_name = blog.media_url.replace("/static/uploads/blogs/", "")
                    local_media_path = os.path.join(app.config["UPLOAD_FOLDER"], file_name)
                    if os.path.exists(local_media_path):
                        os.remove(local_media_path)
                except Exception as e:
                    print(f"Error deleting media file: {e}")

            db.session.delete(blog)
            db.session.commit()
            return jsonify({"success": True, "message": "Blog deleted successfully!"})

        except Exception as e:
            db.session.rollback()
            print(f"Error deleting blog: {str(e)}")
            return jsonify({"success": False, "error": "Server error occurred."}), 500

    # ===========================
    # NEW MISSING ROUTES - ADD THESE
    # ===========================

    # API: Get individual blog
    @app.route("/api/blogs/<int:blog_id>")
    @login_required
    def get_blog(blog_id):
        """Get individual blog data for modal"""
        try:
            blog = Blog.query.options(
                joinedload(Blog.user),
                joinedload(Blog.kb_category)
            ).get_or_404(blog_id)
            
            # Get likes and comments count
            like_count = Like.query.filter_by(blog_id=blog_id).count()
            comment_count = Comment.query.filter_by(blog_id=blog_id).count()
            
            # Check if current user liked this blog
            has_liked = Like.query.filter_by(
                blog_id=blog_id, 
                user_id=current_user.id
            ).first() is not None
            
            return jsonify({
                "success": True,
                "blog": {
                    "id": blog.id,
                    "title": blog.title,
                    "content": blog.content,
                    "category": blog.category,
                    "media_url": blog.media_url,
                    "media_type": blog.media_type,
                    "created_at": blog.created_at.strftime("%b %d, %Y %I:%M %p"),
                    "author": blog.user.full_name if blog.user else "Unknown",
                    "author_id": blog.user_id,
                    "like_count": like_count,
                    "comment_count": comment_count,
                    "has_liked": has_liked,
                    "can_edit": current_user.is_admin or blog.user_id == current_user.id,
                    "can_delete": current_user.is_admin or blog.user_id == current_user.id
                }
            })
        except Exception as e:
            return jsonify({"success": False, "error": str(e)}), 500

    # API: Get all blogs for recent section
    @app.route("/api/blogs")
    @login_required
    def get_all_blogs():
        """Get all blogs for recent posts section"""
        try:
            blogs = Blog.query.options(
                joinedload(Blog.user),
                joinedload(Blog.kb_category)
            ).order_by(Blog.created_at.desc()).all()
            
            blogs_data = []
            for blog in blogs:
                like_count = Like.query.filter_by(blog_id=blog.id).count()
                comment_count = Comment.query.filter_by(blog_id=blog.id).count()
                
                blogs_data.append({
                    "id": blog.id,
                    "title": blog.title,
                    "content": blog.content,
                    "category": blog.category,
                    "media_url": blog.media_url,
                    "media_type": blog.media_type,
                    "created_at": blog.created_at.strftime("%b %d, %Y"),
                    "author": blog.user.full_name if blog.user else "Unknown",
                    "author_id": blog.user_id,
                    "like_count": like_count,
                    "comment_count": comment_count,
                    "can_edit": current_user.is_admin or blog.user_id == current_user.id,
                    "can_delete": current_user.is_admin or blog.user_id == current_user.id
                })
            
            return jsonify({"success": True, "blogs": blogs_data})
        except Exception as e:
            return jsonify({"success": False, "error": str(e)}), 500

    # API: Delete comment (admin only)
    @app.route("/api/comments/<int:comment_id>", methods=["DELETE"])
    @login_required
    def delete_comment(comment_id):
        """Delete comment (admin only)"""
        try:
            comment = Comment.query.get_or_404(comment_id)
            
            # Only admin can delete any comment
            if not current_user.is_admin:
                return jsonify({"success": False, "error": "Permission denied"}), 403
                
            db.session.delete(comment)
            db.session.commit()
            
            return jsonify({"success": True, "message": "Comment deleted successfully"})
        except Exception as e:
            db.session.rollback()
            return jsonify({"success": False, "error": str(e)}), 500

    # API: Update comment (comment owner or admin)
    @app.route("/api/comments/<int:comment_id>", methods=["PUT"])
    @login_required
    def update_comment(comment_id):
        """Update comment (comment owner or admin)"""
        try:
            comment = Comment.query.get_or_404(comment_id)
            data = request.get_json()
            
            # Check permissions - comment owner or admin
            if not (current_user.is_admin or comment.user_id == current_user.id):
                return jsonify({"success": False, "error": "Permission denied"}), 403
                
            new_text = data.get("text", "").strip()
            if not new_text:
                return jsonify({"success": False, "error": "Comment text is required"}), 400
                
            comment.text = new_text
            comment.updated_at = datetime.utcnow()
            db.session.commit()
            
            return jsonify({"success": True, "message": "Comment updated successfully"})
        except Exception as e:
            db.session.rollback()
            return jsonify({"success": False, "error": str(e)}), 500

    # ===========================
    # EXISTING LIKE/COMMENT ROUTES (UPDATED)
    # ===========================

    # --------------------------
    # API: Get blog likes status
    # --------------------------
    @app.route("/api/blogs/<int:blog_id>/like")
    @login_required
    def api_blog_likes(blog_id):
        try:
            like_count = Like.query.filter_by(blog_id=blog_id).count()
            has_liked = (
                Like.query.filter_by(blog_id=blog_id, user_id=current_user.id).first()
                is not None
            )

            return jsonify({"like_count": like_count, "has_liked": has_liked})
        except Exception as e:
            print(f"Error getting likes: {e}")
            return jsonify({"like_count": 0, "has_liked": False})

    # --------------------------
    # API: Like/Unlike blog
    # --------------------------
    @app.route("/api/blogs/<int:blog_id>/like", methods=["POST"])
    @login_required
    def like_blog(blog_id):
        try:
            blog = Blog.query.get_or_404(blog_id)

            # Check if user already liked this blog
            existing_like = Like.query.filter_by(
                user_id=current_user.id, blog_id=blog_id
            ).first()

            if existing_like:
                # Unlike
                db.session.delete(existing_like)
                action = "unliked"
            else:
                # Like
                like = Like(user_id=current_user.id, blog_id=blog_id)
                db.session.add(like)
                action = "liked"

            db.session.commit()

            # Get updated like count
            like_count = Like.query.filter_by(blog_id=blog_id).count()

            return jsonify({"success": True, "action": action, "like_count": like_count})
        except Exception as e:
            db.session.rollback()
            print(f"Error toggling like: {e}")
            return jsonify({"success": False, "error": "Server error occurred."}), 500

    # --------------------------
    # API: Add comment - UPDATED VERSION
    # --------------------------
    @app.route("/api/blogs/<int:blog_id>/comments", methods=["POST"])
    @login_required
    def add_comment(blog_id):
        try:
            blog = Blog.query.get_or_404(blog_id)

            data = request.get_json()
            text = data.get("text", "").strip()

            if not text:
                return (
                    jsonify({"success": False, "error": "Comment text is required."}),
                    400,
                )

            comment = Comment(text=text, user_id=current_user.id, blog_id=blog_id)

            db.session.add(comment)
            db.session.commit()

            return jsonify(
                {
                    "success": True,
                    "comment": {
                        "id": comment.id,
                        "text": comment.text,
                        "created_at": comment.created_at.strftime("%b %d, %Y %I:%M %p"),
                        "author": {"username": current_user.full_name},
                        "can_edit": True,  # User can always edit their own comment
                    },
                }
            )
        except Exception as e:
            db.session.rollback()
            print(f"Error adding comment: {e}")
            return jsonify({"success": False, "error": "Server error occurred."}), 500

    # --------------------------
    # API: Get blog comments - UPDATED VERSION
    # --------------------------
    @app.route("/api/blogs/<int:blog_id>/comments")
    @login_required
    def get_comments(blog_id):
        try:
            comments = (
                Comment.query.filter_by(blog_id=blog_id)
                .order_by(Comment.created_at.desc())
                .all()
            )

            return jsonify(
                [
                    {
                        "id": c.id,
                        "text": c.text,
                        "created_at": c.created_at.strftime("%b %d, %Y %I:%M %p"),
                        "author": {
                            "username": c.user.full_name if c.user else "Unknown"  # Fixed: use c.user instead of c.author
                        },
                        "can_edit": c.user_id == current_user.id or current_user.is_admin,
                    }
                    for c in comments
                ]
            )
        except Exception as e:
            print(f"Error getting comments: {e}")
            return jsonify([])
        
    # ==============================
    # Consultant Routes
    # ==============================

    # User status endpoint
    @app.route("/api/user/status")
    @login_required
    def user_status():
        """Get current user status including admin role"""
        return jsonify(
            {
                "success": True,
                "is_admin": current_user.is_admin,
                "user_id": current_user.id,
                "email": current_user.email,
                "name": current_user.full_name,
            }
        )

    # Debug route to check categories
    @app.route("/api/debug/categories")
    def debug_categories():
        """Debug endpoint to check available categories"""
        try:
            categories = Category.query.all()
            result = [{"id": c.id, "name": c.name} for c in categories]
            return jsonify({"success": True, "categories": result})
        except Exception as e:
            return jsonify({"success": False, "message": str(e)}), 500

    # Initialize categories on first request
    @app.before_request
    def initialize_on_first_request():
        """Initialize categories on first request if they don't exist"""
        if not hasattr(app, "categories_initialized"):
            categories_exist = Category.query.first()
            if not categories_exist:
                print("🔄 Initializing categories on first request...")
                init_categories()
            app.categories_initialized = True

    # Get all approved consultants
    @app.route("/api/consultants")
    @login_required
    def api_consultants():
        search = request.args.get("q", "").strip()
        try:
            query = Consultant.query.options(joinedload(Consultant.user)).filter_by(
                approved=True
            )
            if search:
                query = query.join(User).filter(
                    or_(
                        User.full_name.ilike(f"%{search}%"),
                        Consultant.expertise.ilike(f"%{search}%"),
                    )
                )
            consultants = query.order_by(Consultant.created_at.desc()).all()
            result = [
                {
                    "id": c.id,
                    "name": c.user.full_name if c.user else "",
                    "email": c.user.email if c.user else "",
                    "expertise": c.expertise,
                    "experience": c.experience,
                    "category": getattr(c.category, "name", ""),
                    "category_id": c.category_id,
                }
                for c in consultants
            ]
            return jsonify({"success": True, "consultants": result})
        except Exception as e:
            return jsonify({"success": False, "message": str(e)}), 500

    # Get pending consultants for admin approval
    @app.route("/api/consultants/pending")
    @login_required
    def pending_consultants():
        """Get all pending consultant applications (admin only)"""
        if not current_user.is_admin:
            return jsonify({"success": False, "message": "Admin access required"}), 403

        try:
            pending = (
                Consultant.query.options(
                    joinedload(Consultant.user), joinedload(Consultant.category)
                )
                .filter_by(approved=False)
                .order_by(Consultant.created_at.desc())
                .all()
            )

            result = [
                {
                    "id": c.id,
                    "user_id": c.user_id,
                    "name": c.user.full_name if c.user else "",
                    "email": c.user.email if c.user else "",
                    "expertise": c.expertise,
                    "experience": c.experience,
                    "category": getattr(c.category, "name", ""),
                    "category_id": c.category_id,
                    "created_at": c.created_at.strftime("%Y-%m-%d %H:%M"),
                    "user_profile": {
                        "mobile": c.user.mobile if c.user else "",
                        "location": c.user.location if c.user else "",
                        "profession": c.user.profession if c.user else "",
                    },
                }
                for c in pending
            ]
            return jsonify({"success": True, "pending_consultants": result})
        except Exception as e:
            return jsonify({"success": False, "message": str(e)}), 500

    # Admin approve/decline consultant
    @app.route("/api/consultants/<int:consultant_id>/review", methods=["POST"])
    @login_required
    def review_consultant(consultant_id):
        """Admin approve or decline consultant application"""
        if not current_user.is_admin:
            return jsonify({"success": False, "message": "Admin access required"}), 403

        data = request.get_json() or {}
        action = data.get("action")  # "approve" or "decline"
        new_category_id = data.get("new_category_id")  # Optional: change category

        if action not in ["approve", "decline"]:
            return jsonify({"success": False, "message": "Invalid action"}), 400

        try:
            consultant = Consultant.query.options(
                joinedload(Consultant.user)
            ).get_or_404(consultant_id)

            if action == "approve":
                # Update category if provided
                if new_category_id:
                    new_category = Category.query.get(new_category_id)
                    if not new_category:
                        return (
                            jsonify({"success": False, "message": "Invalid category"}),
                            400,
                        )
                    consultant.category_id = new_category_id

                consultant.approved = True
                db.session.commit()

                # Here you can add email notification logic
                print(f"✅ Consultant {consultant.user.full_name} approved by admin")

                return jsonify(
                    {
                        "success": True,
                        "message": f"Consultant {consultant.user.full_name} approved successfully!",
                    }
                )

            else:  # decline
                # Store decline reason if provided
                decline_reason = data.get("decline_reason", "")

                # Here you can add email notification logic with decline reason
                print(
                    f"❌ Consultant {consultant.user.full_name} declined by admin. Reason: {decline_reason}"
                )

                # Delete the application
                db.session.delete(consultant)
                db.session.commit()

                return jsonify(
                    {
                        "success": True,
                        "message": f"Consultant application declined successfully.",
                    }
                )

        except Exception as e:
            db.session.rollback()
            return jsonify({"success": False, "message": str(e)}), 500

    # Admin create new category
    @app.route("/api/categories", methods=["POST"])
    @login_required
    def create_category():
        """Create new category (admin only)"""
        if not current_user.is_admin:
            return jsonify({"success": False, "message": "Admin access required"}), 403

        data = request.get_json() or {}
        name = data.get("name", "").strip()

        if not name:
            return (
                jsonify({"success": False, "message": "Category name is required"}),
                400,
            )

        try:
            # Check if category already exists
            existing = Category.query.filter_by(name=name).first()
            if existing:
                return (
                    jsonify({"success": False, "message": "Category already exists"}),
                    400,
                )

            category = Category(name=name)
            db.session.add(category)
            db.session.commit()

            return jsonify(
                {
                    "success": True,
                    "message": f"Category '{name}' created successfully!",
                    "category": {"id": category.id, "name": category.name},
                }
            )
        except Exception as e:
            db.session.rollback()
            return jsonify({"success": False, "message": str(e)}), 500

    # Admin update category
    @app.route("/api/categories/<int:category_id>", methods=["PUT"])
    @login_required
    def update_category(category_id):
        """Update category (admin only)"""
        if not current_user.is_admin:
            return jsonify({"success": False, "message": "Admin access required"}), 403

        data = request.get_json() or {}
        name = data.get("name", "").strip()

        if not name:
            return (
                jsonify({"success": False, "message": "Category name is required"}),
                400,
            )

        try:
            category = Category.query.get_or_404(category_id)

            # Check if new name already exists
            existing = Category.query.filter(
                Category.name == name, Category.id != category_id
            ).first()
            if existing:
                return (
                    jsonify(
                        {"success": False, "message": "Category name already exists"}
                    ),
                    400,
                )

            category.name = name
            db.session.commit()

            return jsonify(
                {
                    "success": True,
                    "message": f"Category updated to '{name}' successfully!",
                    "category": {"id": category.id, "name": category.name},
                }
            )
        except Exception as e:
            db.session.rollback()
            return jsonify({"success": False, "message": str(e)}), 500

    # Admin delete category
    @app.route("/api/categories/<int:category_id>", methods=["DELETE"])
    @login_required
    def delete_category(category_id):
        """Delete category (admin only)"""
        if not current_user.is_admin:
            return jsonify({"success": False, "message": "Admin access required"}), 403

        try:
            category = Category.query.get_or_404(category_id)

            # Check if category has consultants
            if category.consultants:
                return (
                    jsonify(
                        {
                            "success": False,
                            "message": "Cannot delete category that has consultants. Move consultants first.",
                        }
                    ),
                    400,
                )

            db.session.delete(category)
            db.session.commit()

            return jsonify(
                {
                    "success": True,
                    "message": f"Category '{category.name}' deleted successfully!",
                }
            )
        except Exception as e:
            db.session.rollback()
            return jsonify({"success": False, "message": str(e)}), 500

    # Get all categories (for admin management)
    @app.route("/api/categories/all")
    @login_required
    def all_categories():
        """Get all categories with consultant counts"""
        try:
            categories = Category.query.options(joinedload(Category.consultants)).all()
            result = [
                {
                    "id": c.id,
                    "name": c.name,
                    "consultant_count": len(
                        [
                            consultant
                            for consultant in c.consultants
                            if consultant.approved
                        ]
                    ),
                    "pending_count": len(
                        [
                            consultant
                            for consultant in c.consultants
                            if not consultant.approved
                        ]
                    ),
                    "total_consultants": len(c.consultants),
                }
                for c in categories
            ]
            return jsonify({"success": True, "categories": result})
        except Exception as e:
            return jsonify({"success": False, "message": str(e)}), 500

    # Register consultant using category_id
    @app.route("/api/consultants/register", methods=["POST"])
    @login_required
    def register_consultant():
        data = request.get_json() or {}
        expertise = data.get("expertise", "").strip()
        experience = data.get("experience", "").strip()
        category_id = data.get("category_id")

        # Debug logging
        print(f"DEBUG - Received registration data:")
        print(f"  expertise: '{expertise}'")
        print(f"  experience: '{experience}'")
        print(f"  category_id: '{category_id}' (type: {type(category_id)})")

        # Validate required fields
        if not expertise:
            return (
                jsonify({"success": False, "message": "Expertise field is required."}),
                400,
            )
        if not experience:
            return (
                jsonify({"success": False, "message": "Experience field is required."}),
                400,
            )
        if not category_id:
            return (
                jsonify(
                    {"success": False, "message": "Category selection is required."}
                ),
                400,
            )

        # Convert category_id to integer and validate
        try:
            category_id = int(category_id)
        except (ValueError, TypeError):
            print(f"DEBUG - Invalid category_id format: {category_id}")
            return (
                jsonify({"success": False, "message": "Invalid category ID format."}),
                400,
            )

        # Ensure category exists
        category = Category.query.get(category_id)
        print(f"DEBUG - Looking for category ID {category_id}, found: {category}")

        if not category:
            # List available categories for debugging
            available_categories = Category.query.all()
            available_ids = [c.id for c in available_categories]
            print(f"DEBUG - Available category IDs: {available_ids}")
            return (
                jsonify(
                    {
                        "success": False,
                        "message": f"Invalid category selected. Please choose a valid category.",
                    }
                ),
                400,
            )

        # Check if user already applied
        existing = Consultant.query.filter_by(user_id=current_user.id).first()
        if existing:
            status = "approved" if existing.approved else "pending approval"
            return (
                jsonify(
                    {
                        "success": False,
                        "message": f"You already have a consultant application that is {status}.",
                    }
                ),
                400,
            )

        try:
            consultant = Consultant(
                user_id=current_user.id,
                category_id=category.id,
                expertise=expertise,
                experience=experience,
                approved=False,
            )
            db.session.add(consultant)
            db.session.commit()
            print(
                f"DEBUG - Successfully registered consultant for user {current_user.id}"
            )
            return jsonify(
                {
                    "success": True,
                    "message": "Consultant profile submitted for approval. You will be notified once approved.",
                }
            )
        except Exception as e:
            db.session.rollback()
            print(f"DEBUG - Database error: {str(e)}")
            return (
                jsonify(
                    {
                        "success": False,
                        "message": "An error occurred while saving your application. Please try again.",
                    }
                ),
                500,
            )

    # Wetehr and Crop
    # ======= Weather and Crop Routes =======
    @app.route("/add_crops", methods=["POST"])
    def add_crops():
        """API endpoint to add selected crops"""
        try:
            data = request.get_json()
            crops = data.get("crops", [])
            weather = data.get("weather", "Unknown")
            timestamp = data.get("timestamp", datetime.now().isoformat())

            print(f"Adding crops: {crops} for weather: {weather} at {timestamp}")

            return (
                jsonify(
                    {
                        "status": "success",
                        "message": f"Added {len(crops)} crops successfully",
                        "crops_added": crops,
                        "weather_condition": weather,
                        "timestamp": timestamp,
                    }
                ),
                200,
            )

        except Exception as e:
            return jsonify({"status": "error", "message": str(e)}), 400

    @app.route("/harvest_crops", methods=["POST"])
    def harvest_crops():
        """API endpoint to harvest ready crops"""
        try:
            data = request.get_json()
            action = data.get("action", "harvest")
            timestamp = data.get("timestamp", datetime.now().isoformat())
            weather = data.get("weather", "Unknown")

            print(f"Harvest action: {action} at {timestamp} for weather: {weather}")

            return (
                jsonify(
                    {
                        "status": "success",
                        "message": "Harvest operation initiated successfully",
                        "action": action,
                        "timestamp": timestamp,
                        "weather_condition": weather,
                    }
                ),
                200,
            )

        except Exception as e:
            return jsonify({"status": "error", "message": str(e)}), 400

    @app.route("/weather_data", methods=["GET"])
    def get_weather_data():
        """API endpoint to get current weather data"""
        try:
            weather_data = {
                "current": {
                    "temp": 25,
                    "condition": "Sunny",
                    "location": "AgroFarm Main Field",
                    "windSpeed": 15,
                    "humidity": 65,
                    "pressure": 1013,
                    "visibility": 10,
                    "icon": "fa-sun",
                },
                "forecast": [
                    {
                        "day": "Today",
                        "temp": 25,
                        "condition": "Sunny",
                        "icon": "fa-sun",
                    },
                    {
                        "day": "Tomorrow",
                        "temp": 22,
                        "condition": "Partly Cloudy",
                        "icon": "fa-cloud-sun",
                    },
                    {
                        "day": "Wed",
                        "temp": 20,
                        "condition": "Rainy",
                        "icon": "fa-cloud-rain",
                    },
                    {
                        "day": "Thu",
                        "temp": 23,
                        "condition": "Cloudy",
                        "icon": "fa-cloud",
                    },
                    {"day": "Fri", "temp": 26, "condition": "Sunny", "icon": "fa-sun"},
                ],
            }

            return jsonify(weather_data), 200

        except Exception as e:
            return jsonify({"status": "error", "message": str(e)}), 400

    @app.route("/crop_recommendations", methods=["GET"])
    def get_crop_recommendations():
        """API endpoint to get crop recommendations based on weather"""
        try:
            weather_condition = request.args.get("condition", "Sunny")

            crop_database = {
                "Sunny": [
                    {
                        "name": "Tomatoes",
                        "icon": "fa-apple-alt",
                        "temp": "20-30°C",
                        "duration": "75-90 days",
                        "status": "optimal",
                    },
                    {
                        "name": "Peppers",
                        "icon": "fa-pepper-hot",
                        "temp": "18-27°C",
                        "duration": "60-90 days",
                        "status": "optimal",
                    },
                    {
                        "name": "Corn",
                        "icon": "fa-seedling",
                        "temp": "21-30°C",
                        "duration": "60-100 days",
                        "status": "good",
                    },
                    {
                        "name": "Cucumbers",
                        "icon": "fa-leaf",
                        "temp": "18-27°C",
                        "duration": "50-70 days",
                        "status": "optimal",
                    },
                    {
                        "name": "Watermelon",
                        "icon": "fa-water",
                        "temp": "22-30°C",
                        "duration": "70-85 days",
                        "status": "good",
                    },
                ],
                "Rainy": [
                    {
                        "name": "Rice",
                        "icon": "fa-tint",
                        "temp": "20-35°C",
                        "duration": "90-120 days",
                        "status": "optimal",
                    },
                    {
                        "name": "Spinach",
                        "icon": "fa-leaf",
                        "temp": "15-20°C",
                        "duration": "40-50 days",
                        "status": "good",
                    },
                    {
                        "name": "Broccoli",
                        "icon": "fa-tree",
                        "temp": "18-23°C",
                        "duration": "60-90 days",
                        "status": "optimal",
                    },
                    {
                        "name": "Cabbage",
                        "icon": "fa-seedling",
                        "temp": "15-20°C",
                        "duration": "80-180 days",
                        "status": "moderate",
                    },
                ],
                "Cloudy": [
                    {
                        "name": "Lettuce",
                        "icon": "fa-leaf",
                        "temp": "15-20°C",
                        "duration": "45-55 days",
                        "status": "optimal",
                    },
                    {
                        "name": "Carrots",
                        "icon": "fa-carrot",
                        "temp": "15-20°C",
                        "duration": "70-80 days",
                        "status": "good",
                    },
                    {
                        "name": "Cauliflower",
                        "icon": "fa-seedling",
                        "temp": "15-20°C",
                        "duration": "55-100 days",
                        "status": "moderate",
                    },
                    {
                        "name": "Kale",
                        "icon": "fa-leaf",
                        "temp": "13-24°C",
                        "duration": "55-75 days",
                        "status": "good",
                    },
                ],
                "Partly Cloudy": [
                    {
                        "name": "Beans",
                        "icon": "fa-seedling",
                        "temp": "18-27°C",
                        "duration": "50-60 days",
                        "status": "optimal",
                    },
                    {
                        "name": "Peas",
                        "icon": "fa-seedling",
                        "temp": "13-18°C",
                        "duration": "60-70 days",
                        "status": "good",
                    },
                    {
                        "name": "Potatoes",
                        "icon": "fa-seedling",
                        "temp": "15-20°C",
                        "duration": "70-120 days",
                        "status": "moderate",
                    },
                ],
            }

            recommendations = crop_database.get(
                weather_condition, crop_database["Sunny"]
            )
            return (
                jsonify(
                    {
                        "status": "success",
                        "weather_condition": weather_condition,
                        "recommendations": recommendations,
                    }
                ),
                200,
            )

        except Exception as e:
            return jsonify({"status": "error", "message": str(e)}), 400

    @app.route("/refresh_weather", methods=["POST"])
    def refresh_weather():
        """API endpoint to manually refresh weather data"""
        try:
            import random

            conditions = ["Sunny", "Partly Cloudy", "Cloudy", "Rainy"]
            new_condition = random.choice(conditions)

            icon_map = {
                "Sunny": "fa-sun",
                "Partly Cloudy": "fa-cloud-sun",
                "Cloudy": "fa-cloud",
                "Rainy": "fa-cloud-rain",
            }

            new_weather_data = {
                "current": {
                    "temp": round(20 + random.random() * 10, 1),
                    "condition": new_condition,
                    "location": "AgroFarm Main Field",
                    "windSpeed": random.randint(10, 25),
                    "humidity": random.randint(50, 85),
                    "pressure": random.randint(1000, 1020),
                    "visibility": random.randint(5, 15),
                    "icon": icon_map[new_condition],
                }
            }

            return (
                jsonify(
                    {
                        "status": "success",
                        "message": "Weather data refreshed successfully",
                        "weather_data": new_weather_data,
                    }
                ),
                200,
            )

        except Exception as e:
            return jsonify({"status": "error", "message": str(e)}), 400

    # ===========================
    # E-COMMERCE ROUTES
    # ===========================
    # ===========================
# E-COMMERCE ROUTES - UPDATED
# ===========================

    @app.route("/marketplace")
    @login_required
    def marketplace():
        """Marketplace main page"""
        return render_template("marketplace.html")

    # Seller Management Routes
    @app.route("/api/marketplace/seller/apply", methods=["POST"])
    @login_required
    def apply_seller():
        """Apply to become a seller"""
        try:
            data = request.get_json()
            
            # Check if user already applied
            existing_application = SellerApplication.query.filter_by(
                user_id=current_user.id, 
                status='pending'
            ).first()
            
            if existing_application:
                return jsonify({
                    "success": False, 
                    "error": "You already have a pending seller application"
                }), 400
            
            # Check if user is already a seller
            existing_seller = Farmer.query.filter_by(user_id=current_user.id).first()
            if existing_seller:
                return jsonify({
                    "success": False, 
                    "error": "You are already a registered seller"
                }), 400
            
            # Create seller application
            application = SellerApplication(
                user_id=current_user.id,
                store_name=data["store_name"],
                store_category=data["store_category"],
                phone=data["phone"],
                address=data["address"],
                description=data.get("description", ""),
                status="pending"
            )
            
            db.session.add(application)
            db.session.commit()
            
            # Send notification to admin (you can implement this)
            # notify_admin_about_seller_application(application)
            
            return jsonify({
                "success": True,
                "message": "Seller application submitted successfully! It will be reviewed by our team."
            })
            
        except Exception as e:
            db.session.rollback()
            return jsonify({"success": False, "error": str(e)}), 500

    @app.route("/api/marketplace/seller/status")
    @login_required
    def get_seller_status():
        """Get seller application status for current user"""
        try:
            # Check if user is already a seller
            seller = Farmer.query.filter_by(user_id=current_user.id).first()
            if seller:
                return jsonify({
                    "success": True,
                    "is_approved": True,
                    "has_pending_application": False,
                    "seller_info": {
                        "store_name": seller.farm_name,
                        "status": seller.status
                    }
                })
            
            # Check for pending applications
            pending_application = SellerApplication.query.filter_by(
                user_id=current_user.id, 
                status='pending'
            ).first()
            
            if pending_application:
                return jsonify({
                    "success": True,
                    "is_approved": False,
                    "has_pending_application": True,
                    "application_date": pending_application.applied_at.isoformat()
                })
            
            return jsonify({
                "success": True,
                "is_approved": False,
                "has_pending_application": False
            })
            
        except Exception as e:
            return jsonify({"success": False, "error": str(e)}), 500

    @app.route("/api/marketplace/seller/applications")
    @login_required
    def get_seller_applications():
        """Get all seller applications (admin only)"""
        if not current_user.is_admin:
            return jsonify({"success": False, "error": "Admin access required"}), 403
        
        try:
            applications = SellerApplication.query.filter_by(status='pending').all()
            
            applications_data = []
            for app in applications:
                applications_data.append({
                    "id": app.id,
                    "user_id": app.user_id,
                    "user_name": app.user.full_name,
                    "user_email": app.user.email,
                    "store_name": app.store_name,
                    "store_category": app.store_category,
                    "phone": app.phone,
                    "address": app.address,
                    "description": app.description,
                    "applied_at": app.applied_at.isoformat(),
                    "status": app.status
                })
            
            return jsonify({"success": True, "applications": applications_data})
            
        except Exception as e:
            return jsonify({"success": False, "error": str(e)}), 500

    @app.route("/api/marketplace/seller/applications/<int:app_id>/review", methods=["POST"])
    @login_required
    def review_seller_application(app_id):
        """Approve or reject seller application (admin only)"""
        if not current_user.is_admin:
            return jsonify({"success": False, "error": "Admin access required"}), 403
        
        try:
            data = request.get_json()
            action = data.get("action")  # "approve" or "reject"
            
            if action not in ["approve", "reject"]:
                return jsonify({"success": False, "error": "Invalid action"}), 400
            
            application = SellerApplication.query.get_or_404(app_id)
            
            if action == "approve":
                # Create farmer/seller account
                farmer = Farmer(
                    user_id=application.user_id,
                    farm_name=application.store_name,
                    contact_phone=application.phone,
                    location=application.address,
                    contact_email=application.user.email,
                    farm_description=application.description,
                    status="active"
                )
                
                db.session.add(farmer)
                application.status = "approved"
                
                # Send notification to user (you can implement this)
                # notify_user_about_seller_approval(application.user, farmer)
                
            else:  # reject
                application.status = "rejected"
                rejection_reason = data.get("rejection_reason", "")
                # notify_user_about_seller_rejection(application.user, rejection_reason)
            
            db.session.commit()
            
            return jsonify({
                "success": True,
                "message": f"Seller application {action}ed successfully"
            })
            
        except Exception as e:
            db.session.rollback()
            return jsonify({"success": False, "error": str(e)}), 500

    # Enhanced Product Routes with Seller Support
    @app.route("/api/marketplace/products", methods=["GET"])
    def get_marketplace_products():
        """Get products with seller and category filters"""
        try:
            category_id = request.args.get("category_id")
            seller_id = request.args.get("seller_id")
            status = request.args.get("status", "active")
            search = request.args.get("search", "")

            query = Product.query

            if category_id:
                query = query.filter(Product.category_id == category_id)
            if seller_id:
                query = query.filter(Product.farmer_id == seller_id)
            if status != "all":
                query = query.filter(Product.status == status)
            if search:
                query = query.filter(
                    Product.name.ilike(f"%{search}%") |
                    Product.description.ilike(f"%{search}%")
                )

            products = query.all()

            products_data = []
            for product in products:
                products_data.append({
                    "id": product.id,
                    "name": product.name,
                    "description": product.description,
                    "price": product.price,
                    "category": product.category.name,
                    "category_id": product.category_id,
                    "farmer": product.farmer.farm_name,
                    "farmer_id": product.farmer_id,
                    "stock": product.stock_quantity,
                    "image": product.photo,
                    "status": product.status,
                    "rating": 4.5,  # You can calculate this from reviews
                    "reviews": 10,  # Count from reviews table
                    "created_at": product.created_at.isoformat(),
                })

            return jsonify({"success": True, "products": products_data})

        except Exception as e:
            return jsonify({"success": False, "error": str(e)}), 500

    @app.route("/api/marketplace/products", methods=["POST"])
    @login_required
    def add_marketplace_product():
        """Add new product - for admins and approved sellers"""
        try:
            data = request.get_json()
            
            # Check if user is authorized to add products
            is_admin = current_user.is_admin
            is_seller = Farmer.query.filter_by(user_id=current_user.id, status="active").first()
            
            if not is_admin and not is_seller:
                return jsonify({"success": False, "error": "Unauthorized"}), 403
            
            # For sellers, use their farmer ID
            farmer_id = data.get("farmer_id")
            if is_seller and not is_admin:
                farmer_id = is_seller.id
            
            product = Product(
                name=data["name"],
                description=data.get("description", ""),
                price=float(data["price"]),
                category_id=int(data["category_id"]),
                farmer_id=farmer_id,
                stock_quantity=int(data["stock_quantity"]),
                photo=data.get("image", ""),
                status=data.get("status", "active"),
                expires_at=datetime.utcnow() + timedelta(days=30),
            )

            db.session.add(product)
            db.session.commit()

            return jsonify({
                "success": True,
                "message": "Product added successfully",
                "product_id": product.id,
            })

        except Exception as e:
            db.session.rollback()
            return jsonify({"success": False, "error": str(e)}), 500

    # Enhanced Dashboard Stats
    @app.route("/api/marketplace/dashboard/stats")
    @login_required
    def get_marketplace_dashboard_stats():
        """Get marketplace dashboard statistics"""
        try:
            total_products = Product.query.count()
            total_orders = Order.query.count()
            total_farmers = Farmer.query.filter_by(status="active").count()
            total_customers = User.query.filter_by(role="user").count()
            pending_seller_apps = SellerApplication.query.filter_by(status="pending").count()

            # Recent activity
            recent_orders = Order.query.order_by(Order.created_at.desc()).limit(5).all()
            recent_products = Product.query.order_by(Product.created_at.desc()).limit(5).all()
            
            recent_activity = []
            
            for order in recent_orders:
                recent_activity.append({
                    "type": "order",
                    "message": f"New order from {order.customer_name}",
                    "amount": f"${order.total_amount}",
                    "time": order.created_at.strftime("%Y-%m-%d %H:%M"),
                })
                
            for product in recent_products:
                recent_activity.append({
                    "type": "product",
                    "message": f"New product: {product.name}",
                    "amount": f"${product.price}",
                    "time": product.created_at.strftime("%Y-%m-%d %H:%M"),
                })

            return jsonify({
                "success": True,
                "stats": {
                    "total_products": total_products,
                    "total_orders": total_orders,
                    "total_farmers": total_farmers,
                    "total_customers": total_customers,
                    "pending_seller_apps": pending_seller_apps,
                },
                "recent_activity": recent_activity,
            })

        except Exception as e:
            return jsonify({"success": False, "error": str(e)}), 500

    # Seller-specific routes
    @app.route("/api/marketplace/seller/products")
    @login_required
    def get_seller_products():
        """Get products for specific seller"""
        try:
            seller = Farmer.query.filter_by(user_id=current_user.id).first()
            if not seller:
                return jsonify({"success": False, "error": "Seller not found"}), 404
            
            products = Product.query.filter_by(farmer_id=seller.id).all()
            
            products_data = []
            for product in products:
                products_data.append({
                    "id": product.id,
                    "name": product.name,
                    "description": product.description,
                    "price": product.price,
                    "category": product.category.name,
                    "stock": product.stock_quantity,
                    "image": product.photo,
                    "status": product.status,
                    "sales_count": 0,  # You can calculate this from order items
                    "created_at": product.created_at.isoformat(),
                })

            return jsonify({"success": True, "products": products_data})

        except Exception as e:
            return jsonify({"success": False, "error": str(e)}), 500

    @app.route("/api/marketplace/seller/orders")
    @login_required
    def get_seller_orders():
        """Get orders for specific seller"""
        try:
            seller = Farmer.query.filter_by(user_id=current_user.id).first()
            if not seller:
                return jsonify({"success": False, "error": "Seller not found"}), 404
            
            # Get orders that contain products from this seller
            seller_orders = Order.query.join(OrderItem).join(Product).filter(
                Product.farmer_id == seller.id
            ).distinct().all()
            
            orders_data = []
            for order in seller_orders:
                # Get only items from this seller
                seller_items = [item for item in order.items 
                            if item.product.farmer_id == seller.id]
                
                total_amount = sum(item.total_price for item in seller_items)
                
                orders_data.append({
                    "id": order.id,
                    "order_number": order.id,
                    "customer_name": order.customer_name,
                    "customer_email": order.customer_email,
                    "total_amount": total_amount,
                    "status": order.status,
                    "order_date": order.created_at.isoformat(),
                    "items": [
                        {
                            "product_name": item.product.name,
                            "quantity": item.quantity,
                            "price": item.unit_price,
                            "total": item.total_price,
                        }
                        for item in seller_items
                    ],
                })

            return jsonify({"success": True, "orders": orders_data})

        except Exception as e:
            return jsonify({"success": False, "error": str(e)}), 500

    @app.route("/api/marketplace/seller/stats")
    @login_required
    def get_seller_stats():
        """Get seller dashboard statistics"""
        try:
            seller = Farmer.query.filter_by(user_id=current_user.id).first()
            if not seller:
                return jsonify({"success": False, "error": "Seller not found"}), 404
            
            total_products = Product.query.filter_by(farmer_id=seller.id).count()
            total_orders = Order.query.join(OrderItem).join(Product).filter(
                Product.farmer_id == seller.id
            ).distinct().count()
            
            # Calculate total sales
            total_sales = db.session.query(db.func.sum(OrderItem.total_price)).join(Product).filter(
                Product.farmer_id == seller.id
            ).scalar() or 0
            
            # Recent orders
            recent_orders = Order.query.join(OrderItem).join(Product).filter(
                Product.farmer_id == seller.id
            ).distinct().order_by(Order.created_at.desc()).limit(5).all()

            return jsonify({
                "success": True,
                "stats": {
                    "total_products": total_products,
                    "total_orders": total_orders,
                    "total_sales": float(total_sales),
                    "store_name": seller.farm_name,
                },
                "recent_orders": [
                    {
                        "order_number": order.id,
                        "customer_name": order.customer_name,
                        "total_amount": sum(item.total_price for item in order.items 
                                        if item.product.farmer_id == seller.id),
                        "status": order.status,
                        "order_date": order.created_at.strftime("%Y-%m-%d %H:%M"),
                    }
                    for order in recent_orders
                ],
            })

        except Exception as e:
            return jsonify({"success": False, "error": str(e)}), 500
        
        # AI Powerd Plant Doctor Route
        # =============================================

    # AI PLANT DOCTOR ROUTES
    # =============================================

    @app.route("/ai-plant-doctor")
    def ai_plant_doctor():
        """Main AI Plant Doctor page"""
        return render_template("ai_plant_doctor.html")

    # AI Analysis API
    @app.route("/api/analyze-plant", methods=["POST"])
    def analyze_plant():
        """
        Analyze plant image and return disease diagnosis
        Expected payload: {image: file, plant_type: string}
        """
        try:
            if "image" not in request.files:
                return jsonify({"error": "No image provided"}), 400

            image_file = request.files["image"]
            plant_type = request.form.get("plant_type", "unknown")

            if image_file.filename == "":
                return jsonify({"error": "No image selected"}), 400

            # Validate file type
            allowed_extensions = {"png", "jpg", "jpeg", "webp"}
            if not (
                "." in image_file.filename
                and image_file.filename.rsplit(".", 1)[1].lower() in allowed_extensions
            ):
                return (
                    jsonify({"error": "Invalid file type. Use PNG, JPG, or WebP"}),
                    400,
                )

            # Validate file size (5MB max)
            if len(image_file.read()) > 5 * 1024 * 1024:
                return jsonify({"error": "File too large. Max 5MB allowed"}), 400
            image_file.seek(0)  # Reset file pointer

            # Here you would integrate with your AI model
            # For now, using mock analysis - replace with actual AI service

            analysis_result = perform_ai_analysis(image_file, plant_type)

            # Save to analysis history
            save_analysis_to_history(analysis_result)

            return jsonify(analysis_result)

        except Exception as e:
            print(f"AI Analysis Error: {str(e)}")
            return jsonify({"error": "Analysis failed. Please try again."}), 500

    # Chat History APIs
    @app.route("/api/chat-history", methods=["GET"])
    def get_chat_history():
        """Get user's chat history"""
        user_id = request.args.get("user_id", "default")
        history = load_chat_history(user_id)
        return jsonify(history)

    @app.route("/api/save-chat", methods=["POST"])
    def save_chat():
        """Save chat message to history"""
        try:
            data = request.json
            user_id = data.get("user_id", "default")
            chat_data = data.get("chat_data")

            if not chat_data:
                return jsonify({"error": "No chat data provided"}), 400

            save_chat_to_history(user_id, chat_data)
            return jsonify({"status": "success", "message": "Chat saved"})

        except Exception as e:
            return jsonify({"error": str(e)}), 500

    @app.route("/api/clear-history", methods=["POST"])
    def clear_history():
        """Clear user's chat history"""
        try:
            data = request.json
            user_id = data.get("user_id", "default")
            clear_user_history(user_id)
            return jsonify({"status": "success", "message": "History cleared"})
        except Exception as e:
            return jsonify({"error": str(e)}), 500

    # AI Chat Response API
    @app.route("/api/chat-response", methods=["POST"])
    def chat_response():
        """Get AI response for text messages"""
        try:
            data = request.json
            user_message = data.get("message", "")
            chat_context = data.get("context", [])

            if not user_message:
                return jsonify({"error": "No message provided"}), 400

            # Generate AI response (replace with actual NLP model)
            ai_response = generate_ai_chat_response(user_message, chat_context)

            return jsonify(
                {"response": ai_response, "timestamp": datetime.now().isoformat()}
            )

        except Exception as e:
            return jsonify({"error": str(e)}), 500

    # =============================================
    # AI ANALYSIS FUNCTIONS
    # =============================================

    def perform_ai_analysis(image_file, plant_type):
        """
        Perform AI analysis on plant image
        Replace this with actual AI model integration
        """
        # Mock analysis - REPLACE WITH REAL AI MODEL CALL

        # Example integration with Plant.id API:
        # result = plant_id_analyze(image_file)

        # Example integration with custom TensorFlow model:
        # result = tf_model_analyze(image_file)

        diseases = [
            {
                "name": "Tomato Early Blight",
                "confidence": 87.5,
                "type": "fungal",
                "scientific_name": "Alternaria solani",
                "treatment": [
                    "Remove and destroy infected leaves immediately",
                    "Apply copper-based fungicide every 7-10 days",
                    "Use chlorothalonil or mancozeb sprays",
                    "Improve air circulation around plants",
                    "Water at the base to keep leaves dry",
                    "Avoid overhead watering",
                ],
                "prevention": [
                    "Rotate crops annually (3-4 year cycle)",
                    "Use disease-resistant tomato varieties",
                    "Space plants properly for good air flow",
                    "Stake plants to keep leaves off ground",
                    "Apply mulch to prevent soil splashing",
                    "Clean garden tools regularly",
                ],
                "symptoms": [
                    "Dark brown spots with concentric rings",
                    "Yellowing around the spots",
                    "Lower leaves affected first",
                    "Spots may have yellow halos",
                ],
            },
            {
                "name": "Powdery Mildew",
                "confidence": 65.2,
                "type": "fungal",
                "scientific_name": "Oidium neolycopersici",
                "treatment": [
                    "Apply sulfur dust or spray",
                    "Use potassium bicarbonate solution",
                    "Neem oil applications every 7-14 days",
                    "Milk spray (1 part milk to 9 parts water)",
                    "Remove severely infected leaves",
                ],
                "prevention": [
                    "Ensure good air circulation",
                    "Avoid crowded planting",
                    "Water in the morning only",
                    "Use resistant varieties when available",
                    "Maintain proper plant nutrition",
                ],
                "symptoms": [
                    "White powdery spots on leaves",
                    "Powdery growth on both leaf surfaces",
                    "Leaves may turn yellow and dry out",
                    "Young growth may be distorted",
                ],
            },
        ]

        return {
            "success": True,
            "plant_type": plant_type or "Tomato Plant",
            "overall_health": "Needs Attention",
            "health_score": 6.2,
            "diseases_detected": diseases,
            "recommendations": {
                "urgency": "medium",
                "summary": "Early blight detected with high confidence. Immediate treatment recommended.",
                "next_steps": [
                    "Begin fungicide treatment within 2-3 days",
                    "Remove visibly infected leaves today",
                    "Monitor plant daily for spread",
                    "Adjust watering practices immediately",
                ],
            },
            "analysis_id": str(uuid.uuid4()),
            "timestamp": datetime.now().isoformat(),
        }

    def generate_ai_chat_response(user_message, context):
        """
        Generate AI response for chat messages
        Replace with actual NLP model (GPT, custom model, etc.)
        """
        user_message_lower = user_message.lower()

        # Simple response logic - REPLACE WITH ACTUAL AI MODEL
        response_templates = {
            "greeting": "Hello! I'm your AI Plant Doctor 🌿🤖 I can help you identify plant diseases and provide treatment advice. You can upload photos of your plants or ask me questions!",
            "help": "I can help you with:\n• Plant disease identification from photos\n• Treatment recommendations\n• Prevention strategies\n• General plant care advice\n\nJust upload a clear photo of your plant for the best diagnosis!",
            "disease": "For accurate disease identification, please upload a clear photo of the affected plant. Make sure the image shows:\n• The entire plant\n• Close-up of affected areas\n• Both sides of the leaves\n\nI'll analyze it and provide specific treatment advice.",
            "treatment": "Treatment depends on the specific disease. Once you upload a photo, I can provide:\n• Specific fungicides/chemical treatments\n• Organic alternatives\n• Application instructions\n• Timing recommendations",
            "prevention": "General prevention tips:\n• Rotate crops annually\n• Use disease-resistant varieties\n• Maintain proper spacing\n• Water at plant base\n• Clean tools regularly\n• Monitor plants frequently",
            "upload": "Great! Click the upload area or drag & drop a photo of your plant. I'll analyze it and provide a detailed diagnosis with treatment options.",
            "thanks": "You're welcome! I'm here to help your plants stay healthy. Don't hesitate to ask if you have more questions or need to upload another photo!",
            "default": "I understand you're concerned about your plant's health. For the most accurate help, please upload a clear photo showing the affected areas. I can then identify any diseases and provide specific treatment recommendations.",
        }

        # Keyword matching - replace with actual NLP
        if any(word in user_message_lower for word in ["hello", "hi", "hey"]):
            return response_templates["greeting"]
        elif any(word in user_message_lower for word in ["help", "what can you do"]):
            return response_templates["help"]
        elif any(
            word in user_message_lower for word in ["disease", "sick", "unhealthy"]
        ):
            return response_templates["disease"]
        elif any(word in user_message_lower for word in ["treatment", "cure", "spray"]):
            return response_templates["treatment"]
        elif any(
            word in user_message_lower for word in ["prevent", "prevention", "avoid"]
        ):
            return response_templates["prevention"]
        elif any(
            word in user_message_lower
            for word in ["upload", "photo", "image", "picture"]
        ):
            return response_templates["upload"]
        elif any(word in user_message_lower for word in ["thank", "thanks"]):
            return response_templates["thanks"]
        else:
            return response_templates["default"]

    # =============================================
    # STORAGE FUNCTIONS (Simple file-based - replace with database)
    # =============================================

    def save_analysis_to_history(analysis_data):
        """Save analysis result to history file"""
        try:
            history_file = "plant_analysis_history.json"
            history = []

            # Load existing history
            if os.path.exists(history_file):
                with open(history_file, "r") as f:
                    history = json.load(f)

            # Add new analysis
            history.append({**analysis_data, "saved_at": datetime.now().isoformat()})

            # Keep only last 50 analyses
            history = history[-50:]

            # Save back to file
            with open(history_file, "w") as f:
                json.dump(history, f, indent=2)

        except Exception as e:
            print(f"Error saving analysis history: {e}")

    def load_chat_history(user_id="default"):
        """Load chat history for user"""
        try:
            history_file = f"chat_history_{user_id}.json"
            if os.path.exists(history_file):
                with open(history_file, "r") as f:
                    return json.load(f)
            return []
        except Exception as e:
            print(f"Error loading chat history: {e}")
            return []

    def save_chat_to_history(user_id, chat_data):
        """Save chat to user's history"""
        try:
            history_file = f"chat_history_{user_id}.json"
            history = load_chat_history(user_id)

            history.append({**chat_data, "timestamp": datetime.now().isoformat()})

            # Keep only last 100 messages
            history = history[-100:]

            with open(history_file, "w") as f:
                json.dump(history, f, indent=2)

        except Exception as e:
            print(f"Error saving chat history: {e}")

    def clear_user_history(user_id="default"):
        """Clear user's chat history"""
        try:
            history_file = f"chat_history_{user_id}.json"
            if os.path.exists(history_file):
                os.remove(history_file)
        except Exception as e:
            print(f"Error clearing history: {e}")

    # =============================================
    # REAL AI INTEGRATION EXAMPLES (Uncomment and configure as needed)
    # =============================================

    """
    # Example: Plant.id API Integration
    def plant_id_analyze(image_file):
        import requests
        
        api_key = "YOUR_PLANT_ID_API_KEY"
        api_url = "https://api.plant.id/v2/identify"
        
        # Prepare image
        files = {'images': image_file}
        data = {
            'api_key': api_key,
            'modifiers': ['crops_fast'],
            'plant_language': 'en',
            'plant_details': ['common_names', 'url', 'taxonomy'],
            'disease_details': ['common_names', 'url', 'description', 'treatment']
        }
        
        response = requests.post(api_url, files=files, data=data)
        return response.json()

    # Example: TensorFlow Model Integration  
    def tf_model_analyze(image_file):
        import tensorflow as tf
        import numpy as np
        from PIL import Image
        
        # Load your trained model
        model = tf.keras.models.load_model('plant_disease_model.h5')
        
        # Preprocess image
        img = Image.open(image_file)
        img = img.resize((224, 224))
        img_array = np.array(img) / 255.0
        img_array = np.expand_dims(img_array, axis=0)
        
        # Make prediction
        predictions = model.predict(img_array)
        
        # Process results
        class_names = ['Healthy', 'Early Blight', 'Late Blight', 'Powdery Mildew']  # Your class names
        predicted_class = class_names[np.argmax(predictions[0])]
        confidence = np.max(predictions[0])
        
        return {
            'disease': predicted_class,
            'confidence': float(confidence),
            'predictions': predictions[0].tolist()
        }

    # Example: Google Cloud Vision AI
    def google_vision_analyze(image_file):
        from google.cloud import vision
        
        client = vision.ImageAnnotatorClient()
        
        # Read image content
        content = image_file.read()
        image = vision.Image(content=content)
        
        # Perform label detection
        response = client.label_detection(image=image)
        labels = response.label_annotations
        
        # Process results for plant diseases
        disease_labels = [label for label in labels if any(
            disease_term in label.description.lower() for disease_term in 
            ['blight', 'mildew', 'rot', 'spot', 'rust', 'mold']
        )]
        
        return {
            'labels': [{'description': label.description, 'score': label.score} 
                    for label in disease_labels]
        }
    """

    # ======= Video Consultation Routes =======
    @app.route("/video-consultation")
    def video_consultation():
        """Main video consultation page"""
        return render_template("consultation.html")

    @app.route("/api/consultation/stats")
    def get_consultation_stats():
        """Get real-time consultation statistics"""
        stats = {
            "online_experts": len([e for e in experts_online.values() if e["online"]]),
            "avg_wait_time": "2 min",
            "rating": "4.8",
            "active_calls": len(active_calls),
        }
        return jsonify(stats)

    @app.route("/api/consultation/request", methods=["POST"])
    def submit_consultation_request():
        """Submit a consultation request"""
        data = request.get_json()

        request_id = str(uuid.uuid4())
        consultation_requests[request_id] = {
            "id": request_id,
            "issue_type": data.get("issue_type"),
            "description": data.get("description"),
            "urgency": data.get("urgency"),
            "status": "pending",
            "created_at": datetime.now().isoformat(),
            "user_id": session.get("user_id", "anonymous"),
        }

        # In real app, notify available experts
        notify_experts(consultation_requests[request_id])

        return jsonify(
            {
                "success": True,
                "request_id": request_id,
                "message": "Consultation request submitted successfully",
            }
        )

    @app.route("/api/consultation/experts")
    def get_available_experts():
        """Get list of available experts"""
        experts = [
            {
                "id": 1,
                "name": "Dr. Green",
                "specialty": "Plant Pathology",
                "rating": 4.8,
                "experience": "15 years",
                "education": "PhD in Agriculture",
                "online": True,
                "specializations": [
                    "Plant Diseases",
                    "Soil Health",
                    "Organic Farming",
                    "Pest Management",
                ],
            },
            {
                "id": 2,
                "name": "Dr. Sharma",
                "specialty": "Soil Science",
                "rating": 4.9,
                "experience": "12 years",
                "education": "PhD in Soil Science",
                "online": True,
                "specializations": [
                    "Soil Testing",
                    "Fertilizer",
                    "Irrigation",
                    "Crop Rotation",
                ],
            },
            {
                "id": 3,
                "name": "Ms. Chen",
                "specialty": "Organic Farming",
                "rating": 4.7,
                "experience": "8 years",
                "education": "MSc in Organic Agriculture",
                "online": True,
                "specializations": [
                    "Organic Pest Control",
                    "Composting",
                    "Sustainable Farming",
                ],
            },
        ]

        return jsonify(experts)

    @app.route("/api/consultation/start-call", methods=["POST"])
    def start_video_call():
        """Initialize a video call"""
        data = request.get_json()
        call_id = str(uuid.uuid4())

        active_calls[call_id] = {
            "id": call_id,
            "user_id": session.get("user_id", "anonymous"),
            "expert_id": data.get("expert_id"),
            "started_at": datetime.now().isoformat(),
            "status": "active",
        }

        # Generate WebRTC signaling data (simplified)
        signaling_data = {
            "call_id": call_id,
            "ice_servers": [{"urls": "stun:stun.l.google.com:19302"}],
        }

        return jsonify(
            {"success": True, "call_id": call_id, "signaling_data": signaling_data}
        )

    @app.route("/api/consultation/end-call", methods=["POST"])
    def end_video_call():
        """End an active video call"""
        data = request.get_json()
        call_id = data.get("call_id")

        if call_id in active_calls:
            active_calls[call_id]["ended_at"] = datetime.now().isoformat()
            active_calls[call_id]["status"] = "ended"

            # In real app, clean up resources and notify both parties
            return jsonify({"success": True, "message": "Call ended successfully"})

        return jsonify({"success": False, "message": "Call not found"}), 404

    @app.route("/api/consultation/send-message", methods=["POST"])
    def send_chat_message():
        """Send a chat message"""
        data = request.get_json()

        message = {
            "id": str(uuid.uuid4()),
            "call_id": data.get("call_id"),
            "sender": data.get("sender", "user"),
            "message": data.get("message"),
            "timestamp": datetime.now().isoformat(),
            "type": "text",
        }

        # In real app, store message and broadcast to other participant
        broadcast_message(message)

        return jsonify({"success": True, "message_id": message["id"]})

    @app.route("/api/consultation/expert-status", methods=["POST"])
    def update_expert_status():
        """Update expert online status"""
        data = request.get_json()
        expert_id = data.get("expert_id")

        experts_online[expert_id] = {
            "online": data.get("online", False),
            "last_seen": datetime.now().isoformat(),
            "specialty": data.get("specialty"),
        }

        return jsonify({"success": True})

    # Helper functions for consultation
    def notify_experts(consultation_request):
        """Notify available experts about new consultation request"""
        # In real app, this would use WebSockets or push notifications
        print(f"Notifying experts about new request: {consultation_request['id']}")

    def broadcast_message(message):
        """Broadcast message to call participants"""
        # In real app, this would use WebSockets
        print(f"Broadcasting message: {message}")

    # ===========================
    # ERROR HANDLERS
    # ===========================
    @app.errorhandler(404)
    def page_not_found(e):
        return render_template("404.html"), 404

    @app.errorhandler(500)
    def internal_error(e):
        db.session.rollback()
        return render_template("500.html"), 500

        # ===========================
    # DATABASE INITIALIZATION
    # ===========================
    with app.app_context():
        db.create_all()
        # Initialize data on first run
        init_categories()
        init_product_categories()
        init_marketplace_settings()
        init_kb_categories()  # <-- ADD THIS LINE
    
    return app 
# ===========================
# RUN THE APPLICATION
# ===========================
if __name__ == "__main__":
    app = create_app()
    app.run(debug=True)