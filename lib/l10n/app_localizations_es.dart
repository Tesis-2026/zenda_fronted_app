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
  String get onboardingHaveAccount => 'Ya tengo una cuenta';

  @override
  String dashboardGreeting(String name) {
    return 'Hola, $name';
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
  String get recommendationsReject => 'No útil';

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
  String get surveySubmitButton => 'Enviar respuestas';

  @override
  String get surveySubmitError =>
      'No se pudo enviar la encuesta. Inténtalo de nuevo.';

  @override
  String get surveyResultTitle => 'Tus resultados';

  @override
  String surveyImprovement(String points) {
    return '¡Tu conocimiento financiero mejoró $points puntos respecto a la encuesta inicial!';
  }

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
  String get consentTitle => 'Tus datos, tu control';
  @override
  String get consentSubtitle => 'Antes de empezar, revisa cómo Zenda maneja tu información.';
  @override
  String get consentBodyTitle => '¿Qué datos recopilamos?';
  @override
  String get consentBodyText => 'Zenda recopila tus registros de ingresos y gastos, perfil financiero (edad, universidad, tipo de ingreso) y datos de uso de la app para generar predicciones y recomendaciones personalizadas. Tus datos nunca se comparten con terceros y se almacenan de forma segura.';
  @override
  String get consentLawNote => 'En cumplimiento con la Ley 29733 — Ley de Protección de Datos Personales del Perú';
  @override
  String get consentCheckbox => 'Acepto que mis datos financieros sean procesados para generar reportes y predicciones personalizadas';
  @override
  String get consentAcceptButton => 'Aceptar y continuar';
  @override
  String get consentMustAccept => 'Debes aceptar para continuar';

  @override
  String get emailSentTitle => '¡Cuenta creada!';
  @override
  String emailSentSubtitle(String name) => 'Bienvenido a Zenda, $name';
  @override
  String emailSentBody(String email) => 'Se envió un correo de bienvenida a $email. Ahora configuremos tu perfil financiero.';
  @override
  String get emailSentContinue => 'Configurar mi perfil';
  @override
  String get emailSentSkip => 'Saltar por ahora';

  @override
  String get profileSetupTitle => 'Cuéntanos sobre ti';
  @override
  String get profileSetupSubtitle => 'Ayuda a Zenda a personalizar tu experiencia. Puedes editar esto en cualquier momento.';
  @override
  String get profileSetupAge => '¿Cuántos años tienes?';
  @override
  String get profileSetupAgeHint => 'ej. 21';
  @override
  String get profileSetupUniversity => '¿Dónde estudias?';
  @override
  String get profileSetupUniversityHint => 'ej. PUCP, UNMSM';
  @override
  String get profileSetupIncomeType => '¿Cómo obtienes ingresos principalmente?';
  @override
  String get profileSetupMonthlyIncome => 'Ingreso mensual promedio (S/)';
  @override
  String get profileSetupMonthlyIncomeHint => 'ej. 1500';
  @override
  String get profileSetupNext => 'Siguiente';
  @override
  String get profileSetupSave => 'Terminar';
  @override
  String get profileSetupSkip => 'Omitir';
  @override
  String get profileSetupCompleteTitle => '¡Listo!';
  @override
  String get profileSetupCompleteBody => 'Tu perfil está configurado. Tomemos el control de tus finanzas.';
  @override
  String get profileSetupGoToDashboard => 'Ir al inicio';
  @override
  String get incomeTypeNone => 'Sin ingresos';
  @override
  String get incomeTypePartTime => 'Trabajo a tiempo parcial';
  @override
  String get incomeTypeFullTime => 'Trabajo a tiempo completo';
  @override
  String get incomeTypeFreelance => 'Freelance';
  @override
  String get incomeTypeAllowance => 'Apoyo familiar / Beca';

  @override
  String get aiChatTitle => 'Zenda IA';
  @override
  String get aiChatInputHint => 'Pregunta lo que quieras sobre tus finanzas...';
  @override
  String get aiChatSend => 'Enviar';
  @override
  String get aiChatWelcome => '¡Hola! Soy Zenda, tu asistente financiero. Pregúntame sobre presupuestos, ahorros o gastos.';
  @override
  String get aiChatError => 'No pude obtener una respuesta. Inténtalo de nuevo.';
  @override
  String get aiChatNavLabel => 'Zenda IA';

  @override
  String get quizTitle => 'Quiz';
  @override
  String get quizEmpty => 'Aún no hay quiz disponible para este tema.';
  @override
  String get quizSubmit => 'Enviar';
  @override
  String get quizCorrect => '¡Correcto!';
  @override
  String get quizIncorrect => 'Incorrecto';
  @override
  String quizResult(int score) => 'Obtuviste $score%';
  @override
  String get quizFinish => 'Ver resultados';
  @override
  String get quizNext => 'Siguiente pregunta';
}
