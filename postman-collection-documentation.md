# Documentación Completa de Postman Collection - API Sistema Financiero

## 📋 Descripción General
Esta documentación detalla cómo crear una colección completa de Postman para probar todos los endpoints de la API, incluyendo autenticación, gestión de gastos e ingresos.

## 🔧 Configuración Inicial de Postman

### **1. Crear Nueva Colección**
1. Abrir Postman
2. Click en "New" → "Collection"
3. Nombre: `Sistema Financiero API`
4. Descripción: `API para gestión de gastos e ingresos con autenticación JWT`

### **2. Configurar Variables de Entorno**
1. Click en "Environments" → "Create Environment"
2. Nombre: `Local Development`
3. Agregar variables:

| Variable | Initial Value | Current Value |
|----------|---------------|---------------|
| `baseUrl` | `http://localhost:3000` | `http://localhost:3000` |
| `authToken` | | (se llenará automáticamente) |

## 🔐 Sección 1: Autenticación (auth_users)

### **1.1 Registro de Usuario**
```
POST {{baseUrl}}/auth/register
```

**Headers:**
```
Content-Type: application/json
```

**Body (raw JSON):**
```json
{
    "email": "usuario@ejemplo.com",
    "password": "123456"
}
```

**Response Esperado (201):**
```json
{
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
        "id": 1,
        "email": "usuario@ejemplo.com",
        "created_at": "2025-01-16T10:30:00.000Z"
    }
}
```

**Tests Script (Para guardar token automáticamente):**

> **📍 UBICACIÓN**: En cada request de Register y Login, agregar en la pestaña "Tests"

**Pasos detallados:**
1. Abrir el request "Register User" en Postman
2. Hacer clic en la pestaña **"Tests"** (está al lado de "Headers", "Body", etc.)
3. Copiar y pegar este código en el editor:

```javascript
pm.test("Status code is 201", function () {
    pm.response.to.have.status(201);
});

pm.test("Response has access_token", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData).to.have.property('access_token');
});

// 🔑 GUARDAR TOKEN AUTOMÁTICAMENTE
if (pm.response.code === 201) {
    var jsonData = pm.response.json();
    pm.environment.set("authToken", jsonData.access_token);
    console.log("✅ Token guardado automáticamente:", jsonData.access_token);
}
```

**Resultado**: Después de ejecutar el request, el token se guardará automáticamente en la variable `{{authToken}}`

### **1.2 Login de Usuario**
```
POST {{baseUrl}}/auth/login
```

**Headers:**
```
Content-Type: application/json
```

**Body (raw JSON):**
```json
{
    "email": "usuario@ejemplo.com",
    "password": "123456"
}
```

**Response Esperado (200):**
```json
{
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
        "id": 1,
        "email": "usuario@ejemplo.com",
        "created_at": "2025-01-16T10:30:00.000Z"
    }
}
```

**Tests Script:**

> **📍 UBICACIÓN**: En el request "Login User", agregar en la pestaña "Tests"

**Pasos detallados:**
1. Abrir el request "Login User" en Postman
2. Hacer clic en la pestaña **"Tests"**
3. Copiar y pegar este código:

```javascript
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

pm.test("Response has access_token", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData).to.have.property('access_token');
});

// 🔑 GUARDAR TOKEN AUTOMÁTICAMENTE
if (pm.response.code === 200) {
    var jsonData = pm.response.json();
    pm.environment.set("authToken", jsonData.access_token);
    console.log("✅ Token de login guardado:", jsonData.access_token);
}
```

## 💰 Sección 2: Gestión de Ingresos (incomes)

> **⚠️ IMPORTANTE**: Todos los endpoints de ingresos requieren autenticación JWT

### **2.1 Configurar Headers para Autenticación**
Para todos los endpoints de ingresos, agregar estos headers:

**Headers:**
```
Content-Type: application/json
Authorization: Bearer {{authToken}}
```

### **2.2 Crear Nuevo Ingreso**
```
POST {{baseUrl}}/incomes
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer {{authToken}}
```

**Body (raw JSON):**
```json
{
    "nombre_ingreso": "Salario Enero 2025",
    "monto": 2500.50,
    "fuente_ingreso": "Salario",
    "descripcion": "Pago mensual de salario",
    "fecha_ingreso": "2025-01-15"
}
```

