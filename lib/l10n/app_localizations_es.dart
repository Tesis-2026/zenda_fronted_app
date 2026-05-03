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
  String get commonOk => 'Aceptar';

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
  String get commonDelete => 'Eliminar';

  @override
  String get commonLater => 'Más tarde';

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
  String get onboardingPage3Title => 'Mantén tu racha y mejora cada día';

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
  String get onboardingHaveAccount => '¿Ya tienes cuenta? Inicia sesión';

  @override
  String get onboardingFeature1 => 'Registra gastos con la regla 50/30/20';

  @override
  String get onboardingFeature2 => 'Establece y logra tus metas de ahorro';

  @override
  String get onboardingFeature3 => 'Insights de IA adaptados para estudiantes';

  @override
  String dashboardGreeting(String name) {
    return 'Hola, $name';
  }

  @override
  String get dashboardMotivation => 'Mejoremos tus finanzas hoy.';

  @override
  String get dashboardPostSurveyBannerTitle => 'Encuesta final disponible';

  @override
  String get dashboardPostSurveyBannerBody =>
      'Llevas 30 días usando Zenda — completa la encuesta final para medir tu progreso.';

  @override
  String get dashboardNavHome => 'INICIO';

  @override
  String get dashboardNavTransactions => 'MOVS';

  @override
  String get dashboardNavAi => 'IA';

  @override
  String get dashboardNavGoals => 'METAS';

  @override
  String get dashboardNavProfile => 'PERFIL';

  @override
  String get dashboardNavEducation => 'EDUC.';

  @override
  String get dashboardRecord => 'Registrar';

  @override
  String get dashboardMyAccounts => 'Mis Cuentas';

  @override
  String get dashboardNoAccounts => 'Sin cuentas aún';

  @override
  String get dashboardAddFirstAccount => 'Agrega tu primera cuenta';

  @override
  String get accountAddTitle => 'Agregar cuenta';

  @override
  String get accountNameLabel => 'Nombre de cuenta';

  @override
  String get accountNameHint => 'ej. BCP Ahorros';

  @override
  String get accountTypeLabel => 'Tipo de cuenta';

  @override
  String get accountTypeCash => 'Efectivo';

  @override
  String get accountTypeDebit => 'Débito';

  @override
  String get accountTypeCredit => 'Tarjeta de crédito';

  @override
  String get accountInitialBalance => 'Saldo inicial (S/)';

  @override
  String get accountCreditLimit => 'Límite de crédito (S/)';

  @override
  String get accountAddButton => 'Agregar cuenta';

  @override
  String get accountDebt => 'Deuda:';

  @override
  String get accountAvail => 'Disp:';

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
  String get txAddButton => '+ Agregar';

  @override
  String get txAddCustomCategory => 'Nueva categoría';

  @override
  String get txNoteLabel => 'Nota (opcional)';

  @override
  String get txNoteHint => 'ej. Cafetería';

  @override
  String get txDateLabel => 'Fecha';

  @override
  String get txSaveButton => 'Guardar transacción';

  @override
  String get txSaved => 'Guardado';

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
  String get txListTitle => 'Transacciones';

  @override
  String get txListEmpty => 'Aún no hay transacciones';

  @override
  String get txListFilterAll => 'Todas';

  @override
  String get txListFilterExpenses => 'Gastos';

  @override
  String get txListFilterIncome => 'Ingresos';

  @override
  String get txListFilterThisWeek => 'Esta semana';

  @override
  String get txListFilterThisMonth => 'Este mes';

  @override
  String get txListFilterAllTime => 'Todo el tiempo';

  @override
  String get txFilterAdvanced => 'Más filtros';

  @override
  String get txFilterCategory => 'Categoría';

  @override
  String get txFilterAllCategories => 'Todas las categorías';

  @override
  String get txFilterMinAmount => 'Monto mínimo (S/)';

  @override
  String get txFilterMaxAmount => 'Monto máximo (S/)';

  @override
  String get txFilterClear => 'Limpiar filtros';

  @override
  String get txFilterApply => 'Aplicar';

  @override
  String txFilterActiveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filtros activos',
      one: '1 filtro activo',
    );
    return '$_temp0';
  }

  @override
  String txBudgetAlert80(String category, String pct) {
    return 'Presupuesto de $category al $pct% — ¡casi en el límite!';
  }

  @override
  String txAnomalyAlert(String category) {
    return 'Gasto inusual en $category — supera tu promedio mensual en más del 20%';
  }

  @override
  String get aiCardSeeRecommendations => 'Ver recomendaciones';

  @override
  String get txDeleteConfirmTitle => 'Eliminar transacción';

  @override
  String get txDeleteConfirmMessage => 'Esta acción no se puede deshacer.';

  @override
  String get txDeleteAction => 'Eliminar';

  @override
  String get txDeleteError =>
      'No se pudo eliminar la transacción. Inténtalo de nuevo.';

  @override
  String get txEditTitle => 'Editar transacción';

  @override
  String get txUpdateButton => 'Guardar cambios';

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
  String get profileEdit => 'Editar';

  @override
  String get profileFullNameLabel => 'Nombre completo';

  @override
  String get profileAgeLabel => 'Edad';

  @override
  String get profileUniversityLabel => 'Universidad';

  @override
  String get profileManageCategories => 'Gestionar categorías';

  @override
  String get catMgmtTitle => 'Mis Categorías';

  @override
  String get catMgmtSystemSection => 'Categorías por defecto';

  @override
  String get catMgmtCustomSection => 'Categorías personalizadas';

  @override
  String get catMgmtEmpty => 'Aún no tienes categorías personalizadas';

  @override
  String get catMgmtAddTitle => 'Nueva categoría';

  @override
  String get catMgmtAddHint => 'Nombre de la categoría';

  @override
  String get catMgmtRenameTitle => 'Renombrar categoría';

  @override
  String get catMgmtDeleteConfirm =>
      '¿Eliminar esta categoría? Las transacciones que la usen conservarán sus datos.';

  @override
  String get catMgmtDeleteAction => 'Eliminar';

  @override
  String get catMgmtErrorLoad => 'No se pudieron cargar las categorías';

  @override
  String get catMgmtErrorSave => 'No se pudo guardar. Intenta de nuevo.';

  @override
  String get catMgmtAddButton => '+ Agregar';

  @override
  String get reportsTitle => 'Reportes';

  @override
  String get reportsTabMonth => 'Mes';

  @override
  String get reportsTabWeek => 'Semana';

  @override
  String get reportsTabCompare => 'Comparar';

  @override
  String get reportsTabDay => 'Día';

  @override
  String get reportsTopCategories => 'Principales categorías';

  @override
  String get reportsNoCategoryData => 'Sin datos de gasto para este período';

  @override
  String get reportsIncome => 'Ingresos';

  @override
  String get reportsExpense => 'Gastos';

  @override
  String get reportsBalance => 'Balance';

  @override
  String reportsCompareMonths(int count) {
    return 'Últimos $count meses';
  }

  @override
  String get reportsNoComparisonData => 'Sin datos disponibles';

  @override
  String get reportsErrorLoad => 'No se pudo cargar el reporte';

  @override
  String get reportsTotalIncome => 'Total de ingresos';

  @override
  String get reportsTotalExpense => 'Total de gastos';

  @override
  String get reportsNetBalance => 'Balance neto';

  @override
  String reportsWeekLabel(int week, int year) {
    return 'Semana $week, $year';
  }

  @override
  String reportsMonthLabel(String month, int year) {
    return '$month $year';
  }

  @override
  String get reportsExportPdf => 'Exportar PDF';

  @override
  String get reportsExportPdfError => 'No se pudo generar el PDF';

  @override
  String get profileBudgets => 'Presupuestos';

  @override
  String get profileGoals => 'Metas de ahorro';

  @override
  String get profileSectionFinance => 'Finanzas';

  @override
  String get profileSectionLearnGrow => 'Aprende y Crece';

  @override
  String get profileSectionSurveys => 'Encuestas';

  @override
  String get profileSectionSupport => 'Soporte';

  @override
  String get profileSendFeedback => 'Enviar comentarios';

  @override
  String get budgetTitle => 'Presupuestos';

  @override
  String get budgetEmptyTitle => 'Sin presupuestos';

  @override
  String get budgetEmptySubtitle =>
      'Crea un presupuesto para controlar tus gastos por categoría';

  @override
  String get budgetAddTitle => 'Nuevo presupuesto';

  @override
  String get budgetCategoryAll => 'Todas las categorías';

  @override
  String get budgetAmountLabel => 'Límite de gasto (S/)';

  @override
  String get budgetMonthLabel => 'Mes';

  @override
  String get budgetYearLabel => 'Año';

  @override
  String budgetSpentOf(String spent, String limit) {
    return 'S/ $spent de S/ $limit';
  }

  @override
  String budgetPercentUsed(String percent) {
    return '$percent% usado';
  }

  @override
  String get budgetErrorLoad => 'No se pudieron cargar los presupuestos';

  @override
  String get budgetDeleteConfirm => '¿Eliminar este presupuesto?';

  @override
  String get budgetDuplicate =>
      'Ya existe un presupuesto para esta categoría y período';

  @override
  String get budgetEditTitle => 'Editar presupuesto';

  @override
  String get goalsTitle => 'Metas de ahorro';

  @override
  String get goalsEmptyTitle => 'Sin metas';

  @override
  String get goalsEmptySubtitle =>
      'Crea una meta de ahorro para seguir tu progreso';

  @override
  String get goalsAddTitle => 'Nueva meta';

  @override
  String get goalsNameLabel => 'Nombre de la meta';

  @override
  String get goalsNameHint => 'ej. Fondo de emergencia';

  @override
  String get goalsTargetLabel => 'Monto objetivo (S/)';

  @override
  String get goalsContributeTitle => 'Agregar aporte';

  @override
  String get goalsContributeLabel => 'Monto (S/)';

  @override
  String goalsProgressLabel(String current, String target) {
    return 'S/ $current de S/ $target';
  }

  @override
  String get goalsErrorLoad => 'No se pudieron cargar las metas';

  @override
  String get goalsDeleteConfirm => '¿Eliminar esta meta?';

  @override
  String get goalsDeleteLabel => 'Eliminar';

  @override
  String get goalsDueDateLabel => 'Fecha límite (opcional)';

  @override
  String get goalsMarkComplete => 'Marcar como completada';

  @override
  String get goalsDetailTitle => 'Detalle de meta';

  @override
  String get goalsDetailContributionHistory => 'Historial de aportes';

  @override
  String get goalsDetailNoContributions => 'Sin aportes todavía';

  @override
  String goalsDetailProjection(String date) {
    return 'A este ritmo completarás tu meta el $date';
  }

  @override
  String goalsDetailAlert(String date) {
    return 'A este ritmo no alcanzarás tu meta antes del $date';
  }

  @override
  String get goalsDetailProgressChart => 'Progreso acumulado';

  @override
  String get authVerifyTitle => 'Ingresa el código de verificación';

  @override
  String authVerifySubtitle(String email) {
    return 'Enviamos un código de 6 dígitos a $email. Expira en 15 minutos.';
  }

  @override
  String get authVerifyResend => 'Reenviar código';

  @override
  String authVerifyResendCooldown(int seconds) {
    return 'Reenviar en ${seconds}s';
  }

  @override
  String get authVerifyButton => 'Verificar código';

  @override
  String get authVerifyInvalidCode =>
      'Código inválido o expirado. Intenta de nuevo.';

  @override
  String get authLockedAccount =>
      'Cuenta bloqueada. Intenta de nuevo en 15 minutos.';

  @override
  String authLockedCountdown(String time) {
    return 'Cuenta bloqueada. Intenta de nuevo en $time.';
  }

  @override
  String authAttemptsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count intentos restantes antes del bloqueo',
      one: '1 intento restante antes del bloqueo',
    );
    return '$_temp0';
  }

  @override
  String get goalsCompletedSection => 'Metas completadas';

  @override
  String get goalsActiveSection => 'Metas activas';

  @override
  String goalsDueDate(String date) {
    return 'Fecha: $date';
  }

  @override
  String goalsDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días restantes',
      one: '1 día restante',
    );
    return '$_temp0';
  }

  @override
  String get goalsOverdue => 'Vencida';

  @override
  String get goalsCelebrate => '¡Meta lograda!';

  @override
  String goalsCelebrateMessage(String name) {
    return '¡Felicitaciones! Alcanzaste tu meta de ahorro para \"$name\".';
  }

  @override
  String get goalsMarkCompleteConfirm => '¿Marcar esta meta como completada?';

  @override
  String get goalsMarkCompleteConfirmBody =>
      'Esto cerrará la meta y la marcará como lograda.';

  @override
  String get goalsDetailDueDate => 'Fecha objetivo';

  @override
  String get goalsDetailDaysLeft => 'Días restantes';

  @override
  String get goalsDetailMarkComplete => 'Marcar como lograda';

  @override
  String get goalsDetailDelete => 'Eliminar meta';

  @override
  String goalCompletedOn(String date) {
    return 'Completado el $date';
  }

  @override
  String get reportsCalendarTitle => 'Calendario de gastos';

  @override
  String get reportsCalendarNoData => 'Sin gastos este día';

  @override
  String reportsDayTotal(String total) {
    return 'S/ $total';
  }

  @override
  String txAiSuggests(String category) {
    return 'Zenda sugiere: $category';
  }

  @override
  String get txAiApply => 'Aplicar sugerencia';

  @override
  String get educationPersonalized => 'Personalizado para ti';

  @override
  String get educationPersonalizedSubtitle =>
      'Temas ordenados según tus patrones de gasto';

  @override
  String get profileNumberFormat => 'Formato de número';

  @override
  String get profileNumberFormatDot => '1,234.56 (decimal con punto)';

  @override
  String get profileNumberFormatComma => '1.234,56 (decimal con coma)';

  @override
  String get profileNumberFormatSaved => 'Formato de número guardado.';

  @override
  String get errorAuthInvalidCredentials => 'Correo o contraseña incorrectos.';

  @override
  String get errorAuthEmailTaken => 'Este correo ya está registrado.';

  @override
  String get errorAuthTokenExpired => 'El enlace es inválido o ha expirado.';

  @override
  String get errorAuthBadRequest => 'Revisa tus datos e inténtalo de nuevo.';

  @override
  String get errorServerError => 'Error inesperado. Inténtalo de nuevo.';

  @override
  String get errorNoConnection => 'No se pudo conectar con el servidor.';

  @override
  String get errorTxNoSourceAccount => 'Selecciona una cuenta de origen.';

  @override
  String get errorTxInvalidAmount => 'Ingresa un monto mayor a 0.';

  @override
  String get errorTxNoCategory => 'Selecciona una categoría.';

  @override
  String get errorTxNoDestAccount => 'Selecciona una cuenta destino.';

  @override
  String get errorTxSameAccount => 'La cuenta destino debe ser distinta.';

  @override
  String get errorTxInvalidSourceAccount => 'Cuenta origen inválida.';

  @override
  String get errorTxInvalidDestAccount => 'Cuenta destino inválida.';

  @override
  String get errorTxCreditTransferNotSupported =>
      'Transferir desde tarjeta de crédito no está disponible.';

  @override
  String get errorTxSaveFailed =>
      'No se pudo guardar la transacción. Inténtalo de nuevo.';

  @override
  String get predictionsTitle => 'Predicciones IA';

  @override
  String get predictionsExpenseTitle => 'Gastos del próximo mes';

  @override
  String get predictionsConfidence => 'Confianza';

  @override
  String get predictionsErrorLoad => 'No se pudieron cargar las predicciones';

  @override
  String get predictionsDisclaimer =>
      'Las predicciones son estimaciones basadas en tu historial. Los resultados reales pueden variar.';

  @override
  String get predictionsLowConfidence =>
      'Aún no hay suficientes datos para una predicción confiable. Sigue registrando transacciones para mejorar la precisión.';

  @override
  String get recommendationsTitle => 'Recomendaciones';

  @override
  String get recommendationsEmpty =>
      'Aún no hay recomendaciones. Agrega más transacciones para obtener consejos personalizados.';

  @override
  String get recommendationsErrorLoad =>
      'No se pudieron cargar las recomendaciones';

  @override
  String get recommendationsAccept => 'Útil';

  @override
  String get recommendationsReject => 'No es relevante';

  @override
  String get educationTitle => 'Educación financiera';

  @override
  String get educationErrorLoad => 'No se pudieron cargar los temas';

  @override
  String educationProgressLabel(int completed, int total) {
    return '$completed de $total temas completados';
  }

  @override
  String get educationTopicDetailTitle => 'Tema';

  @override
  String get educationMarkComplete => 'Marcar como completado';

  @override
  String get educationTopicCompleted => '¡Tema completado!';

  @override
  String get challengesTitle => 'Desafíos';

  @override
  String get challengesSectionActive => 'Activos';

  @override
  String get challengesSectionAvailable => 'Disponibles';

  @override
  String get challengesSectionCompleted => 'Completados';

  @override
  String get challengesSectionExpired => 'Expirados';

  @override
  String get challengesEmpty => 'No hay desafíos disponibles por ahora.';

  @override
  String get challengesErrorLoad => 'No se pudieron cargar los desafíos';

  @override
  String get challengesAcceptButton => 'Aceptar desafío';

  @override
  String get challengesAccepted => '¡Desafío aceptado!';

  @override
  String get challengesCompleteButton => 'Marcar completado';

  @override
  String get challengesCompleted => '¡Desafío completado!';

  @override
  String get challengeAutoCompletedTitle => '¡Reto completado!';

  @override
  String challengeAutoCompletedBody(String name) {
    return 'Completaste: $name';
  }

  @override
  String get challengeAutoCompletedDismiss => '¡Genial!';

  @override
  String get badgesTitle => 'Insignias';

  @override
  String get badgesErrorLoad => 'No se pudieron cargar las insignias';

  @override
  String badgesEarnedCount(int earned, int total) {
    return '$earned de $total insignias obtenidas';
  }

  @override
  String get progressTitle => 'Progreso financiero';

  @override
  String get progressErrorLoad => 'No se pudo cargar el progreso';

  @override
  String get progressCurrentMonth => 'Mes actual';

  @override
  String get progressPreviousMonth => 'Mes anterior';

  @override
  String get progressChangesTitle => 'Cambios mes a mes';

  @override
  String get progressExpensesChange => 'Gastos';

  @override
  String get progressSavingsChange => 'Ahorros';

  @override
  String get progressBalanceChange => 'Balance';

  @override
  String get progressNoData => 'Sin datos';

  @override
  String get surveyPreTitle => 'Encuesta inicial';

  @override
  String get surveyPostTitle => 'Encuesta final';

  @override
  String get surveyErrorLoad => 'No se pudo cargar la encuesta';

  @override
  String get surveyAnswerAll =>
      'Por favor responde todas las preguntas antes de enviar';

  @override
  String get surveyNextButton => 'Siguiente';

  @override
  String get surveySubmitButton => 'Enviar respuestas';

  @override
  String get surveySubmitError =>
      'No se pudo enviar la encuesta. Inténtalo de nuevo.';

  @override
  String get surveyResultTitle => 'Tus resultados';

  @override
  String get surveyResultContinue => 'Continuar al Panel';

  @override
  String surveyImprovement(String points) {
    return '¡Tu conocimiento financiero mejoró $points puntos respecto a la encuesta inicial!';
  }

  @override
  String get susSurveyTitle => 'Cuestionario de Usabilidad';

  @override
  String get susSurveyDescription =>
      'Califica cada afirmación del 1 (Totalmente en desacuerdo) al 5 (Totalmente de acuerdo).';

  @override
  String get susSurveyStronglyDisagree => 'Totalmente en desacuerdo';

  @override
  String get susSurveyStronglyAgree => 'Totalmente de acuerdo';

  @override
  String get susSurveySubmit => 'Enviar';

  @override
  String get susSurveySubmitting => 'Enviando...';

  @override
  String get susSurveyAlreadyDone =>
      'Ya enviaste el cuestionario de usabilidad.';

  @override
  String get susSurveyErrorLoad =>
      'No se pudo cargar el cuestionario. Inténtalo de nuevo.';

  @override
  String get susSurveyErrorSubmit => 'No se pudo enviar. Inténtalo de nuevo.';

  @override
  String get susSurveyResultTitle => 'Puntaje de Usabilidad';

  @override
  String susSurveyResultScore(int score) {
    return 'Tu puntaje SUS: $score/100';
  }

  @override
  String susSurveyResultGrade(String grade) {
    return 'Calificación: $grade';
  }

  @override
  String get susSurveyResultContinue => 'Volver al Perfil';

  @override
  String get surveyComparisonPreLabel => 'Puntaje inicial';

  @override
  String get surveyComparisonPostLabel => 'Puntaje final';

  @override
  String get surveyComparisonImprovementLabel => 'Mejora';

  @override
  String get surveyComparisonGoalLabel => 'Meta de tesis: ≥ 20 puntos';

  @override
  String get surveyComparisonGoalMet => '¡Meta alcanzada!';

  @override
  String get surveyComparisonGoalNotMet => 'Sigue usando la app para mejorar';

  @override
  String get surveyComparisonPending =>
      'Completa ambas encuestas para ver tu progreso';

  @override
  String get surveyComparisonPrePending => 'Encuesta inicial no completada';

  @override
  String get surveyComparisonPostPending => 'Encuesta final no completada';

  @override
  String get surveyComparisonNavTitle => 'Progreso de conocimiento';

  @override
  String get feedbackTitle => 'Enviar comentarios';

  @override
  String get feedbackTypeLabel => 'Tipo';

  @override
  String get feedbackRatingLabel => 'Calificación';

  @override
  String get feedbackMessageLabel => 'Mensaje';

  @override
  String get feedbackMessageHint => 'Cuéntanos qué piensas...';

  @override
  String get feedbackSubmitButton => 'Enviar comentario';

  @override
  String get feedbackThanks => '¡Gracias por tus comentarios!';

  @override
  String get feedbackMessageRequired => 'Por favor ingresa un mensaje';

  @override
  String get feedbackSubmitError =>
      'No se pudo enviar el comentario. Inténtalo de nuevo.';

  @override
  String get notificationsTitle => 'Preferencias de notificaciones';

  @override
  String get notificationsErrorLoad => 'No se pudieron cargar las preferencias';

  @override
  String get notificationTypeBudgetAlert => 'Alertas de presupuesto';

  @override
  String get notificationTypeAnomalyAlert => 'Alertas de gasto inusual';

  @override
  String get notificationTypePredictionReady => 'Predicción lista';

  @override
  String get notificationTypeChallengeReminder => 'Recordatorios de desafíos';

  @override
  String get notificationTypeDailyReminder => 'Recordatorio diario';

  @override
  String get notificationTypeBadgeEarned => 'Insignia obtenida';

  @override
  String get consentTitle => 'Tu privacidad importa';

  @override
  String get consentSubtitle =>
      'Antes de empezar, lee cómo Zenda maneja tus datos financieros.';

  @override
  String get consentBullet1 =>
      'Tus datos están cifrados y almacenados de forma segura en servidores Azure.';

  @override
  String get consentBullet2 =>
      'Tus datos se usan solo para generar reportes personalizados y predicciones de IA.';

  @override
  String get consentBullet3 =>
      'Nunca se comparten con terceros. Puedes solicitar su eliminación en cualquier momento.';

  @override
  String get consentBodyTitle => '¿Qué datos recopilamos?';

  @override
  String get consentBodyText =>
      'Zenda recopila tus registros de ingresos y gastos, perfil financiero (edad, universidad, tipo de ingreso) y datos de uso de la app para generar predicciones y recomendaciones personalizadas. Tus datos nunca se comparten con terceros y se almacenan de forma segura.';

  @override
  String get consentLawNote =>
      'Esta app cumple con la Ley de Protección de Datos Personales del Perú (Ley 29733).';

  @override
  String get consentCheckbox =>
      'Acepto que mis datos financieros sean procesados para generar reportes personalizados y predicciones de IA.';

  @override
  String get consentAcceptButton => 'Acepto — Comencemos';

  @override
  String get consentMustAccept => 'Debes aceptar para continuar';

  @override
  String get emailSentTitle => '¡Cuenta creada!';

  @override
  String emailSentSubtitle(String name) {
    return 'Bienvenido a Zenda, $name';
  }

  @override
  String emailSentBody(String email) {
    return 'Se envió un correo de bienvenida a $email. Ahora configuremos tu perfil financiero.';
  }

  @override
  String get emailSentContinue => 'Configurar mi perfil';

  @override
  String get emailSentSkip => 'Saltar por ahora';

  @override
  String get profileSetupTitle => 'Cuéntanos sobre ti';

  @override
  String get profileSetupSubtitle =>
      'Ayuda a Zenda a personalizar tu experiencia. Puedes editar esto en cualquier momento.';

  @override
  String profileSetupStep(int step, int total) {
    return 'Paso $step de $total';
  }

  @override
  String get profileSetupSkip => 'Omitir';

  @override
  String get profileSetupAge => '¿Cuántos años tienes?';

  @override
  String get profileSetupAgeHint =>
      'Esto nos ayuda a entender tu etapa financiera y personalizar tus insights.';

  @override
  String get profileSetupUniversity => '¿En qué universidad estudias?';

  @override
  String get profileSetupUniversityHint => 'ej. PUCP, ULima, UNMSM...';

  @override
  String get profileSetupUniversitySubtitle =>
      'Tu campus nos ayuda a sugerir recursos financieros locales.';

  @override
  String get profileSetupIncomeType =>
      '¿Cuál es tu principal fuente de ingresos?';

  @override
  String get profileSetupIncomeTypeSubtitle =>
      'Usamos esto para personalizar tus recomendaciones de presupuesto 50/30/20.';

  @override
  String get profileSetupMonthlyIncome =>
      '¿Cuál es tu ingreso mensual promedio?';

  @override
  String get profileSetupMonthlyIncomeHint =>
      'Un estimado está bien. Esto calibra tus objetivos de presupuesto 50/30/20.';

  @override
  String get profileSetupMonthlyIncomePerMonth => 'por mes';

  @override
  String get profileSetupNext => 'Continuar →';

  @override
  String get profileSetupSave => 'Finalizar →';

  @override
  String get profileSetupCompleteTitle => '¡Listo!';

  @override
  String profileSetupCompleteTitleNamed(String name) {
    return '¡Todo listo, $name!';
  }

  @override
  String get profileSetupCompleteBody =>
      'Tu perfil está listo. Toma el control de tus finanzas.';

  @override
  String get profileSetupGoToDashboard => 'Comenzar a usar Zenda';

  @override
  String get incomeTypeScholarship => 'Beca / Subvención';

  @override
  String get incomeTypeScholarshipSub =>
      'Beca, PRONABEC, financiamiento universitario';

  @override
  String get incomeTypePartTime => 'Medio tiempo / Freelance';

  @override
  String get incomeTypePartTimeSub => 'Trabajo, gigs, proyectos paralelos';

  @override
  String get incomeTypeFamily => 'Apoyo Familiar';

  @override
  String get incomeTypeFamilySub => 'Mensualidad de la familia';

  @override
  String get incomeTypeMixed => 'Mixto';

  @override
  String get incomeTypeMixedSub => 'Combinación de los anteriores';

  @override
  String get aiChatTitle => 'Zenda AI';

  @override
  String get aiChatSubtitle => 'Basado en tus datos financieros';

  @override
  String get aiChatInputHint => 'Pregúntale a Zenda AI lo que quieras...';

  @override
  String get aiChatSend => 'Enviar';

  @override
  String get aiChatWelcome =>
      '¡Hola! Soy Zenda, tu asistente financiero. Pregúntame sobre presupuestos, ahorros o gastos.';

  @override
  String get aiChatError =>
      'No pude obtener una respuesta. Inténtalo de nuevo.';

  @override
  String get aiChatNavLabel => 'Zenda IA';

  @override
  String get quizTitle => 'Quiz';

  @override
  String quizQuestionOf(int current, int total) {
    return 'Pregunta $current de $total';
  }

  @override
  String get quizEmpty => 'Aún no hay quiz disponible para este tema.';

  @override
  String get quizSubmit => 'Enviar';

  @override
  String get quizCorrect => '¡Correcto!';

  @override
  String get quizIncorrect => 'Incorrecto';

  @override
  String quizResult(int score) {
    return 'Obtuviste $score%';
  }

  @override
  String get quizFinish => 'Ver resultados';

  @override
  String get quizNext => 'Siguiente pregunta';

  @override
  String get quizPersonalizedTitle => 'Quiz personalizado';

  @override
  String get quizPersonalizedButton => 'Tomar quiz personalizado';

  @override
  String get quizPersonalizedSubtitle =>
      'Preguntas generadas con IA basadas en tus hábitos';

  @override
  String get quizPersonalizedAnalyzing =>
      'Analizando tus hábitos financieros...';

  @override
  String quizPersonalizedAttemptsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count intentos restantes hoy',
      one: '1 intento restante hoy',
    );
    return '$_temp0';
  }

  @override
  String get quizPersonalizedLimitReached =>
      'Alcanzaste el límite de 5 quizzes personalizados por hoy.';

  @override
  String get quizPersonalizedError =>
      'No se pudo generar el quiz. Inténtalo de nuevo.';

  @override
  String get educationRecommended => 'Recomendado';

  @override
  String get reportsWeekDailyTitle => 'Actividad diaria';

  @override
  String get reportsProgressChipsTitle => 'Cambios vs mes anterior';

  @override
  String reportsExpensesChip(String sign, String pct) {
    return 'Gastos $sign$pct%';
  }

  @override
  String reportsSavingsChip(String sign, String pct) {
    return 'Ahorros $sign$pct%';
  }

  @override
  String reportsBalanceChip(String sign, String pct) {
    return 'Balance $sign$pct%';
  }

  @override
  String get aiAdviceStartRecording =>
      'Empieza a registrar gastos para recibir consejos personalizados.';

  @override
  String aiAdviceReduceWants(String pct) {
    return 'Tus \"deseos\" están volando alto ($pct%). Considera reducir gastos hormiga como cafés o taxis para equilibrarte.';
  }

  @override
  String aiAdviceSaveLow(String pct) {
    return 'Tu ahorro está bajo ($pct%). Intenta separar un monto fijo al inicio de semana, aunque sea pequeño.';
  }

  @override
  String get aiAdviceOnTrack =>
      '¡Vas muy bien! Tu presupuesto está equilibrado. Sigue así y considera invertir tus excedentes.';

  @override
  String get surveyResultDialogTitle => 'Tus resultados';

  @override
  String surveyResultDialogBody(String level, String score) {
    return 'Nivel de educación financiera: $level ($score/100)';
  }

  @override
  String get surveyImprovementDialogTitle => '¡Progreso medido!';

  @override
  String surveyImprovementDialogBody(
    String postScore,
    String preScore,
    String improvement,
  ) {
    return 'Puntaje: $postScore/100. Anterior: $preScore/100. ¡Mejoraste $improvement puntos!';
  }

  @override
  String get profileSectionPrivacy => 'PRIVACIDAD';

  @override
  String get profilePrivacyLaw => 'Protección de datos — Ley 29733';

  @override
  String get profilePrivacyLawSubtitle =>
      'Tus datos están protegidos bajo la ley peruana';

  @override
  String get profilePrivacyLawBody =>
      'Zenda cumple con la Ley 29733 de Protección de Datos Personales del Perú. Tus datos financieros se transmiten exclusivamente por HTTPS/TLS y se almacenan de forma segura. El acceso requiere autenticación válida en todo momento. Puedes revocar tu consentimiento en cualquier momento desde esta pantalla.';

  @override
  String get profileRevokeConsent => 'Revocar consentimiento de datos';

  @override
  String get profileRevokeConsentDialogTitle =>
      '¿Revocar consentimiento de datos?';

  @override
  String get profileRevokeConsentDialogBody =>
      'Las funciones de personalización de IA (predicciones, recomendaciones) serán desactivadas. Tus datos ya no serán procesados por IA. Puedes reactivar esto en configuración.';

  @override
  String get profileRevokeConsentConfirm => 'Revocar';

  @override
  String get profileRevokeConsentDone =>
      'Consentimiento revocado. Las funciones de IA están desactivadas.';

  @override
  String get profileConsentAlreadyRevoked =>
      'El consentimiento de datos ya ha sido revocado.';

  @override
  String get reportsTabCategories => 'Categorías';

  @override
  String get reportsPeriodWeek => 'Semana';

  @override
  String get reportsPeriodMonth => 'Mes';

  @override
  String get reportsPeriodQuarter => 'Trimestre';

  @override
  String reportsCategoryDrillTitle(String category) {
    return 'Transacciones de $category';
  }

  @override
  String get reportsCategoryNoTransactions =>
      'No hay transacciones en este período';

  @override
  String get txFilterCustomRange => 'Rango de fechas';

  @override
  String get txFilterDateFrom => 'Desde';

  @override
  String get txFilterDateTo => 'Hasta';

  @override
  String get txFilterClearDates => 'Limpiar fechas';

  @override
  String get reportsEvolutionTitle => 'Evolución mensual';

  @override
  String get reportsEvolutionExpenses => 'Gastos';

  @override
  String get reportsEvolutionSavings => 'Ahorro';

  @override
  String get reportsEvolutionBalance => 'Balance';

  @override
  String get reportsEvolutionNoData =>
      'Agrega datos de al menos 2 meses para ver tu evolución';

  @override
  String get dashboardPostSurveyBannerAction => 'Completar encuesta';

  @override
  String get authConfirmPasswordHint => 'Confirmar contraseña';

  @override
  String get validationPasswordsMismatch => 'Las contraseñas no coinciden';

  @override
  String get dashboardTotalBalance => 'Balance Total';

  @override
  String get dashboardViewAll => 'Ver todo';

  @override
  String get dashboardMonthlyIncome => 'Ingresos';

  @override
  String get dashboardMonthlyExpense => 'Gastos';

  @override
  String get dashboardCashDebitCredit => 'Efectivo · Débito · Crédito';

  @override
  String get goalsNewButton => '+ Nuevo';

  @override
  String get goalsCreateButton => 'Crear meta';

  @override
  String goalsContributeAddAction(String amount) {
    return 'Agregar S/ $amount a la meta';
  }

  @override
  String get emailVerifTitle => 'Revisa tu correo';

  @override
  String emailVerifSubtitle(String email) {
    return 'Enviamos un enlace de verificación a $email';
  }

  @override
  String get emailVerifStep1 => 'Abre el correo de Zenda';

  @override
  String get emailVerifStep2 => 'Haz clic en el enlace de verificación';

  @override
  String get emailVerifStep3 => 'Vuelve a la app para continuar';

  @override
  String get emailVerifOpenApp => 'Abrir app de correo';

  @override
  String get emailVerifResendText => '¿No lo recibiste?';

  @override
  String get emailVerifResendAction => 'Reenviar';

  @override
  String get txSavedTitle => '¡Transacción guardada!';

  @override
  String get txSavedBody =>
      'Tu gasto fue registrado y tu presupuesto actualizado.';

  @override
  String get txSavedLabelAmount => 'Monto';

  @override
  String get txSavedLabelCategory => 'Categoría';

  @override
  String get txSavedLabelDate => 'Fecha';

  @override
  String get txSavedLabelBudget => 'Impacto en presupuesto';

  @override
  String get txSavedBackButton => 'Volver a transacciones';

  @override
  String get txSavedAddAnother => 'Agregar otra';

  @override
  String get authResetSuccessTitle => '¡Contraseña actualizada!';

  @override
  String get authResetSuccessBody =>
      'Tu contraseña fue restablecida exitosamente. Ya puedes iniciar sesión con tu nueva contraseña.';

  @override
  String get authResetSuccessSecurity =>
      'Por tu seguridad, se cerraron todas tus sesiones.';

  @override
  String get authResetSuccessButton => 'Iniciar sesión';

  @override
  String get authSetNewPasswordTitle => 'Nueva contraseña';

  @override
  String get authSetNewPasswordSubtitle =>
      'Tu nueva contraseña debe tener al menos 8 caracteres, 1 mayúscula y 1 número.';

  @override
  String get authConfirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get authPasswordStrengthWeak => 'Débil';

  @override
  String get authPasswordStrengthFair => 'Regular';

  @override
  String get authPasswordStrengthStrong => 'Fuerte';

  @override
  String goalsDetailLeftToReach(String amount) {
    return 'S/ $amount restante para alcanzar tu meta';
  }

  @override
  String get goalsDetailAddContrib => '+ Agregar';

  @override
  String get budgetByCategory => 'Por categoría';

  @override
  String get authForgotCodeExpiry =>
      'El código de verificación expira en 15 minutos. Revisa tu carpeta de spam si no lo encuentras.';

  @override
  String get aiChatQuickAnalyze => 'Analizar gastos';

  @override
  String get aiChatQuickBudget => 'Tips de presupuesto';

  @override
  String get aiChatQuickGoal => 'Progreso de metas';

  @override
  String get profileSetupAgeStepperLabel => 'años';

  @override
  String get profileSetupPopularUniversities => 'Universidades populares';

  @override
  String get profileSetupIncomeQuick500 => 'S/ 500';

  @override
  String get profileSetupIncomeQuick1200 => 'S/ 1,200';

  @override
  String get profileSetupIncomeQuick2000 => 'S/ 2,000';

  @override
  String get educationSearchHint => 'Buscar temas...';

  @override
  String get educationTabLearn => 'Aprender';

  @override
  String get educationTabChallenges => 'Retos';

  @override
  String get educationTabBadges => 'Insignias';

  @override
  String get educationTabProgress => 'Progreso';

  @override
  String get educationFilterAll => 'Todos';

  @override
  String get educationFilterBeginner => 'Básico';

  @override
  String get educationFilterIntermediate => 'Intermedio';

  @override
  String get educationFilterAdvanced => 'Avanzado';

  @override
  String get educationFeaturedLabel => 'Destacado';

  @override
  String get educationStartLabel => 'Comenzar';

  @override
  String get educationLearnGrow => 'Aprende & Crece';

  @override
  String get educationFilterBudgeting => 'Presupuesto';

  @override
  String get educationFilterSaving => 'Ahorro';

  @override
  String get educationFilterInvesting => 'Inversión';

  @override
  String get educationTakeQuiz => 'Tomar el quiz';

  @override
  String educationMinRead(int minutes) {
    return '$minutes min de lectura';
  }

  @override
  String educationQuestions(int count) {
    return '$count preguntas';
  }

  @override
  String get educationLocked => 'Completa los temas anteriores primero';

  @override
  String get quizAnswerRecorded =>
      'Respuesta guardada. Toca Siguiente para continuar.';

  @override
  String get authSignUpLink => 'Regístrate';

  @override
  String get goalManualContribution => 'Contribución manual';

  @override
  String get goalTargetSuffix => 'meta';

  @override
  String get profileSetupSaveError =>
      'No se pudo guardar el perfil. Continuando de todos modos.';

  @override
  String get profileSetupComplete40pct => '40% mejores predicciones';

  @override
  String get profileSetupCompleteImproves =>
      'Completar tu perfil mejora la precisión del pronóstico.';

  @override
  String get budgetSelectPeriod => 'Seleccionar período';

  @override
  String get commonDone => 'Listo';

  @override
  String get profileCurrencyPEN => 'PEN — Sol peruano (S/)';

  @override
  String get profileCurrencyUSD => 'USD — Dólar americano (\$)';

  @override
  String get splashTagline => 'Tu compañero de finanzas con IA';

  @override
  String get splashFooter => 'Hecho para universitarios peruanos';

  @override
  String get dashboardManageBudgets => 'Toca para gestionar presupuestos';

  @override
  String get streakTapToView => 'Toca para ver el progreso';

  @override
  String get aiCardPredictionsChat => 'Predicciones y Chat IA';

  @override
  String get aiCardViewForecast => 'Ver pronóstico';

  @override
  String get reportsVsLastMonth => 'vs mes anterior';

  @override
  String get reportsAiInsightsTitle => 'Insights de IA';

  @override
  String get reportsAiInsightsSaved =>
      'Ahorraste más que el mes pasado. ¡Excelente!';

  @override
  String get reportsAiInsightsExceeded => 'categoría superó el límite.';

  @override
  String get progressOverviewTitle => 'Resumen del Mes';

  @override
  String get progressTotalExpenses => 'Gastos Totales';

  @override
  String get progressTotalSavings => 'Ahorros Totales';

  @override
  String get progressNetBalance => 'Balance Neto';

  @override
  String get progressTrendTitle => 'Tendencia Mensual';

  @override
  String get progressVsLabel => 'vs';

  @override
  String get progressSavingsLegend => 'Ahorros';

  @override
  String get badgesSectionEarned => 'Ganadas';

  @override
  String get badgesSectionLocked => 'Bloqueadas';

  @override
  String get badgesEarnedLabel => 'ganadas';

  @override
  String get predictionsProjectedBalance => 'Balance Proyectado';

  @override
  String get predictionsConfident => 'confianza';

  @override
  String get predictionsBasedOnMonths => 'Basado en los últimos 3 meses';

  @override
  String get predictionsProjectedExpenses => 'Gastos proyectados';

  @override
  String get predictionsTopCategories => 'Principales categorías de gastos';

  @override
  String get predictionsVsLastMonth => '8% vs mes anterior';

  @override
  String get recommendationsSubtitle =>
      '3 consejos personalizados para ti esta semana';

  @override
  String get recommendationsRateExperience => 'Valorar experiencia →';

  @override
  String get notificationsMasterTitle => 'Activar Notificaciones';

  @override
  String get notificationsMasterSubtitle => 'Recibe alertas y recordatorios';

  @override
  String get notificationsCategoriesLabel => 'Categorías';

  @override
  String get notificationSubtypeBudgetAlert =>
      'Cuando alcances el 80% de tu presupuesto';

  @override
  String get notificationSubtypeAnomalyAlert =>
      'Patrones de gasto inusual detectados';

  @override
  String get notificationSubtypePredictionReady => 'Predicción mensual lista';

  @override
  String get notificationSubtypeChallengeReminder =>
      'Nuevos desafíos e insignia ganada';

  @override
  String get notificationSubtypeDailyReminder =>
      'Recuérdame registrar transacciones';

  @override
  String get notificationSubtypeBadgeEarned => 'Nueva insignia ganada';

  @override
  String get surveySkipButton => 'Omitir';

  @override
  String get surveyProgressOf => 'de';

  @override
  String get surveyCompleteTitle => '¡Encuesta Completada!';

  @override
  String get surveyCompleteSubtitle =>
      '¡Gracias por compartir! Usaremos tus respuestas para personalizar Zenda para ti.';

  @override
  String get surveyBadgeUnlocked => 'insignia desbloqueada!';

  @override
  String get surveyFinancialProfileTitle => 'Tu Perfil Financiero';

  @override
  String get surveyFinancialProfileBody =>
      'Basándonos en tus respuestas, Zenda ha personalizado tu panel y recomendaciones para ayudarte a construir mejores hábitos de ahorro.';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSectionGeneral => 'General';

  @override
  String get settingsSectionResearch => 'Investigación';

  @override
  String get settingsCategoriesLabel => 'Categorías';

  @override
  String get settingsNotificationsLabel => 'Notificaciones';

  @override
  String get settingsSurveysLabel => 'Encuestas';

  @override
  String get settingsSurveysSheetTitle => 'Encuestas';

  @override
  String get settingsSurveyPreLabel => 'Encuesta Pre-Uso';

  @override
  String get settingsSurveyPreSubtitle =>
      'Evaluación inicial de conocimiento financiero';

  @override
  String get settingsSurveyPostLabel => 'Encuesta Post-Uso';

  @override
  String get settingsSurveyPostSubtitle =>
      'Mide tu progreso después de 30 días';

  @override
  String get settingsSurveySusLabel => 'Cuestionario SUS';

  @override
  String get settingsSurveySusSubtitle => 'Evalúa tu experiencia con la app';

  @override
  String get settingsSurveyComparisonLabel => 'Progreso de Conocimiento';

  @override
  String get settingsSurveyComparisonSubtitle =>
      'Compara tus puntajes de encuesta pre y post';

  @override
  String get aiChatOnline => 'En línea';

  @override
  String get txListToday => 'Hoy';

  @override
  String get txListYesterday => 'Ayer';
}
