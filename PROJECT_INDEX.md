# Stocked - Project Index

## 📋 Project Overview

**Stocked** is a powerful, modern, offline-first business management application built with Flutter. It serves as a comprehensive solution for distributors and retail clients, providing stock management, order processing, financial tracking, and business analytics.

### Key Features
- **Offline-First Architecture**: Full functionality without internet connection
- **Real-time Sync**: Automatic cloud synchronization when online
- **Role-Based Access**: Separate interfaces for Distributors and Retail Clients
- **Glassmorphic UI**: Modern Cupertino-styled interface with beautiful glass effects
- **Comprehensive Business Management**: Stock, orders, payments, expenses, and vouchers

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
stocked/
├── lib/                          # Main application code
│   ├── core/                     # Core application components
│   │   ├── constants/            # App constants and configuration
│   │   ├── models/               # Data models with Isar annotations
│   │   ├── services/             # Database and sync services
│   │   └── theme/                # App theme and styling
│   ├── features/                 # Feature-based modules
│   │   ├── auth/                 # Authentication feature
│   │   ├── dashboard/            # Dashboard feature
│   │   └── stock/                # Stock management feature
│   └── main.dart                 # Application entry point
├── web/                          # Web platform files
├── android/                      # Android platform files
├── ios/                          # iOS platform files
├── windows/                      # Windows platform files
├── linux/                        # Linux platform files
├── macos/                        # macOS platform files
├── test/                         # Test files
├── pubspec.yaml                  # Dependencies and configuration
├── pubspec.lock                  # Locked dependency versions
├── database_schema.sql           # Supabase database schema
└── README.md                     # Project documentation
```

## 📁 Detailed File Structure

### Core Application (`lib/core/`)

#### Constants (`lib/core/constants/`)
- **app_constants.dart**: Application-wide constants including Supabase configuration

#### Models (`lib/core/models/`)
- **user_model.dart**: User data model with role-based access
- **item_model.dart**: Product inventory model with stock tracking
- **order_model.dart**: Customer order model with status tracking
- **order_item_model.dart**: Individual items within orders
- **voucher_model.dart**: Financial transaction records
- **payment_model.dart**: Payment tracking and history
- **expense_model.dart**: Business expense management
- **Generated files (*.g.dart)**: Isar database code generation

#### Services (`lib/core/services/`)
- **database_service.dart**: Local Isar database initialization and management
- **sync_service.dart**: Cloud synchronization service for offline-first architecture

#### Theme (`lib/core/theme/`)
- **app_theme.dart**: Application theme configuration with glassmorphic design

### Features (`lib/features/`)

#### Authentication (`lib/features/auth/`)
```
auth/
└── presentation/
    ├── providers/                # Auth-related state providers
    └── screens/
        └── auth_screen.dart      # Authentication screen
```

#### Dashboard (`lib/features/dashboard/`)
```
dashboard/
└── presentation/
    └── screens/
        └── dashboard_screen.dart # Main dashboard with business metrics
```

#### Stock Management (`lib/features/stock/`)
```
stock/
└── presentation/
    ├── providers/                # Stock-related state providers
    ├── screens/
    │   └── stock_management_screen.dart # Stock management interface
    └── widgets/                  # Reusable stock-related widgets
