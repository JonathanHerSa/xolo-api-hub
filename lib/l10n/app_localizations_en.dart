// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Xolo API Client';

  @override
  String get backupsAndSync => 'Backups & Sync';

  @override
  String get secureLocalBackup => 'Secure Local Backup';

  @override
  String get secureBackupDescription =>
      'Export your collections and history to a secure, encrypted file. Share it to your Drive, Email, or other devices.';

  @override
  String get actions => 'ACTIONS';

  @override
  String get exportBackup => 'Export Backup';

  @override
  String get exportBackupSubtitle => 'Create an encrypted .xolo file.';

  @override
  String get importBackup => 'Import Backup';

  @override
  String get importBackupSubtitle => 'Restore from a .xolo file.';

  @override
  String get cloudSyncComingSoon => 'Cloud Sync coming in v1.0';

  @override
  String get createBackupPassword => 'Create Backup Password';

  @override
  String get createBackupPasswordDescription =>
      'This password will be required to restore the file.';

  @override
  String get generatingBackup => 'Generating Backup...';

  @override
  String get backupCreated => 'Backup Created!';

  @override
  String get myXoloApiBackup => 'My Xolo API Backup';

  @override
  String get confirmSecureExport => 'Confirm Secure Export';

  @override
  String get confirmSecureExportMessage =>
      'Your profile requires explicit confirmation before exporting data. Continue?';

  @override
  String get continueAction => 'Continue';

  @override
  String get enterDecryptionPassword => 'Enter Decryption Password';

  @override
  String get enterDecryptionPasswordDescription =>
      'Enter the password used to create this backup.';

  @override
  String get restoring => 'Restoring...';

  @override
  String get restoreComplete => 'Restore Complete!';

  @override
  String get restoreFailedInvalidPasswordOrFile =>
      'Restore Failed: Invalid Password or File';

  @override
  String get passwordHint => 'Password';

  @override
  String get projects => 'Projects';

  @override
  String get history => 'History';

  @override
  String get compose => 'Compose';

  @override
  String get composer => 'Composer';

  @override
  String get explorer => 'Explorer';

  @override
  String get backup => 'Backup';

  @override
  String get sync => 'Sync';

  @override
  String get settings => 'Settings';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get add => 'Add';

  @override
  String get import => 'Import';

  @override
  String get export => 'Export';

  @override
  String get clear => 'Clear';

  @override
  String get undo => 'Undo';

  @override
  String get tabParams => 'Params';

  @override
  String get tabAuth => 'Auth';

  @override
  String get tabHeaders => 'Headers';

  @override
  String get tabBody => 'Body';

  @override
  String get tabScripts => 'Scripts';

  @override
  String get tabResponse => 'Response';

  @override
  String get showCode => 'Show Code';

  @override
  String errorMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get appTheme => 'App Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get securityAndPrivacy => 'SECURITY & PRIVACY';

  @override
  String get clearHistory => 'Clear History';

  @override
  String get clearHistoryConfirmTitle => 'Clear History';

  @override
  String get clearHistoryConfirmMessage =>
      'Are you sure you want to delete all request history?';

  @override
  String get historyCleared => 'History cleared';

  @override
  String get emergencyWipeTitle => '⚠️ EMERGENCY WIPE';

  @override
  String get emergencyWipeMessage =>
      'This will permanently delete ALL history, secure keys, and local data.\n\nThe app will close immediately.';

  @override
  String get deleteEverything => 'DELETE EVERYTHING';

  @override
  String get panicButton => 'EMERGENCY WIPE (PANIC BUTTON)';

  @override
  String get clearHistoryTooltip => 'Clear history (current context)';

  @override
  String get noRecentHistory => 'No recent history';

  @override
  String get requestsWillAppearHere =>
      'Your executed requests will appear here.';

  @override
  String historyEventsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count events in this context',
      one: '1 event in this context',
    );
    return '$_temp0';
  }

  @override
  String get clearHistoryDialogTitle => 'Clear History?';

  @override
  String get clearHistoryDialogMessage =>
      'Entries from this workspace will be deleted.';

  @override
  String get entryDeleted => 'Entry deleted';

  @override
  String get requestLoadedInNewTab => 'Request loaded in a new tab';

  @override
  String get authInheritFromParent => 'Inherit from Parent';

  @override
  String get authNone => 'No Auth';

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
  String get authAwsSignature => 'AWS Signature';

  @override
  String get create => 'Create';

  @override
  String get name => 'Name';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get descriptionOptional => 'Description (Optional)';

  @override
  String get method => 'Method';

  @override
  String get loading => 'Loading...';

  @override
  String get active => 'Active';

  @override
  String get activate => 'Activate';

  @override
  String get globals => 'Global';

  @override
  String get saveRequestTooltip => 'Save Request';

  @override
  String get importApiProject => 'Import API Project';

  @override
  String get importCurl => 'Import cURL';

  @override
  String get dailyDriverMode => 'Daily driver mode • Focused API testing';

  @override
  String get cmdKShortcut => 'Cmd+K';

  @override
  String get noActiveTabs => 'No active tabs';

  @override
  String get projectLabel => 'PROJECT';

  @override
  String get globalContext => 'Global Context';

  @override
  String get errorGeneric => 'Error';

  @override
  String get switchWorkspace => 'Switch Workspace';

  @override
  String get globalContextSubtitle => 'Shared variables & history';

  @override
  String get noProjectsFound => 'No projects found.';

  @override
  String get switchEnvironmentTooltip => 'Switch Environment';

  @override
  String get environmentsAndVariables => 'Environments & Variables';

  @override
  String get globalVariables => 'Global Variables';

  @override
  String get globalVariablesSubtitle => 'Available across this workspace';

  @override
  String get environmentOverridesSubtitle => 'Override global variables';

  @override
  String get newEnvironment => 'New Environment';

  @override
  String get environmentNameHint => 'Name (e.g. Dev)';

  @override
  String deleteEnvironmentTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get deleteEnvironmentMessage =>
      'The environment and its variables will be deleted.';

  @override
  String get noVariablesDefined =>
      'No variables defined.\nAdd \"baseUrl\", \"token\", etc.';

  @override
  String get addVariable => 'Add Variable';

  @override
  String get newVariable => 'New Variable';

  @override
  String get editVariable => 'Edit Variable';

  @override
  String variableUsageHint(String syntax) {
    return 'Just write the name. E.g. \"host\".\nThen use it as $syntax';
  }

  @override
  String get keyLabel => 'Key';

  @override
  String get valueLabel => 'Value';

  @override
  String searchInCollection(String name) {
    return 'Search in $name...';
  }

  @override
  String get newRequestTooltip => 'New Request';

  @override
  String get newSubfolderTooltip => 'New Subfolder';

  @override
  String get foldersSection => 'FOLDERS';

  @override
  String get requestsSection => 'REQUESTS';

  @override
  String get noRequestsFound => 'No requests found';

  @override
  String get noRequestsHere => 'No requests here';

  @override
  String get newRequest => 'New Request';

  @override
  String get requestCreated => 'Request created';

  @override
  String get createRequest => 'Create Request';

  @override
  String get deleteCollectionMessage =>
      'All contained requests will be deleted.';

  @override
  String loadedRequest(String name) {
    return 'Loaded: $name';
  }

  @override
  String get selectProject => 'Select Project';

  @override
  String get allProjects => 'All Projects';

  @override
  String get activeWorkspace => 'Active Workspace';

  @override
  String get noProjectsYet => 'No Projects Yet';

  @override
  String get createFirstProject => 'Create First Project';

  @override
  String projectNumber(int id) {
    return 'Project #$id';
  }

  @override
  String get editProject => 'Edit Project';

  @override
  String get editProjectSettings => 'Edit Project Settings';

  @override
  String get emptyProject => 'Empty Project';

  @override
  String get createFolder => 'Create Folder';

  @override
  String get editFolder => 'Edit Folder';

  @override
  String get emptyFolder => 'Empty Folder';

  @override
  String errorLoadingRequests(String message) {
    return 'Error loading requests: $message';
  }

  @override
  String deleteNamedTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get deleteProjectMessage =>
      'This will delete all folders and requests inside.';

  @override
  String get deleteFolderMessage => 'This will delete all items inside.';

  @override
  String get myProjectsAndRequests => 'My Projects & Requests';

  @override
  String get newProjectTooltip => 'New Project';

  @override
  String get projectsWorkspacesSection => 'PROJECTS / WORKSPACES';

  @override
  String get unclassifiedRoot => 'UNCLASSIFIED (ROOT)';

  @override
  String get dragRequestsHere =>
      'Drag requests here to remove them from folders';

  @override
  String get createProjectHint =>
      'Create a project to isolate your environments and variables.';

  @override
  String get newProjectFolder => 'New Project / Folder';

  @override
  String get deleteAll => 'Delete All';

  @override
  String get deleteCollectionWithEnvironments =>
      'All requests and environments will be deleted. This cannot be undone.';

  @override
  String get saveRequest => 'Save Request';

  @override
  String get requestNameLabel => 'Request Name';

  @override
  String get requestNameHint => 'E.g. Get Users';

  @override
  String get folderProjectLabel => 'Folder / Project';

  @override
  String get unclassifiedRootOption => 'Unclassified (Root)';

  @override
  String get requestSavedSuccess => 'Request saved successfully';

  @override
  String requestMovedToRoot(String name) {
    return 'Request \"$name\" moved to root';
  }

  @override
  String get renameProject => 'Rename Project';

  @override
  String get renameFolder => 'Rename Folder';

  @override
  String get newProject => 'New Project';

  @override
  String get newFolder => 'New Folder';

  @override
  String get authorization => 'Authorization';

  @override
  String get authType => 'Auth Type';

  @override
  String get inheritAuthDescription =>
      'This folder will use the authentication configured in its parent folder or project.';

  @override
  String get noAuthDescription => 'No authentication will be used.';

  @override
  String get addToLabel => 'Add to';

  @override
  String get header => 'Header';

  @override
  String get queryParams => 'Query Params';

  @override
  String get configNotAvailable =>
      'Configuration not available for this type yet.';

  @override
  String get projectSaved => 'Project saved';

  @override
  String get folderSaved => 'Folder saved';

  @override
  String get typeToSearch => 'Type to search...';

  @override
  String get paletteAction => 'Action';

  @override
  String get switchWorkspaceAction => 'Switch Workspace';

  @override
  String get paletteProject => 'Project';

  @override
  String get paletteFolder => 'Folder';

  @override
  String get paletteEnvironment => 'Environment';

  @override
  String get paletteRequest => 'Request';

  @override
  String get paletteHistory => 'History';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get allRequests => 'All Requests';

  @override
  String get importCollection => 'Import Collection';

  @override
  String get activateWorkspace => 'Activate Workspace';

  @override
  String get syncExport => 'Sync / Export';

  @override
  String get collectionExported => 'Collection exported successfully';

  @override
  String exportError(String message) {
    return 'Export error: $message';
  }

  @override
  String get environments => 'Environments';

  @override
  String get newItem => 'New Item';

  @override
  String get edit => 'Edit';

  @override
  String get projectsSection => 'PROJECTS';

  @override
  String requestMovedToCollection(String request, String collection) {
    return 'Request \"$request\" moved to \"$collection\"';
  }

  @override
  String projectMovedToCollection(String project, String collection) {
    return 'Project \"$project\" moved into \"$collection\"';
  }

  @override
  String get curlImportedSuccess => 'cURL imported successfully!';

  @override
  String get invalidCurlCommand =>
      'Invalid cURL command or format not supported';

  @override
  String get pasteCurlHint => 'Paste your cURL command here...';

  @override
  String get importSuccess => 'Imported successfully!';

  @override
  String get importDescription =>
      'Import OpenAPI/Swagger or Postman from URL or file.';

  @override
  String get importSourceLabel => 'Source:';

  @override
  String get importFormatLabel => 'Format:';

  @override
  String get importAutoDetect => 'Auto-detect';

  @override
  String get importOpenApi => 'OpenAPI / Swagger';

  @override
  String get importPostman => 'Postman Collection';

  @override
  String get importUrlLabel => 'JSON/YAML URL';

  @override
  String get importUrlHint => 'https://...';

  @override
  String get selectFile => 'Select File';

  @override
  String get importNow => 'Import Now';

  @override
  String get fileReadError => 'Could not read file bytes';

  @override
  String get sourceUrl => 'URL';

  @override
  String get sourceFile => 'File';

  @override
  String get beautify => 'Beautify';

  @override
  String get minify => 'Minify';

  @override
  String get generateFromSchema => 'Generate from Schema';

  @override
  String get bodyJsonHint => '\\\"key\\\": \\\"value\\\"';

  @override
  String get preRequestTab => 'Pre-request';

  @override
  String get postRequestTab => 'Post-request (Extract)';

  @override
  String get preRequestDescription =>
      'Generate/replace variables before the request';

  @override
  String get postRequestDescription => 'Extract variables from the response';

  @override
  String get test => 'Test';

  @override
  String get variableNameHint => 'Variable Name';

  @override
  String get jsonPathHint => 'JSONPath (e.g. \$.data.id)';

  @override
  String get valueHint => 'Value (e.g. timestamp)';

  @override
  String get noResponseToTest => 'No response available to test.';

  @override
  String get testCompleted => 'Test completed';

  @override
  String get absoluteUrlError =>
      'Error: Do not use absolute paths (http/https) here.';

  @override
  String get understood => 'Got it';

  @override
  String get copyJson => 'Copy JSON';

  @override
  String get jsonCopied => 'JSON copied to clipboard';

  @override
  String get codeCopied => 'Code copied to clipboard';

  @override
  String get biometricLockedTitle => 'Xolo Locked';

  @override
  String get biometricVaultSubtitle => 'Your secure API vault';

  @override
  String get unlock => 'Unlock';

  @override
  String get unlockReason => 'Unlock Xolo to continue';

  @override
  String get getNewAccessToken => 'Get New Access Token';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get bearerTokenHint => 'e.g. eyJhbGciOiJIUzI1Ni...';

  @override
  String get apiKeyHint => 'e.g. X-API-Key';

  @override
  String get projectNameHint => 'My API Project';

  @override
  String get oauthCompleteTokenUrl => 'Please complete Token URL and Client ID';

  @override
  String get oauthCompleteAuthUrl => 'Please complete Auth URL';

  @override
  String get oauthTokenSuccess => 'Token obtained successfully';

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
  String get obtainNewToken => 'Obtain new token';

  @override
  String get biometricLock => 'Biometric Lock';

  @override
  String get biometricLockSubtitle => 'Require FaceID/Fingerprint to open';

  @override
  String get biometricAuthFailed =>
      'Could not verify your identity. Try again.';

  @override
  String get biometricUnavailable => 'Not available on this device';

  @override
  String get verifyToEnableLock => 'Verify to enable lock';

  @override
  String authError(String message) {
    return 'Auth Error: $message';
  }

  @override
  String get autoLockDelay => 'Auto-Lock Delay';

  @override
  String get immediately => 'Immediately';

  @override
  String get after30Seconds => 'After 30 seconds';

  @override
  String get after1Minute => 'After 1 minute';

  @override
  String get after5Minutes => 'After 5 minutes';

  @override
  String get delayNow => 'Now';

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
    return '$seconds seconds';
  }

  @override
  String delayMinutesFull(int minutes) {
    return '$minutes minute(s)';
  }

  @override
  String get incognitoMode => 'Incognito Mode';

  @override
  String get incognitoSubtitle => 'Do not save history';

  @override
  String get dataOwnership => 'DATA OWNERSHIP';

  @override
  String get dataStorage => 'DATA & STORAGE';

  @override
  String get yourDataStaysYours => 'Your data stays yours';

  @override
  String get dataOwnershipDescription1 =>
      'Xolo stores your data locally on this device by default. Nothing is uploaded unless you explicitly export and share a backup file.';

  @override
  String get dataOwnershipDescription2 =>
      'Use encrypted backups and security profiles to control how strict the app behaves.';

  @override
  String get securityProfile => 'Security Profile';

  @override
  String securityProfileError(String message) {
    return 'Security profile error: $message';
  }

  @override
  String get profileStandard => 'Standard';

  @override
  String get profileHardened => 'Hardened';

  @override
  String get profileParanoid => 'Paranoid';

  @override
  String get profileStandardDesc => 'Balanced security and usability';

  @override
  String get profileHardenedDesc => 'Hide secrets and tighter lock policy';

  @override
  String get profileParanoidDesc => 'Maximum protection with immediate lock';

  @override
  String themeWidgetError(String message) {
    return 'Theme Widget Error: $message';
  }

  @override
  String panicFailed(String message) {
    return 'Panic Failed: $message';
  }

  @override
  String get appVersion => 'Xolo API Client v0.9.5';

  @override
  String get collections => 'Collections';

  @override
  String get hostHint => 'host';

  @override
  String get invalidJson => 'Invalid JSON';

  @override
  String get schemaGenerated => 'Data generated from Schema';

  @override
  String get schemaEmptyResult => 'Schema produced valid null/empty result.';

  @override
  String get schemaParseFailed => 'Failed to parse Schema';

  @override
  String get noSchemaAvailable => 'No Schema available for this request';

  @override
  String get codeSnippet => 'Code Snippet';

  @override
  String get noResponse => 'No response';

  @override
  String responseErrorPrefix(String message) {
    return 'Error:\n$message';
  }

  @override
  String get runCollection => 'Run Collection';

  @override
  String get runningCollection => 'Running Collection';

  @override
  String get runReport => 'Run Report';

  @override
  String get runHistory => 'Run History';

  @override
  String get noRunHistory => 'No collection runs yet';

  @override
  String get runNotFound => 'Run not found';

  @override
  String get stopOnFailure => 'Stop on failure';

  @override
  String get delayBetweenSteps => 'Delay between steps';

  @override
  String runningStep(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String stepsPassed(int passed, int total) {
    return '$passed / $total passed';
  }

  @override
  String get runFailed => 'Failed';

  @override
  String get runSkipped => 'Skipped';

  @override
  String get reRunFromFailure => 'Re-run from failure';

  @override
  String reRunFromStep(int step) {
    return 'Re-run from step $step';
  }

  @override
  String get tabAssertions => 'Tests';

  @override
  String get addAssertion => 'Add assertion';

  @override
  String get assertionType => 'Assertion type';

  @override
  String get assertionTarget => 'Target (JSONPath)';

  @override
  String get assertionExpected => 'Expected value';

  @override
  String get cloudSync => 'Cloud Sync';

  @override
  String get cloudSyncDescription =>
      'Sync encrypted backup with Google Drive (manual, on-demand).';

  @override
  String get signInGoogle => 'Sign in with Google';

  @override
  String get syncNow => 'Sync now';

  @override
  String lastSynced(String date) {
    return 'Last synced: $date';
  }

  @override
  String signedInAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String get signOut => 'Sign out';

  @override
  String get syncSuccess => 'Sync completed';

  @override
  String get syncFailed => 'Sync failed';
}
