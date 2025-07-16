# Creación y Consulta de Eventos en NestJS con PostgreSQL

---

## Conversación y Explicaciones

### Usuario:
Se requiere un endpoint que pueda almacenar un evento en base de datos, por lo que se requiere crear el modelo para que este sea almacenado, un controlador para recibir la petición de tipo POST y un service que pueda contener la logica de guardado.

El evento debe tener los siguientes campos:

- nombre del evento: string
- hora de inicio: datetime
- hora final: datetime

Además del identificador generado por SQL, el cual será utilizado como llave primaria.

---

### GitHub Copilot:
Para cumplir con tu requerimiento en NestJS y Sequelize, debes crear:

1. **Modelo Sequelize** para el evento.
2. **Service** con la lógica de guardado.
3. **Controller** con un endpoint POST para recibir y almacenar el evento.

Aquí tienes el ejemplo completo:

#### 1. Modelo: `event.model.ts`

```typescript
import { Column, Model, Table, DataType, PrimaryKey, AutoIncrement } from 'sequelize-typescript';

@Table
export class Event extends Model {
  @PrimaryKey
  @AutoIncrement
  @Column
  id: number;

  @Column
  nombre: string;

  @Column({ type: DataType.DATE })
  hora_inicio: Date;

  @Column({ type: DataType.DATE })
  hora_final: Date;
}
```

#### 2. Service: `events.service.ts`

```typescript
import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { Event } from './event.model';

@Injectable()
export class EventsService {
  constructor(
    @InjectModel(Event) private readonly eventModel: typeof Event,
  ) {}

  async createEvent(data: { nombre: string; hora_inicio: Date; hora_final: Date }) {
    const event = await this.eventModel.create(data);
    return event;
  }
}
```

#### 3. Controller: `events.controller.ts`

```typescript
import { Controller, Post, Body } from '@nestjs/common';
import { EventsService } from './events.service';

@Controller('events')
export class EventsController {
  constructor(private readonly eventsService: EventsService) {}

  @Post()
  async createEvent(
    @Body() body: { nombre: string; hora_inicio: Date; hora_final: Date },
  ) {
    return this.eventsService.createEvent(body);
  }
}
```

#### 4. Módulo: `events.module.ts`

```typescript
import { Module } from '@nestjs/common';
import { SequelizeModule } from '@nestjs/sequelize';
import { Event } from './event.model';
import { EventsService } from './events.service';
import { EventsController } from './events.controller';

@Module({
  imports: [SequelizeModule.forFeature([Event])],
  providers: [EventsService],
  controllers: [EventsController],
})
export class EventsModule {}
```

#### 5. Agrega el módulo a tu `AppModule`

```typescript
// ...existing code...
import { EventsModule } from './events/events.module';
// ...existing code...
@Module({
  imports: [
    // ...existing code...
    EventsModule,
    // ...existing code...
  ],
  // ...existing code...
})
export class AppModule {}
// ...existing code...
```

**Con esto tendrás un endpoint POST `/events`** que recibe un JSON como:

```json
{
  "nombre": "Evento de prueba",
  "hora_inicio": "2025-06-11T10:00:00Z",
  "hora_final": "2025-06-11T12:00:00Z"
}
```

y lo almacena en la base de datos.

---

### Usuario:
Bien, todo salió excelente, ahora vamos a crear los controladores y demás artefactos necesarios para traer la data. Sé que sería con un GET, tengo mi db en PostgreSQL en mi local, ayúdame en el paso a paso pero ayúdame también a entender todo.

---

### GitHub Copilot:
¡Perfecto! Vamos a crear el endpoint GET para obtener los eventos almacenados en tu base de datos PostgreSQL usando NestJS y Sequelize. Te explico cada paso:

#### 1. Modelo Sequelize

Ya debes tener el modelo `Event` creado (como te mostré antes). Este modelo representa la tabla en tu base de datos.

#### 2. Service: Lógica para obtener eventos

El service es donde va la lógica de negocio. Aquí agregaremos un método para obtener todos los eventos.

```typescript
// ...existing code...
  async findAll() {
    return this.eventModel.findAll();
  }
// ...existing code...
```

**¿Qué hace este método?**  
`findAll()` usa Sequelize para traer todos los registros de la tabla `events`.

#### 3. Controller: Endpoint GET

El controlador recibe las peticiones HTTP y llama al service. Agregamos un método para el GET.

```typescript
// ...existing code...
import { Controller, Post, Body, Get } from '@nestjs/common';
// ...existing code...

  @Get()
  async findAll() {
    return this.eventsService.findAll();
  }
// ...existing code...
```

**¿Qué hace este endpoint?**  
Cuando haces una petición GET a `/events`, llama al método `findAll()` del service y te devuelve todos los eventos.

#### 4. Probar el endpoint

Puedes probarlo con Postman, Insomnia o simplemente desde el navegador (si no necesitas parámetros).

- **URL:** `http://localhost:3000/events`
- **Método:** GET

Te devolverá un array con todos los eventos almacenados.

#### 5. ¿Cómo funciona todo junto?

- **Modelo:** Define cómo se ve un evento en la base de datos.
- **Service:** Contiene la lógica para crear y obtener eventos.
- **Controller:** Expone endpoints HTTP para interactuar con los eventos.

NestJS se encarga de inyectar las dependencias y conectar todo. Sequelize se conecta a tu base de datos PostgreSQL y ejecuta las consultas.

---

### Usuario:
¿No necesito nada en el body?

---

### GitHub Copilot:
Correcto, para una petición GET estándar como `/events`, **no necesitas enviar nada en el body**.

En HTTP, los métodos GET se usan para obtener información y no deben tener body. Toda la información extra (como filtros o paginación) se suele enviar como parámetros en la URL (query params), por ejemplo:

```
GET /events?fecha_inicio=2025-07-01
```

Pero para simplemente obtener todos los eventos, solo necesitas hacer:

```
GET /events
```

¡Y listo! No necesitas body para este tipo de petición.

---

## Resumen del flujo

- **Modelo:** Define la estructura de la tabla en la base de datos.
- **DTO:** Valida los datos de entrada para el POST.
- **Service:** Contiene la lógica para crear y obtener eventos.
- **Controller:** Expone los endpoints HTTP para interactuar con los eventos.
- **GET:** No requiere body, solo la URL.

---