**Response Esperado (201):**
```json
{
    "id": 1,
    "user_id": 1,
    "nombre_ingreso": "Salario Enero 2025",
    "monto": "2500.50",
    "fuente_ingreso": "Salario",
    "descripcion": "Pago mensual de salario",
    "fecha_ingreso": "2025-01-15",
    "created_at": "2025-01-16T10:30:00.000Z",
    "updated_at": "2025-01-16T10:30:00.000Z"
}
```

### **2.3 Obtener Mis Ingresos**
```
GET {{baseUrl}}/incomes/my-incomes
```

**Headers:**
```
Authorization: Bearer {{authToken}}
```

**Response Esperado (200):**
```json
[
    {
        "id": 1,
        "user_id": 1,
        "nombre_ingreso": "Salario Enero 2025",
        "monto": "2500.50",
        "fuente_ingreso": "Salario",
        "descripcion": "Pago mensual de salario",
        "fecha_ingreso": "2025-01-15",
        "created_at": "2025-01-16T10:30:00.000Z",
        "updated_at": "2025-01-16T10:30:00.000Z"
    }
]
```

### **2.4 Obtener Estadísticas de Ingresos**
```
GET {{baseUrl}}/incomes/my-totals
```

**Headers:**
```
Authorization: Bearer {{authToken}}
```

**Response Esperado (200):**
```json
{
    "total": 2500.50,
    "por_fuente": {
        "Salario": 2500.50,
        "Freelance": 0,
        "Inversiones": 0
    }
}
```

### **2.5 Obtener Ingresos por Rango de Fechas**
```
GET {{baseUrl}}/incomes/by-date-range?startDate=2025-01-01&endDate=2025-01-31
```

**Headers:**
```
Authorization: Bearer {{authToken}}
```

**Query Parameters:**
- `startDate`: `2025-01-01`
- `endDate`: `2025-01-31`

### **2.6 Obtener Ingreso Específico**
```
GET {{baseUrl}}/incomes/1
```

**Headers:**
```
Authorization: Bearer {{authToken}}
```

### **2.7 Actualizar Ingreso**
```
PATCH {{baseUrl}}/incomes/1
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer {{authToken}}
```

**Body (raw JSON):**
```json
{
    "monto": 2600.00,
    "descripcion": "Salario actualizado con bono"
}
```

### **2.8 Eliminar Ingreso**
```
DELETE {{baseUrl}}/incomes/1
```

**Headers:**
```
Authorization: Bearer {{authToken}}
```

## 🛒 Sección 3: Gestión de Gastos (expenses)

> **⚠️ IMPORTANTE**: Todos los endpoints de gastos requieren autenticación JWT

### **3.1 Crear Nuevo Gasto**
```
POST {{baseUrl}}/expenses
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer {{authToken}}
```

**Body (raw JSON):**
```json
{
    "nombre_gasto": "Compra Supermercado",
    "gasto": 150.75,
    "tipo_pago": "credito",
    "descripcion": "Compras de la semana",
    "fecha_gasto": "2025-01-15"
}
```

**Response Esperado (201):**
```json
{
    "id": 1,
    "user_id": 1,
    "nombre_gasto": "Compra Supermercado",
    "gasto": "150.75",
    "tipo_pago": "credito",
    "descripcion": "Compras de la semana",
    "fecha_gasto": "2025-01-15",
    "created_at": "2025-01-16T10:30:00.000Z",
    "updated_at": "2025-01-16T10:30:00.000Z"
}
```

### **3.2 Obtener Mis Gastos**
```
GET {{baseUrl}}/expenses/my-expenses
```

**Headers:**
```
Authorization: Bearer {{authToken}}
```

**Response Esperado (200):**
```json
[
    {
        "id": 1,
        "user_id": 1,
        "nombre_gasto": "Compra Supermercado",
        "gasto": "150.75",
        "tipo_pago": "credito",
        "descripcion": "Compras de la semana",
        "fecha_gasto": "2025-01-15",
        "created_at": "2025-01-16T10:30:00.000Z",
        "updated_at": "2025-01-16T10:30:00.000Z"
    }
]
```

