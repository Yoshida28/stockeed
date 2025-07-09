# Stocked - Business Management App

A powerful, modern, offline-first business management, accounting, stock management, and distributor-retail client commerce mobile app built with Flutter.

## 🚀 Features

### Core Features
- **Offline-First Architecture**: Works seamlessly without internet connection
- **Real-time Sync**: Automatic synchronization with cloud when online
- **Role-Based Access**: Separate interfaces for Distributors and Retail Clients
- **Glassmorphic UI**: Modern Cupertino-styled interface with beautiful glass effects

### Stock Management
- **Inventory Tracking**: Real-time stock levels and movements
- **Low Stock Alerts**: Automatic notifications for items running low
- **Category Management**: Organized product categorization
- **Barcode/SKU Support**: Easy product identification
- **Stock History**: Complete audit trail of stock movements

### Order Management
- **Order Creation**: Quick and easy order processing
- **Status Tracking**: Real-time order status updates
- **Client Management**: Comprehensive client database
- **Order History**: Complete order tracking and history

### Financial Management
- **Payment Tracking**: Multiple payment modes (Cash, UPI, Bank Transfer, Cheque)
- **Expense Management**: Track business expenses
- **GST Integration**: Built-in tax calculation and compliance
- **Outstanding Dues**: Track pending payments and receivables
- **Financial Analytics**: Comprehensive business insights

### Voucher System
- **Sales Vouchers**: Record sales transactions
- **Purchase Vouchers**: Track purchase transactions
- **Payment Vouchers**: Record payments and receipts
- **Journal Entries**: Manual accounting entries

## 🏗️ Architecture

### Technology Stack
- **Frontend**: Flutter with Cupertino widgets
- **State Management**: Riverpod for reactive state management
- **Local Database**: Isar for offline data storage
- **Cloud Database**: Supabase for real-time cloud sync
- **Authentication**: Supabase Auth
- **File Storage**: Supabase Storage
- **UI Design**: Glassmorphic design with Google Fonts

### Project Structure
```
lib/
├── core/
│   ├── constants/          # App constants and configuration
│   ├── models/            # Data models (User, Item, Order, etc.)
│   ├── services/          # Database and sync services
│   └── theme/             # App theme and styling
├── features/
│   ├── auth/              # Authentication feature
│   ├── dashboard/         # Dashboard feature
│   └── stock/             # Stock management feature
└── main.dart              # App entry point
```

### Data Models
- **User**: User profiles with role-based access
- **Item**: Product inventory with stock tracking
- **Order**: Customer orders with status tracking
- **OrderItem**: Individual items in orders
- **Voucher**: Financial transaction records
- **Payment**: Payment tracking and history
- **Expense**: Business expense management

## 🛠️ Setup Instructions

### Prerequisites
- Flutter SDK (3.8.0 or higher)
- Dart SDK (3.1.0 or higher)
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd stocked
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**
   - The app is already configured with Supabase credentials
   - Create the following tables in your Supabase database:
     - `users`
     - `items`
     - `orders`
     - `order_items`
     - `vouchers`
     - `payments`
     - `expenses`

4. **Generate Isar models**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

### Supabase Database Schema

#### Users Table
```sql
CREATE TABLE users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  name TEXT,
  phone TEXT,
  company_name TEXT,
  role TEXT NOT NULL,
  address TEXT,
  gst_number TEXT,
  pan_number TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### Items Table
```sql
CREATE TABLE items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT,
  unit_price DECIMAL(10,2),
  gst_percentage DECIMAL(5,2),
  opening_stock INTEGER DEFAULT 0,
  current_stock INTEGER DEFAULT 0,
  low_stock_threshold INTEGER DEFAULT 10,
  description TEXT,
  barcode TEXT,
  sku TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## 📱 User Roles

### Distributor
- **Dashboard**: Overview of business metrics
- **Stock Management**: Add, edit, and track inventory
- **Order Management**: Process and track customer orders
- **Voucher Management**: Create and manage financial vouchers
- **Payment Tracking**: Monitor payments and outstanding dues
- **Expense Management**: Track business expenses
- **Analytics**: Business performance insights

### Retail Client
- **Home**: View available products and place orders
- **Order History**: Track past and current orders
- **Payment Management**: View payment history and outstanding dues
- **Profile**: Manage personal and business information

## 🔄 Sync Mechanism

### Offline-First Approach
1. **Local Storage**: All data is stored locally using Isar database
2. **Offline Operations**: Full functionality available without internet
3. **Background Sync**: Automatic synchronization when connection is restored
4. **Conflict Resolution**: Smart conflict resolution for data consistency

### Sync Process
1. **Data Collection**: Gather all locally modified data
2. **Connection Check**: Verify internet connectivity
3. **Cloud Sync**: Upload local changes to Supabase
4. **Download Updates**: Fetch latest data from cloud
5. **Local Update**: Update local database with cloud changes

## 🎨 UI/UX Design

### Design Principles
- **Glassmorphic**: Modern glass-like interface elements
- **Cupertino Style**: iOS-native look and feel
- **Responsive**: Adapts to different screen sizes
- **Accessible**: Follows accessibility guidelines
- **Intuitive**: User-friendly navigation and interactions

### Color Scheme
- **Primary**: Indigo (#6366F1)
- **Secondary**: Purple (#8B5CF6)
- **Success**: Green (#10B981)
- **Warning**: Amber (#F59E0B)
- **Error**: Red (#EF4444)
- **Info**: Blue (#3B82F6)

## 📊 Features in Detail

### Stock Management
- **Add Items**: Comprehensive item creation with all necessary details
- **Edit Items**: Modify item information and stock levels
- **Stock Alerts**: Automatic notifications for low stock items
- **Category Filtering**: Organize items by categories
- **Search Functionality**: Quick item search and filtering
- **Stock History**: Complete audit trail of stock movements

### Order Management
- **Create Orders**: Quick order creation with multiple items
- **Order Status**: Track order progress (Pending, Accepted, Dispatched, Delivered)
- **Client Selection**: Choose from existing clients or add new ones
- **Payment Integration**: Link orders with payment tracking
- **Order History**: Complete order tracking and reporting

### Financial Management
- **Payment Tracking**: Record and track all payments
- **Expense Management**: Categorize and track business expenses
- **GST Calculation**: Automatic tax calculation and compliance
- **Outstanding Dues**: Monitor pending payments and receivables
- **Financial Reports**: Generate comprehensive financial reports

## 🔧 Development

### Code Generation
The app uses code generation for Isar models. After making changes to models:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Testing
```bash
flutter test
```

### Building for Production
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## 📈 Roadmap

### Phase 1 (Current)
- ✅ Basic authentication and user management
- ✅ Stock management with offline support
- ✅ Dashboard with basic metrics
- ✅ Glassmorphic UI implementation

### Phase 2 (Next)
- 🔄 Order management system
- 🔄 Voucher management
- 🔄 Payment tracking
- 🔄 Expense management

### Phase 3 (Future)
- 📋 Advanced analytics and reporting
- 📋 Multi-currency support
- 📋 Barcode scanning
- 📋 Invoice generation
- 📋 Email notifications
- 📋 Advanced user roles and permissions

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation

## 🔐 Security

- All sensitive data is encrypted
- Supabase provides enterprise-grade security
- Local data is protected with device security
- Regular security updates and patches

---

**Stocked** - Empowering businesses with modern, efficient, and reliable management solutions.
#   s t o c k e e d  
 #   s t o c k e e d  
 #   s t o c k e e d  
 