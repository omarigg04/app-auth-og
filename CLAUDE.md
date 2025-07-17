# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Structure

This is a full-stack CRUD application consisting of two main components:

- **Flutter Frontend** (`flutter-crud/`): Mobile/web client for expense and income tracking
- **NestJS Backend** (`nestjs-crud/`): REST API server with authentication and CRUD operations

### Key Architecture Components

**Flutter Frontend:**
- Authentication wrapper with JWT token management via shared_preferences
- Service layer pattern for HTTP API calls (auth_service.dart, expense_service.dart, income_service.dart, user_service.dart)
- Screen-based navigation for CRUD operations on users, expenses, and incomes
- Models: auth_user.dart, expense.dart, income.dart, user.dart

**NestJS Backend:**
- Modular architecture with separate modules for auth, user, expense, and income
- JWT authentication with passport strategy
- TypeORM/Sequelize for database operations (MySQL)
- DTO pattern for request validation using class-validator

## Common Development Commands

### Flutter (flutter-crud/)
```bash
cd flutter-crud
flutter pub get                 # Install dependencies
flutter run                     # Run in development mode
flutter build apk              # Build Android APK
flutter test                    # Run tests
flutter analyze                 # Static analysis
```

### NestJS (nestjs-crud/)
```bash
cd nestjs-crud
npm install                     # Install dependencies
npm run start:dev               # Development with watch mode
npm run start:local             # Start with local environment
npm run start:aws               # Start with AWS environment
npm run build                   # Build for production
npm run lint                    # ESLint with auto-fix
npm run format                  # Prettier formatting
npm run test                    # Unit tests
npm run test:e2e                # End-to-end tests
npm run test:cov                # Test coverage
```

## Database Configuration

The NestJS backend supports multiple database environments:
- Local development (.env.local)
- AWS deployment (.env.aws)
- Uses MySQL with TypeORM/Sequelize for data persistence

## Authentication Flow

1. User registers/logs in through Flutter app
2. NestJS returns JWT token on successful authentication
3. Flutter stores token in shared_preferences
4. Token included in Authorization header for protected API calls
5. AuthWrapper handles authentication state management

## API Integration

Flutter services communicate with NestJS endpoints:
- Base URL configured in service files
- HTTP package used for API calls
- CORS enabled on backend for cross-origin requests (origin: '*')

## Testing

- Flutter: Uses flutter_test framework
- NestJS: Jest for unit tests, separate e2e configuration
- Coverage reports available via `npm run test:cov`