### **3.3 Obtener Estadísticas de Gastos**
```
GET {{baseUrl}}/expenses/my-totals
```

**Headers:**
```
Authorization: Bearer {{authToken}}
```

**Response Esperado (200):**
```json
{
    "total": 150.75,
    "credito": 150.75,
    "efectivo": 0
}
```

### **3.4 Obtener Todos los Gastos (Admin)**
```
GET {{baseUrl}}/expenses
```

**Headers:**
```
Authorization: Bearer {{authToken}}
```

### **3.5 Obtener Gasto Específico**
```
GET {{baseUrl}}/expenses/1
```

**Headers:**
```
Authorization: Bearer {{authToken}}
```

### **3.6 Actualizar Gasto**
```
PATCH {{baseUrl}}/expenses/1
```

**Headers:**
```
Content-Type: application/json
Authorization: Bearer {{authToken}}
```

**Body (raw JSON):**
```json
{
    "gasto": 175.50,
    "tipo_pago": "efectivo",
    "descripcion": "Compras actualizadas - pagado en efectivo"
}
```

### **3.7 Eliminar Gasto**
```
DELETE {{baseUrl}}/expenses/1
```

**Headers:**
```
Authorization: Bearer {{authToken}}
```

## 🔧 Configuración Avanzada de Postman

### **1. Configuración Visual Paso a Paso**

#### **📸 Capturas de pantalla de referencia:**

**Pestaña "Tests" en un request:**
```
┌─────────────────────────────────────────┐
│ Params │ Headers │ Body │ Tests │ Settings │
│                          ████████        │
└─────────────────────────────────────────┘
```

**Environment Variables:**
```
┌─────────────────────────────────────────┐
│ Variable    │ Initial Value │ Current   │
│ baseUrl     │ http://...    │ http://.. │
│ authToken   │ (empty)       │ eyJhb...  │
└─────────────────────────────────────────┘
```

### **2. Pre-request Scripts para Autenticación Automática**

> **📍 UBICACIÓN**: En la configuración de la COLECCIÓN (no en requests individuales)

**Pasos:**
1. Hacer clic derecho en tu colección "Sistema Financiero API"
2. Seleccionar "Edit"
3. Ir a la pestaña "Pre-request Script"
4. Agregar este código:

```javascript
// Verificar si tenemos token
if (!pm.environment.get("authToken")) {
    console.log("⚠️ No auth token found. Please login first.");
} else {
    console.log("✅ Auth token disponible");
}
```

### **3. Tests Globales para la Colección**

> **📍 UBICACIÓN**: En la configuración de la COLECCIÓN, pestaña "Tests"

**Pasos:**
1. Hacer clic derecho en la colección "Sistema Financiero API"
2. Seleccionar "Edit"
3. Ir a la pestaña "Tests"
4. Agregar este código:

```javascript
// Test global para verificar autenticación
pm.test("No authentication errors", function () {
    pm.expect(pm.response.code).to.not.equal(401);
});

// Test para endpoints protegidos
if (pm.request.url.toString().includes("/expenses") || pm.request.url.toString().includes("/incomes")) {
    pm.test("Protected endpoint should have auth header", function () {
        pm.expect(pm.request.headers.get("Authorization")).to.exist;
    });
}
```

### **4. Guía Visual Completa de Configuración**

#### **🎯 Flujo de configuración paso a paso:**

**PASO 1: Crear Environment**
```
1. Click en "Environments" (⚙️) en la barra lateral
2. Click "Create Environment"
3. Nombre: "Local Development"
4. Agregar variables:
   - baseUrl: http://localhost:3000
   - authToken: (dejar vacío)
5. Guardar
```

**PASO 2: Configurar Request de Login**
```
1. Crear nuevo request POST
2. URL: {{baseUrl}}/auth/login
3. Headers: Content-Type: application/json
4. Body (raw JSON): {"email": "...", "password": "..."}
5. ⭐ IR A PESTAÑA "Tests"
6. Pegar el script del token
7. Guardar request
```

**PASO 3: Configurar Request de Gastos**
```
1. Crear nuevo request GET
2. URL: {{baseUrl}}/expenses/my-expenses
3. ⭐ Headers: Authorization: Bearer {{authToken}}
4. Guardar request
```

