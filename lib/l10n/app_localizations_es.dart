// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Xolo API Client';

  @override
  String get backupsAndSync => 'Copias y sincronización';

  @override
  String get secureLocalBackup => 'Copia local segura';

  @override
  String get secureBackupDescription =>
      'Exporta tus colecciones e historial a un archivo cifrado. Compártelo en Drive, email u otros dispositivos.';

  @override
  String get actions => 'ACCIONES';

  @override
  String get exportBackup => 'Exportar copia';

  @override
  String get exportBackupSubtitle => 'Crea un archivo .xolo cifrado.';

  @override
  String get importBackup => 'Importar copia';

  @override
  String get importBackupSubtitle => 'Restaura desde un archivo .xolo.';

  @override
  String get cloudSyncComingSoon =>
      'Sincronización en la nube próximamente en v1.0';

  @override
  String get createBackupPassword => 'Crear contraseña de copia';

  @override
  String get createBackupPasswordDescription =>
      'Esta contraseña será necesaria para restaurar el archivo.';

  @override
  String get generatingBackup => 'Generando copia...';

  @override
  String get backupCreated => '¡Copia creada!';

  @override
  String get myXoloApiBackup => 'Mi copia de Xolo API';

  @override
  String get confirmSecureExport => 'Confirmar exportación segura';

  @override
  String get confirmSecureExportMessage =>
      'Tu perfil requiere confirmación explícita antes de exportar datos. ¿Continuar?';

  @override
  String get continueAction => 'Continuar';

  @override
  String get enterDecryptionPassword => 'Introduce la contraseña de descifrado';

  @override
  String get enterDecryptionPasswordDescription =>
      'Introduce la contraseña usada para crear esta copia.';

  @override
  String get restoring => 'Restaurando...';

  @override
  String get restoreComplete => '¡Restauración completada!';

  @override
  String get restoreFailedInvalidPasswordOrFile =>
      'Restauración fallida: contraseña o archivo no válido';

  @override
  String get passwordHint => 'Contraseña';

  @override
  String get projects => 'Proyectos';

  @override
  String get history => 'Historial';

  @override
  String get compose => 'Componer';

  @override
  String get composer => 'Composer';

  @override
  String get explorer => 'Explorador';

  @override
  String get backup => 'Copia';

  @override
  String get sync => 'Sync';

  @override
  String get settings => 'Ajustes';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get add => 'Añadir';

  @override
  String get import => 'Importar';

  @override
  String get export => 'Exportar';

  @override
  String get clear => 'Limpiar';

  @override
  String get undo => 'Deshacer';

  @override
  String get tabParams => 'Parámetros';

  @override
  String get tabAuth => 'Auth';

  @override
  String get tabHeaders => 'Cabeceras';

  @override
  String get tabBody => 'Body';

  @override
  String get tabScripts => 'Scripts';

  @override
  String get tabResponse => 'Respuesta';

  @override
  String get showCode => 'Ver código';

  @override
  String errorMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get appTheme => 'Tema de la app';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get securityAndPrivacy => 'SEGURIDAD Y PRIVACIDAD';

  @override
  String get clearHistory => 'Limpiar historial';

  @override
  String get clearHistoryConfirmTitle => 'Limpiar historial';

  @override
  String get clearHistoryConfirmMessage =>
      '¿Seguro que quieres eliminar todo el historial de requests?';

  @override
  String get historyCleared => 'Historial limpiado';

  @override
  String get emergencyWipeTitle => '⚠️ BORRADO DE EMERGENCIA';

  @override
  String get emergencyWipeMessage =>
      'Esto eliminará permanentemente TODO el historial, claves seguras y datos locales.\n\nLa app se cerrará inmediatamente.';

  @override
  String get deleteEverything => 'ELIMINAR TODO';

  @override
  String get panicButton => 'BORRADO DE EMERGENCIA (BOTÓN PÁNICO)';

  @override
  String get clearHistoryTooltip => 'Limpiar historial (contexto actual)';

  @override
  String get noRecentHistory => 'No hay historial reciente';

  @override
  String get requestsWillAppearHere =>
      'Tus requests ejecutadas aparecerán aquí.';

  @override
  String historyEventsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eventos en este contexto',
      one: '1 evento en este contexto',
    );
    return '$_temp0';
  }

  @override
  String get clearHistoryDialogTitle => '¿Limpiar historial?';

  @override
  String get clearHistoryDialogMessage =>
      'Se eliminarán las entradas de este workspace.';

  @override
  String get entryDeleted => 'Entrada eliminada';

  @override
  String get requestLoadedInNewTab => 'Request cargado en nueva pestaña';

  @override
  String get authInheritFromParent => 'Heredar del padre';

  @override
  String get authNone => 'Sin autenticación';

  @override
  String get authBearerToken => 'Bearer Token';

  @override
  String get authBasicAuth => 'Basic Auth';

  @override
  String get authApiKey => 'API Key';

  @override
  String get authDigestAuth => 'Digest Auth';

  @override
  String get authOAuth1 => 'OAuth 1.0';

  @override
  String get authOAuth2 => 'OAuth 2.0';

  @override
  String get authAwsSignature => 'Firma AWS';

  @override
  String get create => 'Crear';

  @override
  String get name => 'Nombre';

  @override
  String get nameRequired => 'El nombre es obligatorio';

  @override
  String get descriptionOptional => 'Descripción (opcional)';

  @override
  String get method => 'Método';

  @override
  String get loading => 'Cargando...';

  @override
  String get active => 'Activo';

  @override
  String get activate => 'Activar';

  @override
  String get globals => 'Globales';

  @override
  String get saveRequestTooltip => 'Guardar request';

  @override
  String get importApiProject => 'Importar proyecto API';

  @override
  String get importCurl => 'Importar cURL';

  @override
  String get dailyDriverMode => 'Modo daily driver • Pruebas API enfocadas';

  @override
  String get cmdKShortcut => 'Cmd+K';

  @override
  String get noActiveTabs => 'No hay pestañas activas';

  @override
  String get projectLabel => 'PROYECTO';

  @override
  String get globalContext => 'Contexto global';

  @override
  String get errorGeneric => 'Error';

  @override
  String get switchWorkspace => 'Cambiar workspace';

  @override
  String get globalContextSubtitle => 'Variables e historial compartidos';

  @override
  String get noProjectsFound => 'No se encontraron proyectos.';

  @override
  String get switchEnvironmentTooltip => 'Cambiar entorno';

  @override
  String get environmentsAndVariables => 'Entornos y variables';

  @override
  String get globalVariables => 'Variables globales';

  @override
  String get globalVariablesSubtitle => 'Disponibles en todo este workspace';

  @override
  String get environmentOverridesSubtitle =>
      'Sobreescriben las variables globales';

  @override
  String get newEnvironment => 'Nuevo entorno';

  @override
  String get environmentNameHint => 'Nombre (ej: Dev)';

  @override
  String deleteEnvironmentTitle(String name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String get deleteEnvironmentMessage =>
      'Se borrará el entorno y sus variables.';

  @override
  String get noVariablesDefined =>
      'No hay variables definidas.\nAgrega \"baseUrl\", \"token\", etc.';

  @override
  String get addVariable => 'Agregar variable';

  @override
  String get newVariable => 'Nueva variable';

  @override
  String get editVariable => 'Editar variable';

  @override
  String variableUsageHint(String syntax) {
    return 'Solo escribe el nombre. Ej: \"host\".\nLuego úsalo como $syntax';
  }

  @override
  String get keyLabel => 'Clave';

  @override
  String get valueLabel => 'Valor';

  @override
  String searchInCollection(String name) {
    return 'Buscar en $name...';
  }

  @override
  String get newRequestTooltip => 'Nuevo request';

  @override
  String get newSubfolderTooltip => 'Nueva subcarpeta';

  @override
  String get foldersSection => 'CARPETAS';

  @override
  String get requestsSection => 'REQUESTS';

  @override
  String get noRequestsFound => 'No se encontraron requests';

  @override
  String get noRequestsHere => 'No hay requests aquí';

  @override
  String get newRequest => 'Nuevo request';

  @override
  String get requestCreated => 'Request creado';

  @override
  String get createRequest => 'Crear request';

  @override
  String get deleteCollectionMessage =>
      'Se eliminarán todos los requests contenidos.';

  @override
  String loadedRequest(String name) {
    return 'Cargado: $name';
  }

  @override
  String get selectProject => 'Seleccionar proyecto';

  @override
  String get allProjects => 'Todos los proyectos';

  @override
  String get activeWorkspace => 'Workspace activo';

  @override
  String get noProjectsYet => 'Aún no hay proyectos';

  @override
  String get createFirstProject => 'Crear primer proyecto';

  @override
  String projectNumber(int id) {
    return 'Proyecto #$id';
  }

  @override
  String get editProject => 'Editar proyecto';

  @override
  String get editProjectSettings => 'Editar ajustes del proyecto';

  @override
  String get emptyProject => 'Proyecto vacío';

  @override
  String get createFolder => 'Crear carpeta';

  @override
  String get editFolder => 'Editar carpeta';

  @override
  String get emptyFolder => 'Carpeta vacía';

  @override
  String errorLoadingRequests(String message) {
    return 'Error al cargar requests: $message';
  }

  @override
  String deleteNamedTitle(String name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String get deleteProjectMessage =>
      'Se eliminarán todas las carpetas y requests dentro.';

  @override
  String get deleteFolderMessage => 'Se eliminarán todos los elementos dentro.';

  @override
  String get myProjectsAndRequests => 'Mis proyectos y requests';

  @override
  String get newProjectTooltip => 'Nuevo proyecto';

  @override
  String get projectsWorkspacesSection => 'PROYECTOS / WORKSPACES';

  @override
  String get unclassifiedRoot => 'SIN CLASIFICAR (RAÍZ)';

  @override
  String get dragRequestsHere =>
      'Arrastra requests aquí para sacarlos de carpetas';

  @override
  String get createProjectHint =>
      'Crea un proyecto para aislar tus entornos y variables.';

  @override
  String get newProjectFolder => 'Nuevo proyecto / carpeta';

  @override
  String get deleteAll => 'Eliminar todo';

  @override
  String get deleteCollectionWithEnvironments =>
      'Se eliminarán todos los requests y entornos contenidos. Esta acción no se puede deshacer.';

  @override
  String get saveRequest => 'Guardar request';

  @override
  String get requestNameLabel => 'Nombre del request';

  @override
  String get requestNameHint => 'Ej: Get Users';

  @override
  String get folderProjectLabel => 'Carpeta / proyecto';

  @override
  String get unclassifiedRootOption => 'Sin clasificar (raíz)';

  @override
  String get requestSavedSuccess => 'Request guardado exitosamente';

  @override
  String requestMovedToRoot(String name) {
    return 'Request \"$name\" movido a raíz';
  }

  @override
  String get renameProject => 'Renombrar proyecto';

  @override
  String get renameFolder => 'Renombrar carpeta';

  @override
  String get newProject => 'Nuevo proyecto';

  @override
  String get newFolder => 'Nueva carpeta';

  @override
  String get authorization => 'Autorización';

  @override
  String get authType => 'Tipo de auth';

  @override
  String get inheritAuthDescription =>
      'Esta carpeta usará la autenticación configurada en su carpeta padre o proyecto.';

  @override
  String get noAuthDescription => 'No se usará autenticación.';

  @override
  String get addToLabel => 'Agregar a';

  @override
  String get header => 'Header';

  @override
  String get queryParams => 'Query params';

  @override
  String get configNotAvailable =>
      'Configuración no disponible para este tipo aún.';

  @override
  String get projectSaved => 'Proyecto guardado';

  @override
  String get folderSaved => 'Carpeta guardada';

  @override
  String get typeToSearch => 'Escribe para buscar...';

  @override
  String get paletteAction => 'Acción';

  @override
  String get switchWorkspaceAction => 'Cambiar workspace';

  @override
  String get paletteProject => 'Proyecto';

  @override
  String get paletteFolder => 'Carpeta';

  @override
  String get paletteEnvironment => 'Entorno';

  @override
  String get paletteRequest => 'Request';

  @override
  String get paletteHistory => 'Historial';

  @override
  String get noResultsFound => 'No se encontraron resultados';

  @override
  String get allRequests => 'Todos los requests';

  @override
  String get importCollection => 'Importar colección';

  @override
  String get activateWorkspace => 'Activar workspace';

  @override
  String get syncExport => 'Sync / exportar';

  @override
  String get collectionExported => 'Colección exportada correctamente';

  @override
  String exportError(String message) {
    return 'Error exportando: $message';
  }

  @override
  String get environments => 'Entornos';

  @override
  String get newItem => 'Nuevo elemento';

  @override
  String get edit => 'Editar';

  @override
  String get projectsSection => 'PROYECTOS';

  @override
  String requestMovedToCollection(String request, String collection) {
    return 'Request \"$request\" movido a \"$collection\"';
  }

  @override
  String projectMovedToCollection(String project, String collection) {
    return 'Proyecto \"$project\" movido dentro de \"$collection\"';
  }

  @override
  String get curlImportedSuccess => '¡cURL importado con éxito!';

  @override
  String get invalidCurlCommand =>
      'Comando cURL inválido o formato no soportado';

  @override
  String get pasteCurlHint => 'Pega tu comando cURL aquí...';

  @override
  String get importSuccess => '¡Importado con éxito!';

  @override
  String get importDescription =>
      'Importa OpenAPI/Swagger o Postman desde URL o archivo.';

  @override
  String get importSourceLabel => 'Fuente:';

  @override
  String get importFormatLabel => 'Formato:';

  @override
  String get importAutoDetect => 'Auto-detectar';

  @override
  String get importOpenApi => 'OpenAPI / Swagger';

  @override
  String get importPostman => 'Postman Collection';

  @override
  String get importUrlLabel => 'URL del JSON/YAML';

  @override
  String get importUrlHint => 'https://...';

  @override
  String get selectFile => 'Seleccionar archivo';

  @override
  String get importNow => 'Importar ahora';

  @override
  String get fileReadError => 'No se pudieron leer los bytes del archivo';

  @override
  String get sourceUrl => 'URL';

  @override
  String get sourceFile => 'Archivo';

  @override
  String get beautify => 'Formatear';

  @override
  String get minify => 'Minificar';

  @override
  String get generateFromSchema => 'Generar desde schema';

  @override
  String get bodyJsonHint => '\\\"key\\\": \\\"value\\\"';

  @override
  String get preRequestTab => 'Pre-request';

  @override
  String get postRequestTab => 'Post-request (Extraer)';

  @override
  String get preRequestDescription =>
      'Generar/sustituir variables antes de la petición';

  @override
  String get postRequestDescription => 'Extraer variables de la respuesta';

  @override
  String get test => 'Probar';

  @override
  String get variableNameHint => 'Nombre variable';

  @override
  String get jsonPathHint => 'JSONPath (ej. \$.data.id)';

  @override
  String get valueHint => 'Valor (ej. timestamp)';

  @override
  String get noResponseToTest => 'No hay respuesta disponible para probar.';

  @override
  String get testCompleted => 'Prueba completada';

  @override
  String get absoluteUrlError =>
      'Error: No uses rutas absolutas (http/https) aquí.';

  @override
  String get understood => 'Entendido';

  @override
  String get copyJson => 'Copiar JSON';

  @override
  String get jsonCopied => 'JSON copiado al portapapeles';

  @override
  String get codeCopied => 'Código copiado al portapapeles';

  @override
  String get biometricLockedTitle => 'Xolo bloqueado';

  @override
  String get biometricVaultSubtitle => 'Tu bóveda segura de APIs';

  @override
  String get unlock => 'Desbloquear';

  @override
  String get unlockReason => 'Desbloquea Xolo para continuar';

  @override
  String get getNewAccessToken => 'Obtener nuevo token de acceso';

  @override
  String get username => 'Usuario';

  @override
  String get password => 'Contraseña';

  @override
  String get bearerTokenHint => 'ej. eyJhbGciOiJIUzI1Ni...';

  @override
  String get apiKeyHint => 'ej. X-API-Key';

  @override
  String get projectNameHint => 'Mi proyecto API';

  @override
  String get oauthCompleteTokenUrl =>
      'Por favor completa Token URL y Client ID';

  @override
  String get oauthCompleteAuthUrl => 'Por favor completa Auth URL';

  @override
  String get oauthTokenSuccess => 'Token obtenido con éxito';

  @override
  String get oauthClientCredentials => 'Client Credentials';

  @override
  String get oauthPasswordGrant => 'Password';

  @override
  String get oauthAuthorizationCode => 'Authorization Code';

  @override
  String get oauthAuthUrlHint => 'https://example.com/oauth/authorize';

  @override
  String get oauthTokenUrlHint => 'https://example.com/oauth/token';

  @override
  String get obtainNewToken => 'Obtener nuevo token';

  @override
  String get biometricLock => 'Bloqueo biométrico';

  @override
  String get biometricLockSubtitle => 'Solicitar huella/cara al iniciar';

  @override
  String get biometricAuthFailed =>
      'No se pudo verificar tu identidad. Inténtalo de nuevo.';

  @override
  String get biometricUnavailable => 'No disponible en este dispositivo';

  @override
  String get verifyToEnableLock => 'Verifica para activar el bloqueo';

  @override
  String authError(String message) {
    return 'Error de auth: $message';
  }

  @override
  String get autoLockDelay => 'Retraso de auto-bloqueo';

  @override
  String get immediately => 'Inmediatamente';

  @override
  String get after30Seconds => 'Tras 30 segundos';

  @override
  String get after1Minute => 'Tras 1 minuto';

  @override
  String get after5Minutes => 'Tras 5 minutos';

  @override
  String get delayNow => 'Ahora';

  @override
  String delaySeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String delayMinutes(int minutes) {
    return '${minutes}m';
  }

  @override
  String delaySecondsFull(int seconds) {
    return '$seconds segundos';
  }

  @override
  String delayMinutesFull(int minutes) {
    return '$minutes minuto(s)';
  }

  @override
  String get incognitoMode => 'Modo incógnito';

  @override
  String get incognitoSubtitle => 'No guardar historial';

  @override
  String get dataOwnership => 'PROPIEDAD DE DATOS';

  @override
  String get dataStorage => 'DATOS Y ALMACENAMIENTO';

  @override
  String get yourDataStaysYours => 'Tus datos son tuyos';

  @override
  String get dataOwnershipDescription1 =>
      'Xolo almacena tus datos localmente en este dispositivo por defecto. Nada se sube a la nube salvo que exportes y compartas explícitamente un archivo de copia.';

  @override
  String get dataOwnershipDescription2 =>
      'Usa copias cifradas y perfiles de seguridad para controlar qué tan estricta es la app.';

  @override
  String get securityProfile => 'Perfil de seguridad';

  @override
  String securityProfileError(String message) {
    return 'Error de perfil de seguridad: $message';
  }

  @override
  String get profileStandard => 'Estándar';

  @override
  String get profileHardened => 'Reforzado';

  @override
  String get profileParanoid => 'Paranoico';

  @override
  String get profileStandardDesc => 'Equilibrio entre seguridad y usabilidad';

  @override
  String get profileHardenedDesc =>
      'Oculta secretos y política de bloqueo más estricta';

  @override
  String get profileParanoidDesc => 'Máxima protección con bloqueo inmediato';

  @override
  String themeWidgetError(String message) {
    return 'Error del widget de tema: $message';
  }

  @override
  String panicFailed(String message) {
    return 'Fallo del pánico: $message';
  }

  @override
  String get appVersion => 'Xolo API Client v0.9.5';

  @override
  String get collections => 'Colecciones';

  @override
  String get hostHint => 'host';

  @override
  String get invalidJson => 'JSON inválido';

  @override
  String get schemaGenerated => 'Datos generados desde el schema';

  @override
  String get schemaEmptyResult =>
      'El schema produjo un resultado nulo/vacío válido.';

  @override
  String get schemaParseFailed => 'Error al parsear el schema';

  @override
  String get noSchemaAvailable => 'No hay schema disponible para este request';

  @override
  String get codeSnippet => 'Fragmento de código';

  @override
  String get noResponse => 'Sin respuesta';

  @override
  String responseErrorPrefix(String message) {
    return 'Error:\n$message';
  }

  @override
  String get runCollection => 'Ejecutar colección';

  @override
  String get runningCollection => 'Ejecutando colección';

  @override
  String get runReport => 'Reporte de ejecución';

  @override
  String get runHistory => 'Historial de runs';

  @override
  String get noRunHistory => 'Aún no hay ejecuciones de colección';

  @override
  String get runNotFound => 'Ejecución no encontrada';

  @override
  String get stopOnFailure => 'Detener al fallar';

  @override
  String get delayBetweenSteps => 'Retraso entre pasos';

  @override
  String runningStep(int current, int total) {
    return 'Paso $current de $total';
  }

  @override
  String stepsPassed(int passed, int total) {
    return '$passed / $total aprobados';
  }

  @override
  String get runFailed => 'Fallidos';

  @override
  String get runSkipped => 'Omitidos';

  @override
  String get reRunFromFailure => 'Re-ejecutar desde el fallo';

  @override
  String reRunFromStep(int step) {
    return 'Re-ejecutar desde paso $step';
  }

  @override
  String get tabAssertions => 'Tests';

  @override
  String get addAssertion => 'Añadir assertion';

  @override
  String get assertionType => 'Tipo de assertion';

  @override
  String get assertionTarget => 'Objetivo (JSONPath)';

  @override
  String get assertionExpected => 'Valor esperado';

  @override
  String get cloudSync => 'Sync en la nube';

  @override
  String get cloudSyncDescription =>
      'Sincroniza copia cifrada con Google Drive (manual, bajo demanda).';

  @override
  String get signInGoogle => 'Iniciar sesión con Google';

  @override
  String get syncNow => 'Sincronizar ahora';

  @override
  String lastSynced(String date) {
    return 'Última sync: $date';
  }

  @override
  String signedInAs(String email) {
    return 'Sesión: $email';
  }

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get syncSuccess => 'Sincronización completada';

  @override
  String get syncFailed => 'Error de sincronización';
}
