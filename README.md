# Sistema de Gestión de Gastos e Ingresos

Un sistema completo de gestión financiera personal desarrollado con **Flutter** (frontend móvil/web) y **NestJS** (backend API REST) con autenticación JWT y base de datos MySQL.

![Flutter](https://img.shields.io/badge/Flutter-3.8.1-blue.svg)
![NestJS](https://img.shields.io/badge/NestJS-11.0.1-red.svg)
![MySQL](https://img.shields.io/badge/MySQL-8.0-orange.svg)
![TypeScript](https://img.shields.io/badge/TypeScript-5.7.3-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.8.1-blue.svg)

## 📱 Capturas de Pantalla

El proyecto incluye múltiples pantallas mostrando la funcionalidad completa:

- Dashboard interactivo con estadísticas
- Gestión de gastos e ingresos
- Autenticación segura
- Gráficos y reportes con fl_chart
- Diseño responsive para móvil y web

## 🏗️ Arquitectura del Proyecto

```
my-app-1/
├── flutter-crud/          # Frontend Flutter
│   ├── lib/
│   │   ├── models/         # Modelos de datos (User, Expense, Income, AuthUser)
│   │   ├── services/       # Servicios HTTP (auth, expense, income, user)
│   │   ├── screens/        # Pantallas de la aplicación
│   │   └── main.dart       # Punto de entrada
│   └── pubspec.yaml        # Dependencias Flutter
├── nestjs-crud/           # Backend NestJS
│   ├── src/
│   │   ├── auth/          # Módulo de autenticación JWT
│   │   ├── user/          # Gestión de usuarios
│   │   ├── expense/       # Gestión de gastos
│   │   ├── income/        # Gestión de ingresos
│   │   └── main.ts        # Servidor principal
│   └── package.json       # Dependencias NestJS
└── README.md              # Este archivo
```

## ✨ Características Principales

### 🔐 Autenticación y Seguridad
- **JWT Authentication** con Passport.js
- **Registro y login** de usuarios
- **Tokens seguros** almacenados en SharedPreferences (Flutter)
- **Guards JWT** protegiendo rutas del backend
- **Encriptación bcrypt** para contraseñas

### 💰 Gestión Financiera
- **CRUD completo** para gastos e ingresos
- **Categorización** por tipo de pago (crédito/efectivo)
- **Fechas personalizables** para cada transacción
- **Descripciones opcionales** para mayor detalle
- **Filtrado por usuario** autenticado

### 📊 Dashboard y Estadísticas
- **Dashboard interactivo** con resumen financiero
- **Gráficos de barras** (gastos vs ingresos) con fl_chart
- **Vista por días y semanas** configurable
- **Selector de fechas personalizado** avanzado
- **Estadísticas en tiempo real** (totales, promedios, máximos/mínimos)
- **Distribución por tipo de pago** con barras de progreso

### 🎨 Interfaz de Usuario
- **Diseño Material 3** moderno y atractivo
- **Responsive design** (móvil, tablet, desktop)
- **Sidebar navigation** para escritorio
- **Drawer navigation** para móvil
- **Gradientes y sombras** para mejor experiencia visual
- **Pull-to-refresh** en todas las listas

### 🔄 Funcionalidades Avanzadas
- **Modo vista automático** (diario/semanal) según rango de fechas
- **Actividad reciente** en el dashboard
- **Acciones rápidas** para navegación eficiente
- **Estados de carga** y manejo de errores
- **Validación de formularios** completa

## 🚀 Instalación y Configuración

### Prerrequisitos

- **Flutter SDK 3.8.1+**
- **Node.js 18+** 
- **MySQL 8.0+**
- **Git**

### 1. Clonar el Repositorio

```bash
git clone <tu-repositorio>
cd my-app-1
```

### 2. Configuración del Backend (NestJS)

```bash
cd nestjs-crud
npm install
```

#### Configurar Base de Datos

1. Crear base de datos MySQL:
```sql
CREATE DATABASE technics_schema;
```

2. Configurar variables de entorno creando `.env.local`:
```env
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASS=tu_password
DB_NAME=technics_schema
JWT_SECRET=tu_jwt_secret_muy_seguro
```

#### Ejecutar el Backend

```bash
# Desarrollo local
npm run start:dev

# Desarrollo con archivo específico
npm run start:local

# Producción con AWS
npm run start:aws
```

El servidor estará disponible en `http://localhost:3000`

### 3. Configuración del Frontend (Flutter)

```bash
cd flutter-crud
flutter pub get
```

#### Configurar URL del Backend

Editar `lib/services/auth_service.dart` línea 6:
```dart
final String baseUrl = 'http://localhost:3000'; // Cambiar por tu URL
```

#### Ejecutar la Aplicación

```bash
# Para desarrollo
flutter run

# Para web
flutter run -d web

# Para Android
flutter run -d android

# Para iOS
flutter run -d ios
```

## 🔧 Scripts Disponibles

### Backend (NestJS)

```bash
npm run start:dev       # Servidor desarrollo con watch
npm run start:local     # Servidor con variables locales
npm run start:aws       # Servidor con variables AWS
npm run build           # Build para producción
npm run lint            # ESLint con auto-fix
npm run format          # Prettier formatting
npm run test            # Tests unitarios
npm run test:e2e        # Tests end-to-end
npm run test:cov        # Cobertura de tests
```

### Frontend (Flutter)

```bash
flutter pub get         # Instalar dependencias
flutter run            # Ejecutar en desarrollo
flutter build apk      # Build Android APK
flutter build web      # Build para web
flutter test           # Ejecutar tests
flutter analyze        # Análisis estático
```

## 📡 API Endpoints

### Autenticación
- `POST /auth/register` - Registro de usuario
- `POST /auth/login` - Login de usuario
- `GET /auth/test` - Test del módulo auth

### Usuarios
- `GET /users` - Listar usuarios
- `POST /users` - Crear usuario
- `GET /users/:id` - Obtener usuario
- `PATCH /users/:id` - Actualizar usuario
- `DELETE /users/:id` - Eliminar usuario

### Gastos
- `POST /expenses` - Crear gasto
- `GET /expenses` - Listar todos los gastos
- `GET /expenses/my-expenses` - Mis gastos
- `GET /expenses/my-totals` - Mis estadísticas
- `GET /expenses/:id` - Obtener gasto
- `PATCH /expenses/:id` - Actualizar gasto
- `DELETE /expenses/:id` - Eliminar gasto

### Ingresos
- `POST /incomes` - Crear ingreso
- `GET /incomes` - Listar todos los ingresos
- `GET /incomes/my-incomes` - Mis ingresos
- `GET /incomes/my-totals` - Mis estadísticas
- `GET /incomes/:id` - Obtener ingreso
- `PATCH /incomes/:id` - Actualizar ingreso
- `DELETE /incomes/:id` - Eliminar ingreso

## 🗄️ Base de Datos

### Esquema de Tablas

#### auth_users
```sql
- id (PK, Auto Increment)
- email (Unique)
- user_name (Unique)
- password (Encrypted)
- created_at, updated_at
```

#### expenses
```sql
- id (PK, Auto Increment)
- user_id (FK to auth_users)
- nombre_gasto
- gasto (DECIMAL 10,2)
- tipo_pago (ENUM: 'credito', 'efectivo')
- descripcion (TEXT, Optional)
- fecha_gasto (DATE)
- created_at, updated_at
```

#### incomes
```sql
- id (PK, Auto Increment)
- user_id (FK to auth_users)
- nombre_ingreso
- monto (DECIMAL 10,2)
- descripcion (TEXT, Optional)
- fecha_ingreso (DATE)
- created_at, updated_at
```

#### users
```sql
- id (PK, Auto Increment)
- name
- email
- created_at, updated_at
```

## 🛠️ Tecnologías Utilizadas

### Backend (NestJS)
- **NestJS 11.0.1** - Framework Node.js
- **TypeScript 5.7.3** - Lenguaje principal
- **Sequelize 6.37.7** - ORM para MySQL
- **Passport JWT** - Autenticación
- **bcrypt** - Encriptación de contraseñas
- **class-validator** - Validación de DTOs
- **MySQL2** - Driver de base de datos

### Frontend (Flutter)
- **Flutter 3.8.1** - Framework UI
- **Dart 3.8.1** - Lenguaje principal
- **http 1.1.0** - Cliente HTTP
- **shared_preferences 2.2.2** - Almacenamiento local
- **fl_chart 0.68.0** - Gráficos y estadísticas

### Base de Datos
- **MySQL 8.0** - Base de datos relacional

## 🎯 Flujo de Autenticación

1. **Registro/Login** → Usuario envía credenciales
2. **Validación** → Backend valida y genera JWT
3. **Almacenamiento** → Flutter guarda token en SharedPreferences
4. **Autenticación** → Token se incluye en headers de requests
5. **Verificación** → JwtGuard valida token en cada request protegido
6. **Renovación** → AuthWrapper verifica estado al inicio

## 📈 Funcionalidades de Estadísticas

### Dashboard Principal
- Resumen de ingresos, gastos y balance
- Actividad reciente (últimos 5 movimientos)
- Acciones rápidas para navegación
- Cards con gradientes y iconografía moderna

### Pantalla de Estadísticas Avanzadas
- **Filtros de fecha**: 7 días, 30 días, 90 días, mes actual, año actual, personalizado
- **Selector de fechas custom** con calendario interactivo
- **Gráficos de barras** comparando gastos vs ingresos
- **Vista automática** (días/semanas) según rango seleccionado
- **Estadísticas detalladas**: totales, promedios, máximos, mínimos
- **Distribución por tipo de pago** con barras de progreso

## 🔒 Configuración de Seguridad

### Variables de Entorno
```env
# Base de datos
DB_HOST=localhost
DB_PORT=3306
DB_USER=tu_usuario
DB_PASS=tu_password_seguro
DB_NAME=technics_schema

# JWT
JWT_SECRET=tu_jwt_secret_muy_largo_y_seguro

# Puerto (opcional)
PORT=3000
```

### CORS
```typescript
app.enableCors({
  origin: '*', // Configurar según tu dominio en producción
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
});
```

## 🚨 Notas de Seguridad

- ⚠️ **Cambiar JWT_SECRET** en producción
- ⚠️ **Configurar CORS** específico para tu dominio
- ⚠️ **No exponer variables de entorno** en repositorio
- ⚠️ **Usar HTTPS** en producción
- ✅ **Contraseñas encriptadas** con bcrypt
- ✅ **Validación de inputs** con class-validator
- ✅ **Guards JWT** en rutas protegidas

## 🌐 Despliegue

### Backend
- Compatible con **Vercel**, **Heroku**, **AWS**, **Railway**
- Variables de entorno configurables por plataforma
- Build automático con `npm run build`

### Frontend
- **Web**: `flutter build web`
- **Android**: `flutter build apk`
- **iOS**: `flutter build ios`

## 🤝 Contribuir

1. Fork el proyecto
2. Crear rama feature (`git checkout -b feature/AmazingFeature`)
3. Commit cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir Pull Request

## 📝 Licencia

Este proyecto está bajo la Licencia MIT. Ver `LICENSE` para más detalles.

## 👨‍💻 Autor

Desarrollado como sistema de gestión financiera personal con arquitectura moderna y escalable.

---

⭐ **¡Dale una estrella si te fue útil este proyecto!**