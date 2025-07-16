# Creación del Módulo Expenses - Sistema de Gastos

## Descripción General
Este documento describe el proceso completo de creación de un módulo de expenses (gastos) para el sistema NestJS, incluyendo la base de datos, modelos, servicios, controladores y configuración.

## 1. Estructura de Base de Datos

### Tabla expenses
```sql
CREATE TABLE expenses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    nombre_gasto VARCHAR(255) NOT NULL,
    gasto DECIMAL(10, 2) NOT NULL,
    tipo_pago ENUM('credito', 'efectivo') NOT NULL,
    descripcion TEXT,
    fecha_gasto DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Relación con auth_users
    FOREIGN KEY (user_id) REFERENCES auth_users(id) ON DELETE CASCADE
);

-- Índice para optimizar consultas por usuario
CREATE INDEX idx_expenses_user_id ON expenses(user_id);
```

### Características de la relación:
- **Foreign Key**: `user_id` referencia a `auth_users.id`
- **ON DELETE CASCADE**: Elimina automáticamente los gastos si se elimina el usuario
- **Índice**: Optimiza consultas por usuario

## 2. Estructura del Módulo

### Directorio creado:
```
src/expense/
├── dto/
│   ├── create-expense.dto.ts
│   └── update-expense.dto.ts
├── expense.controller.ts
├── expense.model.ts
├── expense.module.ts
└── expense.service.ts
```

## 3. Modelo de Datos (expense.model.ts)

```typescript
import { Table, Column, Model, DataType, PrimaryKey, AutoIncrement, BelongsTo, ForeignKey } from 'sequelize-typescript';
import { AuthUser } from '../auth/auth-user.model';

@Table({ tableName: 'expenses', timestamps: true })
export class Expense extends Model<Expense> {
    @PrimaryKey
    @AutoIncrement
    @Column
    declare id: number;

    @ForeignKey(() => AuthUser)
    @Column({ type: DataType.INTEGER, allowNull: false })
    declare user_id: number;

    @Column({ type: DataType.STRING, allowNull: false })
    declare nombre_gasto: string;

    @Column({ type: DataType.DECIMAL(10, 2), allowNull: false })
    declare gasto: number;

    @Column({ type: DataType.ENUM('credito', 'efectivo'), allowNull: false })
    declare tipo_pago: 'credito' | 'efectivo';

    @Column({ type: DataType.TEXT })
    declare descripcion: string;

    @Column({ type: DataType.DATE, allowNull: false })
    declare fecha_gasto: Date;

    @BelongsTo(() => AuthUser)
    declare user: AuthUser;
}
```

### Características del modelo:
- **Relación**: `@BelongsTo` con AuthUser
- **Tipos**: ENUM para tipo_pago, DECIMAL para gastos
- **Validaciones**: Campos obligatorios definidos con `allowNull: false`

## 4. DTOs (Data Transfer Objects)

### CreateExpenseDto:
```typescript
export class CreateExpenseDto {
    nombre_gasto: string;
    gasto: number;
    tipo_pago: 'credito' | 'efectivo';
    descripcion?: string;
    fecha_gasto: Date;
}
```

### UpdateExpenseDto:
```typescript
export class UpdateExpenseDto {
    nombre_gasto?: string;
    gasto?: number;
    tipo_pago?: 'credito' | 'efectivo';
    descripcion?: string;
    fecha_gasto?: Date;
}
```

## 5. Servicio (expense.service.ts)

### Métodos principales:
- `create()`: Crea nuevo gasto asociado al usuario
- `findAllByUser()`: Obtiene gastos del usuario autenticado
- `findOne()`: Busca gasto específico
- `update()`: Actualiza gasto (solo del usuario propietario)
- `remove()`: Elimina gasto (solo del usuario propietario)
- `getTotalExpensesByUser()`: Calcula totales por tipo de pago

### Características de seguridad:
- Todas las operaciones verifican que el gasto pertenezca al usuario
- Filtros por `user_id` en consultas
- Ordenamiento por fecha descendente

## 6. Controlador (expense.controller.ts)

### Endpoints disponibles:
- `POST /expenses` - Crear gasto
- `GET /expenses/my-expenses` - Obtener mis gastos
- `GET /expenses/my-totals` - Obtener totales por tipo de pago
- `GET /expenses/:id` - Obtener gasto específico
- `PATCH /expenses/:id` - Actualizar gasto
- `DELETE /expenses/:id` - Eliminar gasto

### Seguridad:
- Todos los endpoints protegidos con `@UseGuards(JwtAuthGuard)`
- Usuario extraído del token JWT via `@Request() req`

## 7. Configuración del Módulo

### expense.module.ts:
```typescript
import { Module } from '@nestjs/common';
import { SequelizeModule } from '@nestjs/sequelize';
import { ExpenseService } from './expense.service';
import { ExpenseController } from './expense.controller';
import { Expense } from './expense.model';

@Module({
  imports: [SequelizeModule.forFeature([Expense])],
  controllers: [ExpenseController],
  providers: [ExpenseService],
  exports: [ExpenseService],
})
export class ExpenseModule {}
```

### Registro en app.module.ts:
```typescript
// Importaciones agregadas
import { Expense } from './expense/expense.model';
import { ExpenseModule } from './expense/expense.module';

// En models array
models: [User, AuthUser, Expense],

// En imports array
ExpenseModule,
```

## 8. Funcionalidades Implementadas

### ✅ CRUD Completo
- Crear, leer, actualizar y eliminar gastos
- Validaciones de seguridad por usuario

### ✅ Estadísticas
- Total de gastos por usuario
- Separación por tipo de pago (crédito/efectivo)

### ✅ Seguridad
- Autenticación JWT obligatoria
- Aislamiento de datos por usuario
- Validaciones de propietario

### ✅ Relaciones
- Foreign key con tabla auth_users
- Consultas optimizadas con índices

## 9. Próximos Pasos

Para integrar con Flutter:
1. Actualizar el frontend para consumir endpoints de expenses
2. Crear pantallas para listar, crear y editar gastos
3. Implementar gráficos de estadísticas
4. Agregar filtros por fecha y tipo de pago

## 10. Comandos para Probar

```bash
# Instalar dependencias
npm install

# Ejecutar servidor
npm run start:dev

# Endpoints de prueba (con JWT token)
POST /expenses
GET /expenses/my-expenses
GET /expenses/my-totals
```

## Conclusión

El módulo de expenses ha sido creado exitosamente con:
- Estructura modular siguiendo patrones NestJS
- Seguridad implementada con JWT
- Relaciones de base de datos configuradas
- CRUD completo con validaciones
- Estadísticas básicas implementadas

El sistema está listo para ser integrado con el frontend Flutter y expandir funcionalidades según necesidades.