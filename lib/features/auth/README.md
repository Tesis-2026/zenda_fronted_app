# Módulo de Autenticación - Zenda

## Descripción
Módulo de autenticación local completo con UI premium para Zenda. Implementa registro, login y gestión de sesión 100% local sin backend.

## Archivos Creados/Modificados

### Nuevos Archivos

1. **lib/features/auth/local_auth_service.dart**
   - Servicio de autenticación local usando SharedPreferences
   - Almacena usuarios en formato JSON
   - Hash de contraseñas con SHA-256
   - Métodos: `register()`, `login()`, `logout()`, `getCurrentUser()`, `isLoggedIn()`

2. **lib/features/auth/auth_controller.dart**
   - Controlador Riverpod para gestión de estado de autenticación
   - `AuthNotifier` con estados: loading, authenticated, unauthenticated, error
   - `authNotifierProvider` para acceso global al estado
   - Manejo automático de errores

3. **lib/features/auth/login_screen.dart**
   - Pantalla de login con UI premium
   - Validación de formulario (email válido, password mín 6 caracteres)
   - Toggle de visibilidad de contraseña
   - Botón "Olvidé mi contraseña" (dialog informativo)
   - Botón Google (disabled, solo demo)
   - Link a registro
   - Nota de privacidad

4. **lib/features/auth/register_screen.dart**
   - Pantalla de registro con UI premium
   - Campos: Nombre, Email, Contraseña
   - Validación completa
   - Toggle de visibilidad de contraseña
   - Link a login
   - Nota de privacidad extendida

5. **lib/features/auth/auth_gate.dart**
   - Widget que verifica autenticación
   - Redirige automáticamente a dashboard si ya está logueado
   - Muestra loading mientras verifica

### Archivos Modificados

1. **lib/core/models/user.dart**
   - Agregado: `toJson()`, `fromJson()`, `copyWith()`
   - Serialización para almacenamiento local

2. **pubspec.yaml**
   - Agregado: `crypto: ^3.0.6` (para hash de contraseñas)

3. **lib/routing/app_router.dart**
   - Rutas nuevas: `/auth/login`, `/auth/register`
   - Redirect: `/login` → `/auth/login` (compatibilidad)
   - Integración de `AuthGate` en rutas de auth

4. **lib/features/onboarding/splash_decider.dart**
   - Actualizado para redirigir a `/auth/login`

5. **lib/features/onboarding/onboarding_screen.dart**
   - Actualizado para redirigir a `/auth/login`

## Características Implementadas

### Autenticación Local
- ✅ Registro de usuarios con validación
- ✅ Login con email y contraseña
- ✅ Hash de contraseñas (SHA-256)
- ✅ Persistencia de sesión
- ✅ Logout
- ✅ Verificación de sesión activa

### UI Premium
- ✅ Diseño consistente con onboarding
- ✅ Formularios con validación en tiempo real
- ✅ Estados de loading en botones
- ✅ Toggle de visibilidad de contraseña
- ✅ Mensajes de error claros (SnackBar)
- ✅ Soporte completo dark/light mode
- ✅ Responsive (scroll en pantallas pequeñas)
- ✅ Iconos y gradientes premium

### Validaciones
- ✅ Email: formato válido
- ✅ Contraseña: mínimo 6 caracteres
- ✅ Nombre: no vacío
- ✅ Email duplicado: detecta si ya existe
- ✅ Usuario no existe: error claro
- ✅ Contraseña incorrecta: error claro

## Cómo Funciona el Almacenamiento Local

### Estructura de Datos en SharedPreferences

```dart
// Key: 'current_user_email'
// Value: "usuario@email.com"

// Key: 'users_json'
// Value: JSON string
{
  "usuario@email.com": {
    "id": "1707264000000",
    "name": "Juan Pérez",
    "email": "usuario@email.com",
    "passwordHash": "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8"
  },
  "otro@email.com": {
    "id": "1707264100000",
    "name": "María López",
    "email": "otro@email.com",
    "passwordHash": "..."
  }
}
```

### Flujo de Registro
1. Usuario completa formulario
2. Validación de campos
3. Verificar que email no exista
4. Crear User con ID único (timestamp)
5. Hash de contraseña con SHA-256
6. Guardar en `users_json`
7. Establecer como `current_user_email`
8. Actualizar estado en Riverpod
9. Navegar a `/dashboard`

