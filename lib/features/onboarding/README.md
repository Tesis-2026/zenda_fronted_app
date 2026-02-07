# Módulo de Onboarding - Zenda

## Descripción
Módulo de onboarding premium con UI moderna para la app Zenda. Implementa un flujo de 3 pantallas que presenta las características principales de la aplicación.

## Archivos Creados/Modificados

### Nuevos Archivos
1. **lib/features/onboarding/onboarding_screen.dart**
   - Pantalla principal con PageView de 3 páginas
   - Controles de navegación (Siguiente/Empezar, Saltar, Ya tengo cuenta)
   - Indicadores de página animados
   - Navegación a `/login` al completar

2. **lib/features/onboarding/onboarding_page.dart**
   - Widget reutilizable para cada página del onboarding
   - Hero visual con icono en círculo con gradiente
   - Card de contenido con sombras sutiles
   - Layout responsive con SingleChildScrollView

3. **lib/features/onboarding/onboarding_prefs.dart**
   - Repositorio para manejar el estado de onboarding
   - Usa SharedPreferences para persistir `onboarding_completed`
   - Métodos: `isOnboardingCompleted()`, `setOnboardingCompleted()`, `resetOnboarding()`

4. **lib/features/onboarding/splash_decider.dart**
   - Pantalla splash inicial
   - Verifica si onboarding fue completado
   - Redirige a `/onboarding` o `/login` según corresponda
   - Branding de Zenda con loading indicator

### Archivos Modificados
1. **pubspec.yaml**
   - Agregado: `shared_preferences: ^2.3.4`

2. **lib/routing/app_router.dart**
   - Ruta inicial cambiada a `/` (SplashDecider)
   - Agregada ruta `/` para splash
   - Ruta `/onboarding` ya existía, ahora integrada en el flujo

## Características Implementadas

### UI Premium
- ✅ Gradientes suaves en iconos hero
- ✅ Cards con sombras sutiles y bordes redondeados (24px)
- ✅ Animaciones smooth en PageView y indicadores
- ✅ Soporte completo para modo claro y oscuro
- ✅ Layout responsive (funciona en pantallas pequeñas)
- ✅ Espaciado generoso y jerarquía visual clara

### Navegación
- ✅ PageView con 3 pantallas
- ✅ Botón "Siguiente" en páginas 1-2, "Empezar" en página 3
- ✅ Botón "Saltar" (top-right) que va directo a auth
- ✅ Link "Ya tengo cuenta" que va a auth
- ✅ Persistencia del estado (no se muestra de nuevo después de completar)

### Contenido (Español Peruano)
**Página 1:**
- Título: "Registra tus gastos en segundos"
- Subtítulo: "Anota con un toque o escanea una boleta (demo)."
- Microcopy: "Menos fricción, más control."
- Icono: Receipt (recibo)
- Gradiente: Verde menta (#34D399 → #10B981)

**Página 2:**
- Título: "Entiende tu dinero con 50/30/20"
- Subtítulo: "Zenda te muestra si vas equilibrado: necesidades, deseos y ahorro."
- Microcopy: "Aprende sin complicarte."
- Icono: Pie Chart
- Gradiente: Azul cielo (#60A5FA → #3B82F6)

**Página 3:**
- Título: "Mantén tu racha y mejora cada día 🔥"
- Subtítulo: "Gana constancia registrando a diario y viendo tu progreso."
- Microcopy: "Lo importante es volver mañana."
- Icono: Fire (fuego)
- Gradiente: Amarillo (#FCD34D → #F59E0B)

## Paleta de Colores Usada

### Modo Claro
- Primary: #34D399 (menta)
- Secondary: #60A5FA (azul cielo)
- Background: #F9FAFB
- Text Primary: #1F2937
- Text Secondary: #6B7280
- Warning: #FCD34D

### Modo Oscuro
- Background: #0F172A
- Card: #1E293B
- Primary: #34D399
- Secondary: #38BDF8
- Text: #F1F5F9

## Flujo de Navegación

```
App Start
    ↓
SplashDecider (/)
    ↓
    ├─→ onboarding_completed = false → OnboardingScreen (/onboarding)
    │                                        ↓
    │                                   (Completa/Salta)
    │                                        ↓
    └─→ onboarding_completed = true  → LoginScreen (/login)
```

## Cómo Probar

1. **Primera vez (onboarding nuevo):**
   ```bash
   flutter run
   ```
   - Verás el splash → onboarding
   - Navega las 3 páginas o salta
   - Al completar, va a `/login`

2. **Segunda vez (onboarding completado):**
   - Reinicia la app
   - Verás el splash → login directamente

3. **Reset onboarding (para testing):**
   - Desinstala la app o limpia datos
   - O modifica el código para llamar `OnboardingPrefs.resetOnboarding()`

## Accesibilidad

- ✅ Botones con altura mínima 48px
- ✅ Buen contraste en dark mode
- ✅ Textos responsivos
- ✅ Sin overflow en pantallas pequeñas (SingleChildScrollView)

## Próximos Pasos

Para integrar con el resto de la app:
1. Implementar LoginScreen funcional (actualmente es placeholder)
2. Agregar lógica de autenticación mock
3. Conectar con dashboard después del login
4. Opcional: Agregar animaciones de transición entre rutas