**PASO 4: Verificar Funcionamiento**
```
1. Ejecutar Login → Ver en Console si dice "Token guardado"
2. Ejecutar Get Expenses → Debe devolver 200, no 401
3. Verificar en Environment que authToken tiene valor
```

### **5. Folder Structure Recomendada**

```
📁 Sistema Financiero API
├── 📁 Authentication
│   ├── Register User
│   └── Login User
├── 📁 Incomes Management
│   ├── Create Income
│   ├── Get My Incomes
│   ├── Get Income Stats
│   ├── Get Incomes by Date Range
│   ├── Get Specific Income
│   ├── Update Income
│   └── Delete Income
└── 📁 Expenses Management
    ├── Create Expense
    ├── Get My Expenses
    ├── Get Expense Stats
    ├── Get All Expenses
    ├── Get Specific Expense
    ├── Update Expense
    └── Delete Expense
```

## 🚨 Manejo de Errores Comunes

### **Error 401 - Unauthorized**
```json
{
    "statusCode": 401,
    "message": "Unauthorized"
}
```
**Solución**: Verificar que el header `Authorization: Bearer {{authToken}}` esté presente.

### **Error 403 - Forbidden**
```json
{
    "statusCode": 403,
    "message": "Forbidden resource"
}
```
**Solución**: El token es válido pero no tienes permisos para este recurso.

### **Error 404 - Not Found**
```json
{
    "statusCode": 404,
    "message": "Resource not found"
}
```
**Solución**: Verificar que el ID del recurso existe y pertenece al usuario.

### **Error 422 - Validation Error**
```json
{
    "statusCode": 422,
    "message": "Validation failed",
    "errors": ["monto must be a positive number"]
}
```
**Solución**: Verificar que los datos del body cumplan las validaciones.

## 📊 Ejemplos de Datos de Prueba

### **Usuarios de Prueba:**
```json
{
    "email": "juan@ejemplo.com",
    "password": "123456"
}
```

### **Ingresos de Prueba:**
```json
[
    {
        "nombre_ingreso": "Salario Enero",
        "monto": 3000.00,
        "fuente_ingreso": "Salario",
        "fecha_ingreso": "2025-01-01"
    },
    {
        "nombre_ingreso": "Proyecto Freelance",
        "monto": 800.50,
        "fuente_ingreso": "Freelance",
        "fecha_ingreso": "2025-01-10"
    },
    {
        "nombre_ingreso": "Dividendos",
        "monto": 200.25,
        "fuente_ingreso": "Inversiones",
        "fecha_ingreso": "2025-01-15"
    }
]
```

### **Gastos de Prueba:**
```json
[
    {
        "nombre_gasto": "Supermercado",
        "gasto": 250.00,
        "tipo_pago": "credito",
        "fecha_gasto": "2025-01-02"
    },
    {
        "nombre_gasto": "Gasolina",
        "gasto": 60.00,
        "tipo_pago": "efectivo",
        "fecha_gasto": "2025-01-05"
    },
    {
        "nombre_gasto": "Restaurante",
        "gasto": 85.75,
        "tipo_pago": "credito",
        "fecha_gasto": "2025-01-12"
    }
]
```

## 🎯 Flujo de Prueba Recomendado

1. **Paso 1**: Ejecutar `Register User` o `Login User`
2. **Paso 2**: Verificar que el token se guardó en `{{authToken}}`
3. **Paso 3**: Crear algunos ingresos con `Create Income`
4. **Paso 4**: Crear algunos gastos con `Create Expense`
5. **Paso 5**: Verificar estadísticas con `Get Income Stats` y `Get Expense Stats`
6. **Paso 6**: Probar actualizaciones y eliminaciones
7. **Paso 7**: Verificar filtros y búsquedas

## 📥 Importar Colección

Para importar esta colección completa a Postman:

1. Copia los endpoints de esta documentación
2. Crea cada request manualmente en Postman
3. Configura las variables de entorno
4. Agrega los scripts de tests
5. Organiza en carpetas según la estructura recomendada

Con esta configuración tendrás una colección completa para probar toda la API del sistema financiero de manera eficiente y automatizada.