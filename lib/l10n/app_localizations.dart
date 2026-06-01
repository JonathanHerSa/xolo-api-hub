import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Xolo API Client'**
  String get appTitle;

  /// No description provided for @backupsAndSync.
  ///
  /// In en, this message translates to:
  /// **'Backups & Sync'**
  String get backupsAndSync;

  /// No description provided for @secureLocalBackup.
  ///
  /// In en, this message translates to:
  /// **'Secure Local Backup'**
  String get secureLocalBackup;

  /// No description provided for @secureBackupDescription.
  ///
  /// In en, this message translates to:
  /// **'Export your collections and history to a secure, encrypted file. Share it to your Drive, Email, or other devices.'**
  String get secureBackupDescription;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'ACTIONS'**
  String get actions;

  /// No description provided for @exportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export Backup'**
  String get exportBackup;

  /// No description provided for @exportBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create an encrypted .xolo file.'**
  String get exportBackupSubtitle;

  /// No description provided for @importBackup.
  ///
  /// In en, this message translates to:
  /// **'Import Backup'**
  String get importBackup;

  /// No description provided for @importBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restore from a .xolo file.'**
  String get importBackupSubtitle;

  /// No description provided for @cloudSyncComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Cloud Sync coming in v1.0'**
  String get cloudSyncComingSoon;

  /// No description provided for @createBackupPassword.
  ///
  /// In en, this message translates to:
  /// **'Create Backup Password'**
  String get createBackupPassword;

  /// No description provided for @createBackupPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'This password will be required to restore the file.'**
  String get createBackupPasswordDescription;

  /// No description provided for @generatingBackup.
  ///
  /// In en, this message translates to:
  /// **'Generating Backup...'**
  String get generatingBackup;

  /// No description provided for @backupCreated.
  ///
  /// In en, this message translates to:
  /// **'Backup Created!'**
  String get backupCreated;

  /// No description provided for @myXoloApiBackup.
  ///
  /// In en, this message translates to:
  /// **'My Xolo API Backup'**
  String get myXoloApiBackup;

  /// No description provided for @confirmSecureExport.
  ///
  /// In en, this message translates to:
  /// **'Confirm Secure Export'**
  String get confirmSecureExport;

  /// No description provided for @confirmSecureExportMessage.
  ///
  /// In en, this message translates to:
  /// **'Your profile requires explicit confirmation before exporting data. Continue?'**
  String get confirmSecureExportMessage;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @enterDecryptionPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter Decryption Password'**
  String get enterDecryptionPassword;

  /// No description provided for @enterDecryptionPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the password used to create this backup.'**
  String get enterDecryptionPasswordDescription;

  /// No description provided for @restoring.
  ///
  /// In en, this message translates to:
  /// **'Restoring...'**
  String get restoring;

  /// No description provided for @restoreComplete.
  ///
  /// In en, this message translates to:
  /// **'Restore Complete!'**
  String get restoreComplete;

  /// No description provided for @restoreFailedInvalidPasswordOrFile.
  ///
  /// In en, this message translates to:
  /// **'Restore Failed: Invalid Password or File'**
  String get restoreFailedInvalidPasswordOrFile;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// No description provided for @projects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projects;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @compose.
  ///
  /// In en, this message translates to:
  /// **'Compose'**
  String get compose;

  /// No description provided for @composer.
  ///
  /// In en, this message translates to:
  /// **'Composer'**
  String get composer;

  /// No description provided for @explorer.
  ///
  /// In en, this message translates to:
  /// **'Explorer'**
  String get explorer;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// No description provided for @sync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get sync;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @tabParams.
  ///
  /// In en, this message translates to:
  /// **'Params'**
  String get tabParams;

  /// No description provided for @tabAuth.
  ///
  /// In en, this message translates to:
  /// **'Auth'**
  String get tabAuth;

  /// No description provided for @tabHeaders.
  ///
  /// In en, this message translates to:
  /// **'Headers'**
  String get tabHeaders;

  /// No description provided for @tabBody.
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get tabBody;

  /// No description provided for @tabScripts.
  ///
  /// In en, this message translates to:
  /// **'Scripts'**
  String get tabScripts;

  /// No description provided for @tabResponse.
  ///
  /// In en, this message translates to:
  /// **'Response'**
  String get tabResponse;

  /// No description provided for @showCode.
  ///
  /// In en, this message translates to:
  /// **'Show Code'**
  String get showCode;

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorMessage(String message);

  /// No description provided for @appTheme.
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get appTheme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @securityAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'SECURITY & PRIVACY'**
  String get securityAndPrivacy;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistory;

  /// No description provided for @clearHistoryConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistoryConfirmTitle;

  /// No description provided for @clearHistoryConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all request history?'**
  String get clearHistoryConfirmMessage;

  /// No description provided for @historyCleared.
  ///
  /// In en, this message translates to:
  /// **'History cleared'**
  String get historyCleared;

  /// No description provided for @emergencyWipeTitle.
  ///
  /// In en, this message translates to:
  /// **'⚠️ EMERGENCY WIPE'**
  String get emergencyWipeTitle;

  /// No description provided for @emergencyWipeMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete ALL history, secure keys, and local data.\n\nThe app will close immediately.'**
  String get emergencyWipeMessage;

  /// No description provided for @deleteEverything.
  ///
  /// In en, this message translates to:
  /// **'DELETE EVERYTHING'**
  String get deleteEverything;

  /// No description provided for @panicButton.
  ///
  /// In en, this message translates to:
  /// **'EMERGENCY WIPE (PANIC BUTTON)'**
  String get panicButton;

  /// No description provided for @clearHistoryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear history (current context)'**
  String get clearHistoryTooltip;

  /// No description provided for @noRecentHistory.
  ///
  /// In en, this message translates to:
  /// **'No recent history'**
  String get noRecentHistory;

  /// No description provided for @requestsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your executed requests will appear here.'**
  String get requestsWillAppearHere;

  /// No description provided for @historyEventsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 event in this context} other{{count} events in this context}}'**
  String historyEventsCount(int count);

  /// No description provided for @clearHistoryDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear History?'**
  String get clearHistoryDialogTitle;

  /// No description provided for @clearHistoryDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Entries from this workspace will be deleted.'**
  String get clearHistoryDialogMessage;

  /// No description provided for @entryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Entry deleted'**
  String get entryDeleted;

  /// No description provided for @requestLoadedInNewTab.
  ///
  /// In en, this message translates to:
  /// **'Request loaded in a new tab'**
  String get requestLoadedInNewTab;

  /// No description provided for @authInheritFromParent.
  ///
  /// In en, this message translates to:
  /// **'Inherit from Parent'**
  String get authInheritFromParent;

  /// No description provided for @authNone.
  ///
  /// In en, this message translates to:
  /// **'No Auth'**
  String get authNone;

  /// No description provided for @authBearerToken.
  ///
  /// In en, this message translates to:
  /// **'Bearer Token'**
  String get authBearerToken;

  /// No description provided for @authBasicAuth.
  ///
  /// In en, this message translates to:
  /// **'Basic Auth'**
  String get authBasicAuth;

  /// No description provided for @authApiKey.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get authApiKey;

  /// No description provided for @authDigestAuth.
  ///
  /// In en, this message translates to:
  /// **'Digest Auth'**
  String get authDigestAuth;

  /// No description provided for @authOAuth1.
  ///
  /// In en, this message translates to:
  /// **'OAuth 1.0'**
  String get authOAuth1;

  /// No description provided for @authOAuth2.
  ///
  /// In en, this message translates to:
  /// **'OAuth 2.0'**
  String get authOAuth2;

  /// No description provided for @authAwsSignature.
  ///
  /// In en, this message translates to:
  /// **'AWS Signature'**
  String get authAwsSignature;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionOptional;

  /// No description provided for @method.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get method;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @activate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activate;

  /// No description provided for @globals.
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get globals;

  /// No description provided for @saveRequestTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save Request'**
  String get saveRequestTooltip;

  /// No description provided for @importApiProject.
  ///
  /// In en, this message translates to:
  /// **'Import API Project'**
  String get importApiProject;

  /// No description provided for @importCurl.
  ///
  /// In en, this message translates to:
  /// **'Import cURL'**
  String get importCurl;

  /// No description provided for @dailyDriverMode.
  ///
  /// In en, this message translates to:
  /// **'Daily driver mode • Focused API testing'**
  String get dailyDriverMode;

  /// No description provided for @cmdKShortcut.
  ///
  /// In en, this message translates to:
  /// **'Cmd+K'**
  String get cmdKShortcut;

  /// No description provided for @noActiveTabs.
  ///
  /// In en, this message translates to:
  /// **'No active tabs'**
  String get noActiveTabs;

  /// No description provided for @projectLabel.
  ///
  /// In en, this message translates to:
  /// **'PROJECT'**
  String get projectLabel;

  /// No description provided for @globalContext.
  ///
  /// In en, this message translates to:
  /// **'Global Context'**
  String get globalContext;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorGeneric;

  /// No description provided for @switchWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Switch Workspace'**
  String get switchWorkspace;

  /// No description provided for @globalContextSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shared variables & history'**
  String get globalContextSubtitle;

  /// No description provided for @noProjectsFound.
  ///
  /// In en, this message translates to:
  /// **'No projects found.'**
  String get noProjectsFound;

  /// No description provided for @switchEnvironmentTooltip.
  ///
  /// In en, this message translates to:
  /// **'Switch Environment'**
  String get switchEnvironmentTooltip;

  /// No description provided for @environmentsAndVariables.
  ///
  /// In en, this message translates to:
  /// **'Environments & Variables'**
  String get environmentsAndVariables;

  /// No description provided for @globalVariables.
  ///
  /// In en, this message translates to:
  /// **'Global Variables'**
  String get globalVariables;

  /// No description provided for @globalVariablesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Available across this workspace'**
  String get globalVariablesSubtitle;

  /// No description provided for @environmentOverridesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Override global variables'**
  String get environmentOverridesSubtitle;

  /// No description provided for @newEnvironment.
  ///
  /// In en, this message translates to:
  /// **'New Environment'**
  String get newEnvironment;

  /// No description provided for @environmentNameHint.
  ///
  /// In en, this message translates to:
  /// **'Name (e.g. Dev)'**
  String get environmentNameHint;

  /// No description provided for @deleteEnvironmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String deleteEnvironmentTitle(String name);

  /// No description provided for @deleteEnvironmentMessage.
  ///
  /// In en, this message translates to:
  /// **'The environment and its variables will be deleted.'**
  String get deleteEnvironmentMessage;

  /// No description provided for @noVariablesDefined.
  ///
  /// In en, this message translates to:
  /// **'No variables defined.\nAdd \"baseUrl\", \"token\", etc.'**
  String get noVariablesDefined;

  /// No description provided for @addVariable.
  ///
  /// In en, this message translates to:
  /// **'Add Variable'**
  String get addVariable;

  /// No description provided for @newVariable.
  ///
  /// In en, this message translates to:
  /// **'New Variable'**
  String get newVariable;

  /// No description provided for @editVariable.
  ///
  /// In en, this message translates to:
  /// **'Edit Variable'**
  String get editVariable;

  /// No description provided for @variableUsageHint.
  ///
  /// In en, this message translates to:
  /// **'Just write the name. E.g. \"host\".\nThen use it as {syntax}'**
  String variableUsageHint(String syntax);

  /// No description provided for @keyLabel.
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get keyLabel;

  /// No description provided for @valueLabel.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get valueLabel;

  /// No description provided for @searchInCollection.
  ///
  /// In en, this message translates to:
  /// **'Search in {name}...'**
  String searchInCollection(String name);

  /// No description provided for @newRequestTooltip.
  ///
  /// In en, this message translates to:
  /// **'New Request'**
  String get newRequestTooltip;

  /// No description provided for @newSubfolderTooltip.
  ///
  /// In en, this message translates to:
  /// **'New Subfolder'**
  String get newSubfolderTooltip;

  /// No description provided for @foldersSection.
  ///
  /// In en, this message translates to:
  /// **'FOLDERS'**
  String get foldersSection;

  /// No description provided for @requestsSection.
  ///
  /// In en, this message translates to:
  /// **'REQUESTS'**
  String get requestsSection;

  /// No description provided for @noRequestsFound.
  ///
  /// In en, this message translates to:
  /// **'No requests found'**
  String get noRequestsFound;

  /// No description provided for @noRequestsHere.
  ///
  /// In en, this message translates to:
  /// **'No requests here'**
  String get noRequestsHere;

  /// No description provided for @newRequest.
  ///
  /// In en, this message translates to:
  /// **'New Request'**
  String get newRequest;

  /// No description provided for @requestCreated.
  ///
  /// In en, this message translates to:
  /// **'Request created'**
  String get requestCreated;

  /// No description provided for @createRequest.
  ///
  /// In en, this message translates to:
  /// **'Create Request'**
  String get createRequest;

  /// No description provided for @deleteCollectionMessage.
  ///
  /// In en, this message translates to:
  /// **'All contained requests will be deleted.'**
  String get deleteCollectionMessage;

  /// No description provided for @loadedRequest.
  ///
  /// In en, this message translates to:
  /// **'Loaded: {name}'**
  String loadedRequest(String name);

  /// No description provided for @selectProject.
  ///
  /// In en, this message translates to:
  /// **'Select Project'**
  String get selectProject;

  /// No description provided for @allProjects.
  ///
  /// In en, this message translates to:
  /// **'All Projects'**
  String get allProjects;

  /// No description provided for @activeWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Active Workspace'**
  String get activeWorkspace;

  /// No description provided for @noProjectsYet.
  ///
  /// In en, this message translates to:
  /// **'No Projects Yet'**
  String get noProjectsYet;

  /// No description provided for @createFirstProject.
  ///
  /// In en, this message translates to:
  /// **'Create First Project'**
  String get createFirstProject;

  /// No description provided for @projectNumber.
  ///
  /// In en, this message translates to:
  /// **'Project #{id}'**
  String projectNumber(int id);

  /// No description provided for @editProject.
  ///
  /// In en, this message translates to:
  /// **'Edit Project'**
  String get editProject;

  /// No description provided for @editProjectSettings.
  ///
  /// In en, this message translates to:
  /// **'Edit Project Settings'**
  String get editProjectSettings;

  /// No description provided for @emptyProject.
  ///
  /// In en, this message translates to:
  /// **'Empty Project'**
  String get emptyProject;

  /// No description provided for @createFolder.
  ///
  /// In en, this message translates to:
  /// **'Create Folder'**
  String get createFolder;

  /// No description provided for @editFolder.
  ///
  /// In en, this message translates to:
  /// **'Edit Folder'**
  String get editFolder;

  /// No description provided for @emptyFolder.
  ///
  /// In en, this message translates to:
  /// **'Empty Folder'**
  String get emptyFolder;

  /// No description provided for @errorLoadingRequests.
  ///
  /// In en, this message translates to:
  /// **'Error loading requests: {message}'**
  String errorLoadingRequests(String message);

  /// No description provided for @deleteNamedTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String deleteNamedTitle(String name);

  /// No description provided for @deleteProjectMessage.
  ///
  /// In en, this message translates to:
  /// **'This will delete all folders and requests inside.'**
  String get deleteProjectMessage;

  /// No description provided for @deleteFolderMessage.
  ///
  /// In en, this message translates to:
  /// **'This will delete all items inside.'**
  String get deleteFolderMessage;

  /// No description provided for @myProjectsAndRequests.
  ///
  /// In en, this message translates to:
  /// **'My Projects & Requests'**
  String get myProjectsAndRequests;

  /// No description provided for @newProjectTooltip.
  ///
  /// In en, this message translates to:
  /// **'New Project'**
  String get newProjectTooltip;

  /// No description provided for @projectsWorkspacesSection.
  ///
  /// In en, this message translates to:
  /// **'PROJECTS / WORKSPACES'**
  String get projectsWorkspacesSection;

  /// No description provided for @unclassifiedRoot.
  ///
  /// In en, this message translates to:
  /// **'UNCLASSIFIED (ROOT)'**
  String get unclassifiedRoot;

  /// No description provided for @dragRequestsHere.
  ///
  /// In en, this message translates to:
  /// **'Drag requests here to remove them from folders'**
  String get dragRequestsHere;

  /// No description provided for @createProjectHint.
  ///
  /// In en, this message translates to:
  /// **'Create a project to isolate your environments and variables.'**
  String get createProjectHint;

  /// No description provided for @newProjectFolder.
  ///
  /// In en, this message translates to:
  /// **'New Project / Folder'**
  String get newProjectFolder;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAll;

  /// No description provided for @deleteCollectionWithEnvironments.
  ///
  /// In en, this message translates to:
  /// **'All requests and environments will be deleted. This cannot be undone.'**
  String get deleteCollectionWithEnvironments;

  /// No description provided for @saveRequest.
  ///
  /// In en, this message translates to:
  /// **'Save Request'**
  String get saveRequest;

  /// No description provided for @requestNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Request Name'**
  String get requestNameLabel;

  /// No description provided for @requestNameHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. Get Users'**
  String get requestNameHint;

  /// No description provided for @folderProjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Folder / Project'**
  String get folderProjectLabel;

  /// No description provided for @unclassifiedRootOption.
  ///
  /// In en, this message translates to:
  /// **'Unclassified (Root)'**
  String get unclassifiedRootOption;

  /// No description provided for @requestSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request saved successfully'**
  String get requestSavedSuccess;

  /// No description provided for @requestMovedToRoot.
  ///
  /// In en, this message translates to:
  /// **'Request \"{name}\" moved to root'**
  String requestMovedToRoot(String name);

  /// No description provided for @renameProject.
  ///
  /// In en, this message translates to:
  /// **'Rename Project'**
  String get renameProject;

  /// No description provided for @renameFolder.
  ///
  /// In en, this message translates to:
  /// **'Rename Folder'**
  String get renameFolder;

  /// No description provided for @newProject.
  ///
  /// In en, this message translates to:
  /// **'New Project'**
  String get newProject;

  /// No description provided for @newFolder.
  ///
  /// In en, this message translates to:
  /// **'New Folder'**
  String get newFolder;

  /// No description provided for @authorization.
  ///
  /// In en, this message translates to:
  /// **'Authorization'**
  String get authorization;

  /// No description provided for @authType.
  ///
  /// In en, this message translates to:
  /// **'Auth Type'**
  String get authType;

  /// No description provided for @inheritAuthDescription.
  ///
  /// In en, this message translates to:
  /// **'This folder will use the authentication configured in its parent folder or project.'**
  String get inheritAuthDescription;

  /// No description provided for @noAuthDescription.
  ///
  /// In en, this message translates to:
  /// **'No authentication will be used.'**
  String get noAuthDescription;

  /// No description provided for @addToLabel.
  ///
  /// In en, this message translates to:
  /// **'Add to'**
  String get addToLabel;

  /// No description provided for @header.
  ///
  /// In en, this message translates to:
  /// **'Header'**
  String get header;

  /// No description provided for @queryParams.
  ///
  /// In en, this message translates to:
  /// **'Query Params'**
  String get queryParams;

  /// No description provided for @configNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Configuration not available for this type yet.'**
  String get configNotAvailable;

  /// No description provided for @projectSaved.
  ///
  /// In en, this message translates to:
  /// **'Project saved'**
  String get projectSaved;

  /// No description provided for @folderSaved.
  ///
  /// In en, this message translates to:
  /// **'Folder saved'**
  String get folderSaved;

  /// No description provided for @typeToSearch.
  ///
  /// In en, this message translates to:
  /// **'Type to search...'**
  String get typeToSearch;

  /// No description provided for @paletteAction.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get paletteAction;

  /// No description provided for @switchWorkspaceAction.
  ///
  /// In en, this message translates to:
  /// **'Switch Workspace'**
  String get switchWorkspaceAction;

  /// No description provided for @paletteProject.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get paletteProject;

  /// No description provided for @paletteFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get paletteFolder;

  /// No description provided for @paletteEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get paletteEnvironment;

  /// No description provided for @paletteRequest.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get paletteRequest;

  /// No description provided for @paletteHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get paletteHistory;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @allRequests.
  ///
  /// In en, this message translates to:
  /// **'All Requests'**
  String get allRequests;

  /// No description provided for @importCollection.
  ///
  /// In en, this message translates to:
  /// **'Import Collection'**
  String get importCollection;

  /// No description provided for @activateWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Activate Workspace'**
  String get activateWorkspace;

  /// No description provided for @syncExport.
  ///
  /// In en, this message translates to:
  /// **'Sync / Export'**
  String get syncExport;

  /// No description provided for @collectionExported.
  ///
  /// In en, this message translates to:
  /// **'Collection exported successfully'**
  String get collectionExported;

  /// No description provided for @exportError.
  ///
  /// In en, this message translates to:
  /// **'Export error: {message}'**
  String exportError(String message);

  /// No description provided for @environments.
  ///
  /// In en, this message translates to:
  /// **'Environments'**
  String get environments;

  /// No description provided for @newItem.
  ///
  /// In en, this message translates to:
  /// **'New Item'**
  String get newItem;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @projectsSection.
  ///
  /// In en, this message translates to:
  /// **'PROJECTS'**
  String get projectsSection;

  /// No description provided for @requestMovedToCollection.
  ///
  /// In en, this message translates to:
  /// **'Request \"{request}\" moved to \"{collection}\"'**
  String requestMovedToCollection(String request, String collection);

  /// No description provided for @projectMovedToCollection.
  ///
  /// In en, this message translates to:
  /// **'Project \"{project}\" moved into \"{collection}\"'**
  String projectMovedToCollection(String project, String collection);

  /// No description provided for @curlImportedSuccess.
  ///
  /// In en, this message translates to:
  /// **'cURL imported successfully!'**
  String get curlImportedSuccess;

  /// No description provided for @invalidCurlCommand.
  ///
  /// In en, this message translates to:
  /// **'Invalid cURL command or format not supported'**
  String get invalidCurlCommand;

  /// No description provided for @pasteCurlHint.
  ///
  /// In en, this message translates to:
  /// **'Paste your cURL command here...'**
  String get pasteCurlHint;

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Imported successfully!'**
  String get importSuccess;

  /// No description provided for @importDescription.
  ///
  /// In en, this message translates to:
  /// **'Import OpenAPI/Swagger or Postman from URL or file.'**
  String get importDescription;

  /// No description provided for @importSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Source:'**
  String get importSourceLabel;

  /// No description provided for @importFormatLabel.
  ///
  /// In en, this message translates to:
  /// **'Format:'**
  String get importFormatLabel;

  /// No description provided for @importAutoDetect.
  ///
  /// In en, this message translates to:
  /// **'Auto-detect'**
  String get importAutoDetect;

  /// No description provided for @importOpenApi.
  ///
  /// In en, this message translates to:
  /// **'OpenAPI / Swagger'**
  String get importOpenApi;

  /// No description provided for @importPostman.
  ///
  /// In en, this message translates to:
  /// **'Postman Collection'**
  String get importPostman;

  /// No description provided for @importUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'JSON/YAML URL'**
  String get importUrlLabel;

  /// No description provided for @importUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://...'**
  String get importUrlHint;

  /// No description provided for @selectFile.
  ///
  /// In en, this message translates to:
  /// **'Select File'**
  String get selectFile;

  /// No description provided for @importNow.
  ///
  /// In en, this message translates to:
  /// **'Import Now'**
  String get importNow;

  /// No description provided for @fileReadError.
  ///
  /// In en, this message translates to:
  /// **'Could not read file bytes'**
  String get fileReadError;

  /// No description provided for @sourceUrl.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get sourceUrl;

  /// No description provided for @sourceFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get sourceFile;

  /// No description provided for @beautify.
  ///
  /// In en, this message translates to:
  /// **'Beautify'**
  String get beautify;

  /// No description provided for @minify.
  ///
  /// In en, this message translates to:
  /// **'Minify'**
  String get minify;

  /// No description provided for @generateFromSchema.
  ///
  /// In en, this message translates to:
  /// **'Generate from Schema'**
  String get generateFromSchema;

  /// No description provided for @bodyJsonHint.
  ///
  /// In en, this message translates to:
  /// **'\\\"key\\\": \\\"value\\\"'**
  String get bodyJsonHint;

  /// No description provided for @preRequestTab.
  ///
  /// In en, this message translates to:
  /// **'Pre-request'**
  String get preRequestTab;

  /// No description provided for @postRequestTab.
  ///
  /// In en, this message translates to:
  /// **'Post-request (Extract)'**
  String get postRequestTab;

  /// No description provided for @preRequestDescription.
  ///
  /// In en, this message translates to:
  /// **'Generate/replace variables before the request'**
  String get preRequestDescription;

  /// No description provided for @postRequestDescription.
  ///
  /// In en, this message translates to:
  /// **'Extract variables from the response'**
  String get postRequestDescription;

  /// No description provided for @test.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get test;

  /// No description provided for @variableNameHint.
  ///
  /// In en, this message translates to:
  /// **'Variable Name'**
  String get variableNameHint;

  /// No description provided for @jsonPathHint.
  ///
  /// In en, this message translates to:
  /// **'JSONPath (e.g. \$.data.id)'**
  String get jsonPathHint;

  /// No description provided for @valueHint.
  ///
  /// In en, this message translates to:
  /// **'Value (e.g. timestamp)'**
  String get valueHint;

  /// No description provided for @noResponseToTest.
  ///
  /// In en, this message translates to:
  /// **'No response available to test.'**
  String get noResponseToTest;

  /// No description provided for @testCompleted.
  ///
  /// In en, this message translates to:
  /// **'Test completed'**
  String get testCompleted;

  /// No description provided for @absoluteUrlError.
  ///
  /// In en, this message translates to:
  /// **'Error: Do not use absolute paths (http/https) here.'**
  String get absoluteUrlError;

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get understood;

  /// No description provided for @copyJson.
  ///
  /// In en, this message translates to:
  /// **'Copy JSON'**
  String get copyJson;

  /// No description provided for @jsonCopied.
  ///
  /// In en, this message translates to:
  /// **'JSON copied to clipboard'**
  String get jsonCopied;

  /// No description provided for @codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard'**
  String get codeCopied;

  /// No description provided for @biometricLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Xolo Locked'**
  String get biometricLockedTitle;

  /// No description provided for @biometricVaultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your secure API vault'**
  String get biometricVaultSubtitle;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @unlockReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock Xolo to continue'**
  String get unlockReason;

  /// No description provided for @getNewAccessToken.
  ///
  /// In en, this message translates to:
  /// **'Get New Access Token'**
  String get getNewAccessToken;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @bearerTokenHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. eyJhbGciOiJIUzI1Ni...'**
  String get bearerTokenHint;

  /// No description provided for @apiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. X-API-Key'**
  String get apiKeyHint;

  /// No description provided for @projectNameHint.
  ///
  /// In en, this message translates to:
  /// **'My API Project'**
  String get projectNameHint;

  /// No description provided for @oauthCompleteTokenUrl.
  ///
  /// In en, this message translates to:
  /// **'Please complete Token URL and Client ID'**
  String get oauthCompleteTokenUrl;

  /// No description provided for @oauthCompleteAuthUrl.
  ///
  /// In en, this message translates to:
  /// **'Please complete Auth URL'**
  String get oauthCompleteAuthUrl;

  /// No description provided for @oauthTokenSuccess.
  ///
  /// In en, this message translates to:
  /// **'Token obtained successfully'**
  String get oauthTokenSuccess;

  /// No description provided for @oauthClientCredentials.
  ///
  /// In en, this message translates to:
  /// **'Client Credentials'**
  String get oauthClientCredentials;

  /// No description provided for @oauthPasswordGrant.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get oauthPasswordGrant;

  /// No description provided for @oauthAuthorizationCode.
  ///
  /// In en, this message translates to:
  /// **'Authorization Code'**
  String get oauthAuthorizationCode;

  /// No description provided for @oauthAuthUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://example.com/oauth/authorize'**
  String get oauthAuthUrlHint;

  /// No description provided for @oauthTokenUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://example.com/oauth/token'**
  String get oauthTokenUrlHint;

  /// No description provided for @obtainNewToken.
  ///
  /// In en, this message translates to:
  /// **'Obtain new token'**
  String get obtainNewToken;

  /// No description provided for @biometricLock.
  ///
  /// In en, this message translates to:
  /// **'Biometric Lock'**
  String get biometricLock;

  /// No description provided for @biometricLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Require FaceID/Fingerprint to open'**
  String get biometricLockSubtitle;

  /// No description provided for @biometricAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not verify your identity. Try again.'**
  String get biometricAuthFailed;

  /// No description provided for @biometricUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Not available on this device'**
  String get biometricUnavailable;

  /// No description provided for @verifyToEnableLock.
  ///
  /// In en, this message translates to:
  /// **'Verify to enable lock'**
  String get verifyToEnableLock;

  /// No description provided for @authError.
  ///
  /// In en, this message translates to:
  /// **'Auth Error: {message}'**
  String authError(String message);

  /// No description provided for @autoLockDelay.
  ///
  /// In en, this message translates to:
  /// **'Auto-Lock Delay'**
  String get autoLockDelay;

  /// No description provided for @immediately.
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get immediately;

  /// No description provided for @after30Seconds.
  ///
  /// In en, this message translates to:
  /// **'After 30 seconds'**
  String get after30Seconds;

  /// No description provided for @after1Minute.
  ///
  /// In en, this message translates to:
  /// **'After 1 minute'**
  String get after1Minute;

  /// No description provided for @after5Minutes.
  ///
  /// In en, this message translates to:
  /// **'After 5 minutes'**
  String get after5Minutes;

  /// No description provided for @delayNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get delayNow;

  /// No description provided for @delaySeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String delaySeconds(int seconds);

  /// No description provided for @delayMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String delayMinutes(int minutes);

  /// No description provided for @delaySecondsFull.
  ///
  /// In en, this message translates to:
  /// **'{seconds} seconds'**
  String delaySecondsFull(int seconds);

  /// No description provided for @delayMinutesFull.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minute(s)'**
  String delayMinutesFull(int minutes);

  /// No description provided for @incognitoMode.
  ///
  /// In en, this message translates to:
  /// **'Incognito Mode'**
  String get incognitoMode;

  /// No description provided for @incognitoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Do not save history'**
  String get incognitoSubtitle;

  /// No description provided for @dataOwnership.
  ///
  /// In en, this message translates to:
  /// **'DATA OWNERSHIP'**
  String get dataOwnership;

  /// No description provided for @dataStorage.
  ///
  /// In en, this message translates to:
  /// **'DATA & STORAGE'**
  String get dataStorage;

  /// No description provided for @yourDataStaysYours.
  ///
  /// In en, this message translates to:
  /// **'Your data stays yours'**
  String get yourDataStaysYours;

  /// No description provided for @dataOwnershipDescription1.
  ///
  /// In en, this message translates to:
  /// **'Xolo stores your data locally on this device by default. Nothing is uploaded unless you explicitly export and share a backup file.'**
  String get dataOwnershipDescription1;

  /// No description provided for @dataOwnershipDescription2.
  ///
  /// In en, this message translates to:
  /// **'Use encrypted backups and security profiles to control how strict the app behaves.'**
  String get dataOwnershipDescription2;

  /// No description provided for @securityProfile.
  ///
  /// In en, this message translates to:
  /// **'Security Profile'**
  String get securityProfile;

  /// No description provided for @securityProfileError.
  ///
  /// In en, this message translates to:
  /// **'Security profile error: {message}'**
  String securityProfileError(String message);

  /// No description provided for @profileStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get profileStandard;

  /// No description provided for @profileHardened.
  ///
  /// In en, this message translates to:
  /// **'Hardened'**
  String get profileHardened;

  /// No description provided for @profileParanoid.
  ///
  /// In en, this message translates to:
  /// **'Paranoid'**
  String get profileParanoid;

  /// No description provided for @profileStandardDesc.
  ///
  /// In en, this message translates to:
  /// **'Balanced security and usability'**
  String get profileStandardDesc;

  /// No description provided for @profileHardenedDesc.
  ///
  /// In en, this message translates to:
  /// **'Hide secrets and tighter lock policy'**
  String get profileHardenedDesc;

  /// No description provided for @profileParanoidDesc.
  ///
  /// In en, this message translates to:
  /// **'Maximum protection with immediate lock'**
  String get profileParanoidDesc;

  /// No description provided for @themeWidgetError.
  ///
  /// In en, this message translates to:
  /// **'Theme Widget Error: {message}'**
  String themeWidgetError(String message);

  /// No description provided for @panicFailed.
  ///
  /// In en, this message translates to:
  /// **'Panic Failed: {message}'**
  String panicFailed(String message);

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Xolo API Client v0.9.5'**
  String get appVersion;

  /// No description provided for @collections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get collections;

  /// No description provided for @hostHint.
  ///
  /// In en, this message translates to:
  /// **'host'**
  String get hostHint;

  /// No description provided for @invalidJson.
  ///
  /// In en, this message translates to:
  /// **'Invalid JSON'**
  String get invalidJson;

  /// No description provided for @schemaGenerated.
  ///
  /// In en, this message translates to:
  /// **'Data generated from Schema'**
  String get schemaGenerated;

  /// No description provided for @schemaEmptyResult.
  ///
  /// In en, this message translates to:
  /// **'Schema produced valid null/empty result.'**
  String get schemaEmptyResult;

  /// No description provided for @schemaParseFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to parse Schema'**
  String get schemaParseFailed;

  /// No description provided for @noSchemaAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Schema available for this request'**
  String get noSchemaAvailable;

  /// No description provided for @codeSnippet.
  ///
  /// In en, this message translates to:
  /// **'Code Snippet'**
  String get codeSnippet;

  /// No description provided for @noResponse.
  ///
  /// In en, this message translates to:
  /// **'No response'**
  String get noResponse;

  /// No description provided for @responseErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error:\n{message}'**
  String responseErrorPrefix(String message);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
