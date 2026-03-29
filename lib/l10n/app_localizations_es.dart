// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Zenda';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonOr => 'o';

  @override
  String get commonNotSet => 'No definido';

  @override
  String get commonUnknownError => 'Error desconocido';

  @override
  String get commonSignOut => 'Cerrar sesión';

  @override
  String get validationEnterEmail => 'Ingresa tu correo';

  @override
  String get validationInvalidEmail => 'Correo inválido';

  @override
  String get validationEnterPassword => 'Ingresa tu contraseña';

  @override
  String get validationMinPassword => 'Al menos 8 caracteres';

  @override
  String get validationEnterName => 'Ingresa tu nombre';

  @override
  String get validationEnterCode => 'Ingresa el código';

  @override
  String get validationEnterNewPassword => 'Ingresa tu nueva contraseña';

  @override
  String get authLoginTitle => 'Bienvenido a Zenda';

  @override
  String get authLoginSubtitle => 'Inicia sesión para continuar';

  @override
  String get authEmailLabel => 'Correo';

  @override
  String get authEmailHint => 'tu@correo.com';

  @override
  String get authPasswordLabel => 'Contraseña';

  @override
  String get authPasswordHint => 'Al menos 8 caracteres';

  @override
  String get authForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get authSignIn => 'Iniciar sesión';

  @override
  String get authNoAccount => '¿No tienes cuenta?';

  @override
  String get authSignUp => 'Crear cuenta';

  @override
  String get authPrivacyNote =>
      'Zenda no se conecta a bancos. Tus datos son privados.';

  @override
  String get authAccountNotFound => 'Cuenta no encontrada';

  @override
  String get authAccountNotFoundMessage =>
      'No existe cuenta con este correo. ¿Te gustaría crear una nueva?';

  @override
  String get authContinueGoogle => 'Continuar con Google (Demo)';

  @override
  String get authRegisterTitle => 'Crear cuenta';

  @override
  String get authRegisterSubtitle =>
      'Únete a Zenda y toma el control de tus finanzas';

  @override
  String get authFullNameLabel => 'Nombre completo';

  @override
  String get authFullNameHint => 'Juan Pérez';

  @override
  String get authHaveAccount => '¿Ya tienes cuenta?';

  @override
  String get authDataSecure => 'Tus datos están seguros';

  @override
  String get authDataSecureRegister =>
      'Zenda no se conecta a bancos. Toda tu información se almacena localmente en tu dispositivo.';

  @override
  String get authForgotTitle => 'Recuperar contraseña';

  @override
  String get authForgotSubtitle =>
      'Ingresa tu correo y te enviaremos un código de recuperación.';

  @override
  String get authSendCode => 'Enviar código';

  @override
  String get authHaveCode => 'Ya tengo un código';

  @override
  String get authCheckEmail => 'Revisa tu correo';

  @override
  String get authCheckEmailMessage =>
      'Si tu correo está registrado, recibirás un código de recuperación en minutos.\n\nIngresa el código en la siguiente pantalla.';

  @override
  String get authEnterCode => 'Ingresar código';

  @override
  String get authResetTitle => 'Nueva contraseña';

  @override
  String get authResetSubtitle =>
      'Ingresa el código que recibiste por correo y tu nueva contraseña.';

  @override
  String get authResetCodeLabel => 'Código de recuperación';

  @override
  String get authResetCodeHint => 'Pega el código del correo';

  @override
  String get authNewPasswordLabel => 'Nueva contraseña';

  @override
  String get authResetButton => 'Restablecer contraseña';

  @override
  String get authPasswordUpdated => 'Contraseña actualizada. Inicia sesión.';

  @override
  String get authOnboardingReset =>
      'Para reiniciar el onboarding, reinstala la app o borra los datos.';

  @override
  String get onboardingPage1Title => 'Registra tus gastos en segundos';

  @override
  String get onboardingPage1Subtitle =>
      'Registra con un toque o escanea un recibo (demo).';

  @override
  String get onboardingPage1Micro => 'Menos fricción, más control.';

  @override
  String get onboardingPage2Title => 'Entiende tu dinero con 50/30/20';

  @override
  String get onboardingPage2Subtitle =>
      'Zenda te muestra si estás equilibrado: necesidades, deseos y ahorros.';

  @override
  String get onboardingPage2Micro => 'Aprende sin complicarte.';

  @override
  String get onboardingPage3Title => 'Mantén tu racha y mejora cada día 🔥';

  @override
  String get onboardingPage3Subtitle =>
      'Construye consistencia registrando diariamente y siguiendo tu progreso.';

  @override
  String get onboardingPage3Micro => 'Lo importante es volver mañana.';

  @override
  String get onboardingSkip => 'Omitir';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingRegister => 'Registrarse';

  @override
  String get onboardingStart => 'Comenzar';

  @override
  String get onboardingHaveAccount => 'Ya tengo una cuenta';

  @override
  String dashboardGreeting(String name) {
    return 'Hola, $name 👋';
  }

  @override
  String get dashboardMotivation => 'Mejoremos tus finanzas hoy.';

  @override
  String get dashboardNavHome => 'Inicio';

  @override
  String get dashboardNavTransactions => 'Movs.';

  @override
  String get dashboardNavBudget => 'Presupuesto';

  @override
  String get dashboardNavProfile => 'Perfil';

  @override
  String get dashboardRecord => 'Registrar';

  @override
  String get dashboardMyAccounts => 'Mis Cuentas';

  @override
  String get dashboardBudgetTitle => 'Tu Presupuesto 50/30/20';

  @override
  String get dashboardBudgetSubtitle =>
      'Basado en tus gastos de los últimos 30 días';

  @override
  String get dashboardTransactions => 'Transacciones';

  @override
  String get dashboardNoTransactions => 'Aún no hay transacciones.';

  @override
  String get dashboardNeeds => 'Necesidades';

  @override
  String get dashboardWants => 'Deseos';

  @override
  String get dashboardSavings => 'Ahorros';

  @override
  String get dashboardUserFallback => 'Usuario';

  @override
  String get dashboardSignOutConfirm => '¿Seguro que quieres cerrar sesión?';

  @override
  String dashboardErrorAccounts(String error) {
    return 'Error al cargar cuentas: $error';
  }

  @override
  String dashboardErrorTransactions(String error) {
    return 'Error al cargar transacciones: $error';
  }

  @override
  String get summaryTodayLabel => 'Gasto de Hoy';

  @override
  String get summaryWeekLabel => 'Esta Semana';

  @override
  String streakLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'racha de $count días',
      one: 'racha de 1 día',
    );
    return '$_temp0';
  }

  @override
  String get budgetNoExpenses => 'Sin gastos registrados';

  @override
  String get aiCardTitle => 'Consejo Zenda';

  @override
  String get txNewTitle => 'Nueva transacción';

  @override
  String get txScanReceipt => 'Escanear recibo (demo)';

  @override
  String get txExpense => 'Gasto';

  @override
  String get txIncome => 'Ingreso';

  @override
  String get txTransfer => 'Transferencia';

  @override
  String get txAccountLabel => 'Cuenta';

  @override
  String get txSourceLabel => 'Origen';

  @override
  String get txDestLabel => 'Destino';

  @override
  String get txAmountLabel => 'Monto (PEN)';

  @override
  String get txAmountHint => '0.00';

  @override
  String get txCategoryLabel => 'Categoría';

  @override
  String get txNoteLabel => 'Nota (opcional)';

  @override
  String get txNoteHint => 'ej. Cafetería';

  @override
  String get txDateLabel => 'Fecha';

  @override
  String get txSaveButton => 'Guardar transacción';

  @override
  String get txSaved => 'Guardado ✅';

  @override
  String txErrorPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String get txNeed => 'Necesidad';

  @override
  String get txWant => 'Deseo';

  @override
  String get txSavingBucket => 'Ahorro';

  @override
  String get txCategoryFood => 'Comida';

  @override
  String get txCategoryTransport => 'Transporte';

  @override
  String get txCategoryHousing => 'Vivienda';

  @override
  String get txCategoryUtilities => 'Servicios';

  @override
  String get txCategoryHealth => 'Salud';

  @override
  String get txCategoryEntertainment => 'Entretenimiento';

  @override
  String get txCategoryShopping => 'Compras';

  @override
  String get txCategorySubscriptions => 'Suscripciones';

  @override
  String get txCategoryCravings => 'Antojos';

  @override
  String get txCategorySavings => 'Ahorros';

  @override
  String get txCategoryOther => 'Otro';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileSignOutTooltip => 'Cerrar sesión';

  @override
  String get profileSignOutDialogTitle => 'Cerrar sesión';

  @override
  String get profileSignOutDialogContent =>
      '¿Seguro que quieres cerrar sesión?';

  @override
  String get profileErrorLoad => 'No se pudo cargar el perfil';

  @override
  String get profileErrorSave =>
      'No se pudieron guardar los cambios. Revisa tu conexión.';

  @override
  String get profileAge => 'Edad';

  @override
  String get profileUniversity => 'Universidad';

  @override
  String get profileCurrency => 'Moneda';

  @override
  String get profileIncomeType => 'Tipo de ingreso';

  @override
  String get profileMonthlyIncome => 'Ingreso mensual';

  @override
  String get profileFinancialLiteracy => 'Educación financiera';

  @override
  String get profileEditButton => 'Editar perfil';

  @override
  String get profileFullNameLabel => 'Nombre completo';

  @override
  String get profileAgeLabel => 'Edad';

  @override
  String get profileUniversityLabel => 'Universidad';
}
