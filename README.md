# PM-AJAY Agency Mapping Platform

A comprehensive, production-ready government solution for agency mapping and project management, built with Flutter and Supabase, featuring innovative mapping with real-time fund flow visualization, five specialized dashboards, and PostGIS-enabled spatial queries.

## 🚀 Features

### Core Capabilities
- **Interactive Map Visualization** with color-coded location pins
- **Five Specialized Dashboards** (Centre, State, Agency, Overwatch, Public)
- **Real-time Fund Flow Tracking** with animated visualizations
- **Spatial Queries** powered by PostGIS
- **Role-based Access Control** with comprehensive RLS policies
- **Offline-first Architecture** for field operations

### Innovative Features
- **Color-coded Location Pins**: Status-based markers (green=completed, red=delayed, blue=in-progress, orange=on-hold)
- **Filterable Geographic Views**: Filter by agency type, project component, fund status, completion percentage
- **Real-time Location Updates**: Live project status changes reflected instantly on maps
- **Fund Flow Waterfall**: Visual representation of fund journey from Centre to beneficiary
- **Spatial Proximity Analysis**: Find nearest agencies, projects, and resources

## 📋 Prerequisites

- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)
- Supabase Account
- Node.js (for Supabase CLI)

## 🛠️ Installation

### 1. Clone the Repository
```bash
git clone <repository-url>
cd PROTOTYPE
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Supabase

Update [`lib/core/config/supabase_config.dart`](lib/core/config/supabase_config.dart:1) with your Supabase credentials:

```dart
static const String url = 'https://your-project.supabase.co';
static const String anonKey = 'your-anon-key-here';
```

### 4. Run Database Migrations

```bash
# Initialize Supabase
supabase init

# Run migrations
supabase db push
```

The migrations include:
- [`001_initial_schema.sql`](supabase/migrations/001_initial_schema.sql:1) - Core database schema with PostGIS
- [`002_rls_policies.sql`](supabase/migrations/002_rls_policies.sql:1) - Row Level Security policies
- [`003_spatial_functions.sql`](supabase/migrations/003_spatial_functions.sql:1) - Spatial query functions

## 🏃 Running the Application

```bash
# Run in development mode
flutter run

# Build for production
flutter build apk  # Android
flutter build ios  # iOS
flutter build web  # Web
```

## 📱 Application Structure

```
lib/
├── core/
│   ├── config/          # Configuration files
│   ├── models/          # Data models
│   ├── router/          # Navigation routing
│   ├── services/        # Business logic services
│   └── theme/           # App theming
├── features/
│   ├── auth/            # Authentication pages
│   ├── dashboard/       # Dashboard implementations
│   ├── fund_flow/       # Fund flow visualization
│   └── maps/            # Map widgets
└── main.dart            # Application entry point
```

## 🔐 User Roles

The platform supports five distinct user roles:

1. **Centre Admin** - National-level oversight and management
2. **State Officer** - State-level coordination and monitoring
3. **Agency User** - Project implementation and milestone tracking
4. **Overwatch** - Cross-hierarchy audit and quality assurance
5. **Public** - Transparent access to project information

## 🗺️ Key Components

### Interactive Map Widget
[`lib/features/maps/widgets/interactive_map_widget.dart`](lib/features/maps/widgets/interactive_map_widget.dart:1)

Features:
- Color-coded project status markers
- Agency location markers with coverage areas
- Real-time status updates
- Tap interactions with detailed info cards

### Fund Flow Visualizer
[`lib/features/fund_flow/widgets/fund_flow_visualizer.dart`](lib/features/fund_flow/widgets/fund_flow_visualizer.dart:1)

Visualizations:
- Waterfall charts showing fund progression
- Pie charts for status distribution
- Transaction timeline with filtering

### Spatial Query Service
[`lib/core/services/spatial_query_service.dart`](lib/core/services/spatial_query_service.dart:1)

Capabilities:
- Find nearby agencies and projects
- Calculate distances
- Check coverage areas
- Boundary-based queries

## 📊 Dashboards

### 1. Centre Dashboard
- National agency heatmap
- Fund flow waterfall visualization
- Predictive analytics with AI insights

### 2. State Dashboard
- District-wise performance maps
- Agency capacity optimizer
- Fund allocation simulator

### 3. Agency Dashboard
- Project geo-tracker with GPS validation
- Smart milestone claims with evidence verification
- Resource proximity mapping

### 4. Overwatch Dashboard
- Cross-hierarchy audit trail
- Risk assessment heat maps
- Quality assurance command center

### 5. Public Dashboard
- Transparency map explorer
- Citizen feedback portal
- Impact visualization with before/after comparisons

## 🔒 Security

### Row Level Security (RLS)
All database tables are protected with comprehensive RLS policies:
- User data isolation by role and jurisdiction
- State-level data segregation
- Agency-specific access controls
- Public read-only access for completed projects

### Authentication
- JWT-based authentication via Supabase Auth
- Role-based access control (RBAC)
- Session management with automatic renewal

## 🌐 Spatial Features

### PostGIS Integration
- Geographic proximity analysis
- Coverage area calculations
- Boundary-based filtering
- Route optimization

### Supported Spatial Queries
```dart
// Find nearby agencies
await spatialService.findNearbyAgencies(
  location: LatLng(28.6139, 77.2090),
  radiusInMeters: 5000,
);

// Check coverage area
await spatialService.isPointInCoverageArea(
  agencyId: agencyId,
  point: LatLng(28.6139, 77.2090),
);

// Calculate distance
await spatialService.calculateDistance(
  from: point1,
  to: point2,
);
```

## 📈 Performance Optimization

- **Lazy Loading**: Progressive loading of map data
- **Caching Strategy**: Multi-level caching for frequently accessed data
- **Image Optimization**: Automatic compression and format conversion
- **Database Connection Pooling**: Efficient resource management
- **Spatial Indexes**: GIST indexes for fast geographic queries

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/
```

## 📦 Deployment

### Web Deployment
```bash
flutter build web --release
# Deploy to hosting platform (Firebase, Netlify, etc.)
```

### Mobile Deployment
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License.

## 🆘 Support

For support and queries:
- Create an issue in the repository
- Email: support@pmajay.gov.in
- Documentation: [PM-AJAY Documentation](https://docs.pmajay.gov.in)

## 🎯 Roadmap

- [ ] AI-powered delay prediction
- [ ] Blockchain integration for fund tracking
- [ ] Mobile offline sync optimization
- [ ] Multi-language support (10+ languages)
- [ ] Advanced analytics dashboard
- [ ] Citizen mobile app

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Supabase for the backend infrastructure
- OpenStreetMap for map data
- PostGIS for spatial database capabilities

---

Built with ❤️ for transparent governance and efficient project management.