```

### Platform-Specific Directories
- **android/**: Android-specific configuration and resources
- **ios/**: iOS-specific configuration and resources
- **web/**: Web platform files (index.html, manifest.json, favicon.png)
- **windows/**: Windows desktop configuration
- **linux/**: Linux desktop configuration
- **macos/**: macOS desktop configuration

## 🗄️ Database Schema

### Core Tables
1. **users**: User profiles with role-based access (distributor/retail_client)
2. **items**: Product inventory with stock tracking
3. **orders**: Customer orders with status tracking
4. **order_items**: Individual items within orders
5. **vouchers**: Financial transaction records
6. **voucher_items**: Items within vouchers
7. **payments**: Payment tracking and history
8. **expenses**: Business expense management
9. **stock_movements**: Audit trail for stock changes
10. **settings**: Application configuration

### Key Features
- **UUID Primary Keys**: All tables use UUID for unique identification
- **Sync Status Tracking**: Each table includes sync_status and last_synced_at fields
- **Cloud ID Mapping**: Maps local IDs to cloud IDs for synchronization
- **Automatic Timestamps**: Created_at and updated_at fields with triggers
- **Referential Integrity**: Foreign key constraints for data consistency
- **Indexes**: Optimized database performance with strategic indexing

## 🔧 Dependencies

### Core Dependencies
- **flutter**: Flutter SDK
- **cupertino_icons**: iOS-style icons
- **google_fonts**: Typography
- **flutter_riverpod**: State management
- **isar**: Local database
- **isar_flutter_libs**: Isar Flutter integration
- **path_provider**: File system access
- **supabase_flutter**: Cloud services
- **connectivity_plus**: Network connectivity
- **intl**: Internationalization

### Development Dependencies
- **flutter_test**: Testing framework
- **flutter_lints**: Code quality
- **build_runner**: Code generation
- **isar_generator**: Isar model generation

## 🚀 Application Flow

### Startup Process
1. **WidgetsFlutterBinding.ensureInitialized()**: Initialize Flutter bindings
2. **Supabase.initialize()**: Initialize cloud services
3. **DatabaseService.initialize()**: Initialize local Isar database
4. **SyncService.initialize()**: Initialize synchronization service
5. **ProviderScope**: Wrap app with Riverpod provider scope
6. **AuthWrapper**: Handle authentication state

### Authentication Flow
- **StreamBuilder**: Listens to Supabase auth state changes
- **Session Check**: Redirects to Dashboard if authenticated
- **Auth Screen**: Shows login/signup if not authenticated

### Data Flow
1. **Local Operations**: All operations performed on local Isar database
2. **Offline Support**: Full functionality without internet
3. **Background Sync**: Automatic synchronization when online
4. **Conflict Resolution**: Smart conflict resolution for data consistency

## 🎨 UI/UX Design

### Design Principles
- **Glassmorphic**: Modern glass-like interface elements
- **Cupertino Style**: iOS-native look and feel
- **Responsive**: Adapts to different screen sizes
- **Accessible**: Follows accessibility guidelines

### Color Scheme
- **Primary**: Indigo (#6366F1)
- **Secondary**: Purple (#8B5CF6)
- **Success**: Green (#10B981)
- **Warning**: Amber (#F59E0B)
- **Error**: Red (#EF4444)
- **Info**: Blue (#3B82F6)

## 👥 User Roles

### Distributor
- **Dashboard**: Business metrics and overview
- **Stock Management**: Inventory tracking and management
- **Order Management**: Process and track customer orders
- **Voucher Management**: Financial transaction records
- **Payment Tracking**: Monitor payments and outstanding dues
- **Expense Management**: Track business expenses
- **Analytics**: Business performance insights

### Retail Client
- **Home**: View available products and place orders
- **Order History**: Track past and current orders
- **Payment Management**: View payment history and outstanding dues
- **Profile**: Manage personal and business information

## 🔄 Synchronization

### Offline-First Approach
1. **Local Storage**: All data stored locally using Isar
2. **Offline Operations**: Full functionality without internet
3. **Background Sync**: Automatic sync when connection restored
4. **Conflict Resolution**: Smart conflict resolution

### Sync Process
1. **Data Collection**: Gather locally modified data
2. **Connection Check**: Verify internet connectivity
3. **Cloud Sync**: Upload local changes to Supabase
4. **Download Updates**: Fetch latest data from cloud
5. **Local Update**: Update local database with cloud changes

## 🛠️ Development Commands

### Setup
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Running
```bash
flutter run
```

### Testing
```bash
flutter test
```

### Building
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web
```

## 📊 Key Features Implementation

### Stock Management
- **Add/Edit Items**: Comprehensive item creation and modification
- **Stock Alerts**: Automatic notifications for low stock
- **Category Filtering**: Organized product categorization
- **Search Functionality**: Quick item search and filtering
- **Stock History**: Complete audit trail

### Order Management
- **Create Orders**: Quick order creation with multiple items
- **Order Status**: Track progress (Pending, Accepted, Dispatched, Delivered)
- **Client Selection**: Choose from existing clients or add new ones
- **Payment Integration**: Link orders with payment tracking
- **Order History**: Complete order tracking and reporting

### Financial Management
- **Payment Tracking**: Record and track all payments
- **Expense Management**: Categorize and track business expenses
- **GST Calculation**: Automatic tax calculation and compliance
- **Outstanding Dues**: Monitor pending payments and receivables
- **Financial Reports**: Generate comprehensive financial reports

## 🔐 Security Features

- **Encrypted Data**: All sensitive data is encrypted
- **Supabase Security**: Enterprise-grade cloud security
- **Local Protection**: Device-level data protection
- **Regular Updates**: Security patches and updates

## 📈 Development Roadmap

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

This project is licensed under the MIT License.

---

**Stocked** - Empowering businesses with modern, efficient, and reliable management solutions. 