### Flujo de Login
1. Usuario ingresa credenciales
2. Validación de campos
3. Buscar usuario por email en `users_json`
4. Comparar hash de contraseña
5. Si coincide, establecer `current_user_email`
6. Actualizar estado en Riverpod
7. Navegar a `/dashboard`

### Flujo de Sesión Persistente
1. App inicia → `SplashDecider`
2. Verifica onboarding completado
3. Si sí → va a `/auth/login`
4. `AuthGate` verifica `authNotifierProvider`
5. `AuthNotifier` consulta `getCurrentUser()`
6. Si hay `current_user_email` válido → redirige a `/dashboard`
7. Si no → muestra login

### Logout
1. Usuario presiona "Cerrar sesión" (desde Profile)
2. Llamar `authNotifier.logout()`
3. Eliminar `current_user_email` de SharedPreferences
4. Actualizar estado a `unauthenticated`
5. Navegar a `/auth/login`

## Seguridad (Nivel Demo)

⚠️ **Importante**: Este es un prototipo local. No es seguro para producción.

- ✅ Contraseñas hasheadas (SHA-256)
- ✅ Emails normalizados (lowercase, trim)
- ❌ No hay encriptación de datos en SharedPreferences
- ❌ No hay rate limiting
- ❌ No hay recuperación de contraseña real
- ❌ No hay verificación de email

Para producción se necesitaría:
- Backend con autenticación segura
- Tokens JWT o similar
- Encriptación de datos sensibles
- Verificación de email
- 2FA opcional

## Flujo Completo de Navegación

```
App Start
    ↓
SplashDecider (/)
    ↓
    ├─→ onboarding_completed = false → Onboarding → /auth/login
    │
    └─→ onboarding_completed = true → /auth/login
                                           ↓
                                       AuthGate
                                           ↓
                                    ├─→ isAuthenticated = true → /dashboard
                                    │
                                    └─→ isAuthenticated = false → LoginScreen
                                                                        ↓
                                                                   ├─→ Login exitoso → /dashboard
                                                                   └─→ "Crear cuenta" → /auth/register
                                                                                              ↓
                                                                                         Registro exitoso → /dashboard
```

## Cómo Probar

### 1. Registro de nuevo usuario
```bash
flutter run
```
- Completa onboarding (o salta)
- En login, presiona "Crear cuenta"
- Llena: Nombre, Email, Contraseña (mín 6 chars)
- Presiona "Crear cuenta"
- Deberías ir directo a dashboard

### 2. Login con usuario existente
- Cierra la app y vuelve a abrir
- Deberías ver login (sesión cerrada)
- Ingresa email y contraseña del usuario creado
- Presiona "Iniciar sesión"
- Deberías ir a dashboard

### 3. Sesión persistente
- Estando logueado, cierra y reabre la app
- Deberías ir directo a dashboard (sin pasar por login)

### 4. Errores
- Intenta registrar con email duplicado → "Este email ya está registrado"
- Intenta login con email inexistente → "Usuario no existe"
- Intenta login con contraseña incorrecta → "Contraseña incorrecta"
- Intenta registrar con email inválido → "Email inválido"
- Intenta con contraseña < 6 chars → "Mínimo 6 caracteres"

## Integración con Dashboard

El dashboard debe:
1. Verificar autenticación con `authNotifierProvider`
2. Obtener usuario actual: `ref.watch(authNotifierProvider).user`
3. Mostrar nombre del usuario
4. Proveer botón de logout que llame `ref.read(authNotifierProvider.notifier).logout()`

## Próximos Pasos

Para completar la app:
1. ✅ Onboarding implementado
2. ✅ Auth implementado
3. ⏳ Dashboard (mostrar nombre de usuario, botón logout)
4. ⏳ Transacciones (CRUD)
5. ⏳ Cuentas (CRUD)
6. ⏳ Breakdown 50/30/20
7. ⏳ Streak
8. ⏳ Profile con logout

## Notas Técnicas

- **Estado global**: `authNotifierProvider` es accesible desde cualquier parte de la app
- **Listeners**: Las pantallas escuchan cambios de estado para mostrar errores
- **Navegación**: Se usa `context.go()` de GoRouter (no push/pop)
- **Validación**: Formularios con `GlobalKey<FormState>` y validators
- **Teclado**: Se cierra automáticamente al enviar formulario
- **Loading**: Botones muestran CircularProgressIndicator durante operaciones async
