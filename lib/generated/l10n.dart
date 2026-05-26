// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `جارٍ التحميل...`
  String get loading {
    return Intl.message('جارٍ التحميل...', name: 'loading', desc: '', args: []);
  }

  /// `قطعك`
  String get brandWordmark {
    return Intl.message('قطعك', name: 'brandWordmark', desc: '', args: []);
  }

  /// `حدث خطأ ما`
  String get errorStateTitle {
    return Intl.message(
      'حدث خطأ ما',
      name: 'errorStateTitle',
      desc: '',
      args: [],
    );
  }

  /// `إعادة المحاولة`
  String get retryAction {
    return Intl.message(
      'إعادة المحاولة',
      name: 'retryAction',
      desc: '',
      args: [],
    );
  }

  /// `تعذر التحقق من الجلسة. حاول مرة أخرى.`
  String get authResolutionError {
    return Intl.message(
      'تعذر التحقق من الجلسة. حاول مرة أخرى.',
      name: 'authResolutionError',
      desc: '',
      args: [],
    );
  }

  /// `مرحباً بعودتك`
  String get welcomeBack {
    return Intl.message(
      'مرحباً بعودتك',
      name: 'welcomeBack',
      desc: '',
      args: [],
    );
  }

  /// `سجّل الدخول إلى حسابك`
  String get signInSubtitle {
    return Intl.message(
      'سجّل الدخول إلى حسابك',
      name: 'signInSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `البريد الإلكتروني`
  String get emailLabel {
    return Intl.message(
      'البريد الإلكتروني',
      name: 'emailLabel',
      desc: '',
      args: [],
    );
  }

  /// `كلمة المرور`
  String get passwordLabel {
    return Intl.message(
      'كلمة المرور',
      name: 'passwordLabel',
      desc: '',
      args: [],
    );
  }

  /// `نسيت كلمة المرور؟`
  String get forgotPassword {
    return Intl.message(
      'نسيت كلمة المرور؟',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `تسجيل الدخول`
  String get signIn {
    return Intl.message('تسجيل الدخول', name: 'signIn', desc: '', args: []);
  }

  /// `تسجيل Google غير متاح حالياً`
  String get googleComingSoon {
    return Intl.message(
      'تسجيل Google غير متاح حالياً',
      name: 'googleComingSoon',
      desc: '',
      args: [],
    );
  }

  /// `ليس لديك حساب؟ أنشئ حساباً`
  String get createAccountPrompt {
    return Intl.message(
      'ليس لديك حساب؟ أنشئ حساباً',
      name: 'createAccountPrompt',
      desc: '',
      args: [],
    );
  }

  /// `إنشاء حساب`
  String get createAccount {
    return Intl.message(
      'إنشاء حساب',
      name: 'createAccount',
      desc: '',
      args: [],
    );
  }

  /// `الاسم الكامل`
  String get fullNameLabel {
    return Intl.message(
      'الاسم الكامل',
      name: 'fullNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `رقم الهاتف`
  String get phoneLabel {
    return Intl.message('رقم الهاتف', name: 'phoneLabel', desc: '', args: []);
  }

  /// `تأكيد كلمة المرور`
  String get confirmPasswordLabel {
    return Intl.message(
      'تأكيد كلمة المرور',
      name: 'confirmPasswordLabel',
      desc: '',
      args: [],
    );
  }

  /// `أوافق على الشروط وسياسات السوق`
  String get acceptTerms {
    return Intl.message(
      'أوافق على الشروط وسياسات السوق',
      name: 'acceptTerms',
      desc: '',
      args: [],
    );
  }

  /// `لديك حساب بالفعل؟ سجّل الدخول`
  String get signInPrompt {
    return Intl.message(
      'لديك حساب بالفعل؟ سجّل الدخول',
      name: 'signInPrompt',
      desc: '',
      args: [],
    );
  }

  /// `إعادة تعيين كلمة المرور`
  String get resetPassword {
    return Intl.message(
      'إعادة تعيين كلمة المرور',
      name: 'resetPassword',
      desc: '',
      args: [],
    );
  }

  /// `أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة التعيين.`
  String get resetPasswordBody {
    return Intl.message(
      'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة التعيين.',
      name: 'resetPasswordBody',
      desc: '',
      args: [],
    );
  }

  /// `إرسال رابط إعادة التعيين`
  String get sendResetLink {
    return Intl.message(
      'إرسال رابط إعادة التعيين',
      name: 'sendResetLink',
      desc: '',
      args: [],
    );
  }

  /// `تحقق من بريدك الإلكتروني`
  String get checkYourEmail {
    return Intl.message(
      'تحقق من بريدك الإلكتروني',
      name: 'checkYourEmail',
      desc: '',
      args: [],
    );
  }

  /// `إذا كان الحساب موجوداً فقد تم إرسال رابط إعادة التعيين.`
  String get passwordResetSuccess {
    return Intl.message(
      'إذا كان الحساب موجوداً فقد تم إرسال رابط إعادة التعيين.',
      name: 'passwordResetSuccess',
      desc: '',
      args: [],
    );
  }

  /// `تعذر بدء إعادة تعيين كلمة المرور.`
  String get passwordResetFailure {
    return Intl.message(
      'تعذر بدء إعادة تعيين كلمة المرور.',
      name: 'passwordResetFailure',
      desc: '',
      args: [],
    );
  }

  /// `الوصول إلى الحساب`
  String get authGateEyebrow {
    return Intl.message(
      'الوصول إلى الحساب',
      name: 'authGateEyebrow',
      desc: '',
      args: [],
    );
  }

  /// `تسجيل الدخول مطلوب`
  String get authGateTitle {
    return Intl.message(
      'تسجيل الدخول مطلوب',
      name: 'authGateTitle',
      desc: '',
      args: [],
    );
  }

  /// `أنشئ حساباً أو سجّل الدخول لمتابعة هذا الإجراء.`
  String get authGateBody {
    return Intl.message(
      'أنشئ حساباً أو سجّل الدخول لمتابعة هذا الإجراء.',
      name: 'authGateBody',
      desc: '',
      args: [],
    );
  }

  /// `سجّل الدخول لحفظ هذا الإعلان`
  String get authGateSaveTitle {
    return Intl.message(
      'سجّل الدخول لحفظ هذا الإعلان',
      name: 'authGateSaveTitle',
      desc: '',
      args: [],
    );
  }

  /// `تحتاج إلى حساب قبل إضافة هذا الإعلان إلى المحفوظات.`
  String get authGateSaveBody {
    return Intl.message(
      'تحتاج إلى حساب قبل إضافة هذا الإعلان إلى المحفوظات.',
      name: 'authGateSaveBody',
      desc: '',
      args: [],
    );
  }

  /// `سجّل الدخول لمراسلة البائع`
  String get authGateMessageTitle {
    return Intl.message(
      'سجّل الدخول لمراسلة البائع',
      name: 'authGateMessageTitle',
      desc: '',
      args: [],
    );
  }

  /// `استخدم حسابك لفتح المحادثة ومتابعة التواصل مع البائع.`
  String get authGateMessageBody {
    return Intl.message(
      'استخدم حسابك لفتح المحادثة ومتابعة التواصل مع البائع.',
      name: 'authGateMessageBody',
      desc: '',
      args: [],
    );
  }

  /// `سجّل الدخول لطلب هذه القطعة`
  String get authGateBuyTitle {
    return Intl.message(
      'سجّل الدخول لطلب هذه القطعة',
      name: 'authGateBuyTitle',
      desc: '',
      args: [],
    );
  }

  /// `استخدم حسابك للمتابعة إلى مسار طلب الشراء لهذا الإعلان.`
  String get authGateBuyBody {
    return Intl.message(
      'استخدم حسابك للمتابعة إلى مسار طلب الشراء لهذا الإعلان.',
      name: 'authGateBuyBody',
      desc: '',
      args: [],
    );
  }

  /// `جارٍ تحميل بيانات الحساب والسوق.`
  String get splashSubtitle {
    return Intl.message(
      'جارٍ تحميل بيانات الحساب والسوق.',
      name: 'splashSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `أنشئ حساب مشتري مع بيانات التواصل الأساسية.`
  String get signUpSubtitle {
    return Intl.message(
      'أنشئ حساب مشتري مع بيانات التواصل الأساسية.',
      name: 'signUpSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `الحساب`
  String get accountSettingsEyebrow {
    return Intl.message(
      'الحساب',
      name: 'accountSettingsEyebrow',
      desc: '',
      args: [],
    );
  }

  /// `إعدادات الحساب`
  String get accountSettingsTitle {
    return Intl.message(
      'إعدادات الحساب',
      name: 'accountSettingsTitle',
      desc: '',
      args: [],
    );
  }

  /// `حدّث بيانات الهوية المرتبطة بهذا الحساب للمشتري أو البائع.`
  String get accountSettingsSubtitle {
    return Intl.message(
      'حدّث بيانات الهوية المرتبطة بهذا الحساب للمشتري أو البائع.',
      name: 'accountSettingsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `البريد الإلكتروني يُدار من خلال موفر تسجيل الدخول.`
  String get accountSettingsEmailLocked {
    return Intl.message(
      'البريد الإلكتروني يُدار من خلال موفر تسجيل الدخول.',
      name: 'accountSettingsEmailLocked',
      desc: '',
      args: [],
    );
  }

  /// `حفظ الإعدادات`
  String get accountSettingsSave {
    return Intl.message(
      'حفظ الإعدادات',
      name: 'accountSettingsSave',
      desc: '',
      args: [],
    );
  }

  /// `تم تحديث إعدادات الحساب.`
  String get accountSettingsSaved {
    return Intl.message(
      'تم تحديث إعدادات الحساب.',
      name: 'accountSettingsSaved',
      desc: '',
      args: [],
    );
  }

  /// `تغيير كلمة المرور`
  String get accountSettingsChangePasswordAction {
    return Intl.message(
      'تغيير كلمة المرور',
      name: 'accountSettingsChangePasswordAction',
      desc: '',
      args: [],
    );
  }

  /// `تغيير كلمة المرور`
  String get accountSettingsUpdatePasswordTitle {
    return Intl.message(
      'تغيير كلمة المرور',
      name: 'accountSettingsUpdatePasswordTitle',
      desc: '',
      args: [],
    );
  }

  /// `تحديث كلمة المرور`
  String get accountSettingsUpdatePasswordConfirm {
    return Intl.message(
      'تحديث كلمة المرور',
      name: 'accountSettingsUpdatePasswordConfirm',
      desc: '',
      args: [],
    );
  }

  /// `كلمة المرور الجديدة`
  String get accountSettingsNewPasswordLabel {
    return Intl.message(
      'كلمة المرور الجديدة',
      name: 'accountSettingsNewPasswordLabel',
      desc: '',
      args: [],
    );
  }

  /// `تأكيد كلمة المرور الجديدة`
  String get accountSettingsConfirmPasswordLabel {
    return Intl.message(
      'تأكيد كلمة المرور الجديدة',
      name: 'accountSettingsConfirmPasswordLabel',
      desc: '',
      args: [],
    );
  }

  /// `استخدم 8 أحرف على الأقل لكلمة المرور الجديدة.`
  String get accountSettingsPasswordTooShort {
    return Intl.message(
      'استخدم 8 أحرف على الأقل لكلمة المرور الجديدة.',
      name: 'accountSettingsPasswordTooShort',
      desc: '',
      args: [],
    );
  }

  /// `تأكيد كلمة المرور غير مطابق.`
  String get accountSettingsPasswordMismatch {
    return Intl.message(
      'تأكيد كلمة المرور غير مطابق.',
      name: 'accountSettingsPasswordMismatch',
      desc: '',
      args: [],
    );
  }

  /// `تم تحديث كلمة المرور.`
  String get accountSettingsPasswordUpdated {
    return Intl.message(
      'تم تحديث كلمة المرور.',
      name: 'accountSettingsPasswordUpdated',
      desc: '',
      args: [],
    );
  }

  /// `حذف الحساب`
  String get accountSettingsDeleteAccountAction {
    return Intl.message(
      'حذف الحساب',
      name: 'accountSettingsDeleteAccountAction',
      desc: '',
      args: [],
    );
  }

  /// `حذف الحساب`
  String get accountSettingsDeleteAccountTitle {
    return Intl.message(
      'حذف الحساب',
      name: 'accountSettingsDeleteAccountTitle',
      desc: '',
      args: [],
    );
  }

  /// `يُغلق هذا الحساب على هذا الجهاز ويُعطّل الوصول إلى السوق إلى أن يُعاد تفعيله عبر الدعم.`
  String get accountSettingsDeleteAccountBody {
    return Intl.message(
      'يُغلق هذا الحساب على هذا الجهاز ويُعطّل الوصول إلى السوق إلى أن يُعاد تفعيله عبر الدعم.',
      name: 'accountSettingsDeleteAccountBody',
      desc: '',
      args: [],
    );
  }

  /// `حذف الحساب`
  String get accountSettingsDeleteAccountConfirm {
    return Intl.message(
      'حذف الحساب',
      name: 'accountSettingsDeleteAccountConfirm',
      desc: '',
      args: [],
    );
  }

  /// `تم تعطيل الحساب.`
  String get accountSettingsDeleteAccountSuccess {
    return Intl.message(
      'تم تعطيل الحساب.',
      name: 'accountSettingsDeleteAccountSuccess',
      desc: '',
      args: [],
    );
  }

  /// `اللغة`
  String get languageSelectionEyebrow {
    return Intl.message(
      'اللغة',
      name: 'languageSelectionEyebrow',
      desc: '',
      args: [],
    );
  }

  /// `اللغة`
  String get languageSelectionTitle {
    return Intl.message(
      'اللغة',
      name: 'languageSelectionTitle',
      desc: '',
      args: [],
    );
  }

  /// `اختر لغة العرض داخل Qitak.`
  String get languageSelectionSubtitle {
    return Intl.message(
      'اختر لغة العرض داخل Qitak.',
      name: 'languageSelectionSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `تم تحديث تفضيل اللغة.`
  String get languageSelectionSaved {
    return Intl.message(
      'تم تحديث تفضيل اللغة.',
      name: 'languageSelectionSaved',
      desc: '',
      args: [],
    );
  }

  /// `العربية`
  String get languageNameArabic {
    return Intl.message(
      'العربية',
      name: 'languageNameArabic',
      desc: '',
      args: [],
    );
  }

  /// `الإنجليزية`
  String get languageNameEnglish {
    return Intl.message(
      'الإنجليزية',
      name: 'languageNameEnglish',
      desc: '',
      args: [],
    );
  }

  /// `الفرنسية`
  String get languageNameFrench {
    return Intl.message(
      'الفرنسية',
      name: 'languageNameFrench',
      desc: '',
      args: [],
    );
  }

  /// `العربية`
  String get languageNativeArabic {
    return Intl.message(
      'العربية',
      name: 'languageNativeArabic',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get languageNativeEnglish {
    return Intl.message(
      'English',
      name: 'languageNativeEnglish',
      desc: '',
      args: [],
    );
  }

  /// `Français`
  String get languageNativeFrench {
    return Intl.message(
      'Français',
      name: 'languageNativeFrench',
      desc: '',
      args: [],
    );
  }

  /// `المظهر`
  String get appearanceSettingsEyebrow {
    return Intl.message(
      'المظهر',
      name: 'appearanceSettingsEyebrow',
      desc: '',
      args: [],
    );
  }

  /// `المظهر`
  String get appearanceSettingsTitle {
    return Intl.message(
      'المظهر',
      name: 'appearanceSettingsTitle',
      desc: '',
      args: [],
    );
  }

  /// `اختر طريقة عرض Qitak على هذا الجهاز.`
  String get appearanceSettingsSubtitle {
    return Intl.message(
      'اختر طريقة عرض Qitak على هذا الجهاز.',
      name: 'appearanceSettingsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `تم تحديث تفضيل المظهر.`
  String get appearanceSettingsSaved {
    return Intl.message(
      'تم تحديث تفضيل المظهر.',
      name: 'appearanceSettingsSaved',
      desc: '',
      args: [],
    );
  }

  /// `داكن`
  String get appearanceModeDarkTitle {
    return Intl.message(
      'داكن',
      name: 'appearanceModeDarkTitle',
      desc: '',
      args: [],
    );
  }

  /// `استخدم المظهر الداكن.`
  String get appearanceModeDarkSubtitle {
    return Intl.message(
      'استخدم المظهر الداكن.',
      name: 'appearanceModeDarkSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `فاتح`
  String get appearanceModeLightTitle {
    return Intl.message(
      'فاتح',
      name: 'appearanceModeLightTitle',
      desc: '',
      args: [],
    );
  }

  /// `استخدم واجهة فاتحة مناسبة للعرض النهاري.`
  String get appearanceModeLightSubtitle {
    return Intl.message(
      'استخدم واجهة فاتحة مناسبة للعرض النهاري.',
      name: 'appearanceModeLightSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `النظام`
  String get appearanceModeSystemTitle {
    return Intl.message(
      'النظام',
      name: 'appearanceModeSystemTitle',
      desc: '',
      args: [],
    );
  }

  /// `اتبع إعداد مظهر الجهاز.`
  String get appearanceModeSystemSubtitle {
    return Intl.message(
      'اتبع إعداد مظهر الجهاز.',
      name: 'appearanceModeSystemSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `التالي`
  String get onboardingNext {
    return Intl.message('التالي', name: 'onboardingNext', desc: '', args: []);
  }

  /// `تخطي`
  String get onboardingSkip {
    return Intl.message('تخطي', name: 'onboardingSkip', desc: '', args: []);
  }

  /// `متابعة`
  String get onboardingGetStarted {
    return Intl.message(
      'متابعة',
      name: 'onboardingGetStarted',
      desc: '',
      args: [],
    );
  }

  /// `البداية`
  String get onboardingEyebrow {
    return Intl.message(
      'البداية',
      name: 'onboardingEyebrow',
      desc: '',
      args: [],
    );
  }

  /// `تصفح القطع قبل تسجيل الدخول`
  String get onboardingTitleOne {
    return Intl.message(
      'تصفح القطع قبل تسجيل الدخول',
      name: 'onboardingTitleOne',
      desc: '',
      args: [],
    );
  }

  /// `استكشف الإعلانات، قارن الخيارات، وافهم السوق قبل إنشاء الحساب.`
  String get onboardingBodyOne {
    return Intl.message(
      'استكشف الإعلانات، قارن الخيارات، وافهم السوق قبل إنشاء الحساب.',
      name: 'onboardingBodyOne',
      desc: '',
      args: [],
    );
  }

  /// `ابحث بالفلاتر التي تهم فعلاً`
  String get onboardingTitleTwo {
    return Intl.message(
      'ابحث بالفلاتر التي تهم فعلاً',
      name: 'onboardingTitleTwo',
      desc: '',
      args: [],
    );
  }

  /// `استخدم الفئة والولاية والبلدية والعلامة والموديل والسنة للوصول إلى القطعة المناسبة بسرعة أكبر.`
  String get onboardingBodyTwo {
    return Intl.message(
      'استخدم الفئة والولاية والبلدية والعلامة والموديل والسنة للوصول إلى القطعة المناسبة بسرعة أكبر.',
      name: 'onboardingBodyTwo',
      desc: '',
      args: [],
    );
  }

  /// `سجل الدخول فقط عندما تريد المتابعة`
  String get onboardingTitleThree {
    return Intl.message(
      'سجل الدخول فقط عندما تريد المتابعة',
      name: 'onboardingTitleThree',
      desc: '',
      args: [],
    );
  }

  /// `احفظ الإعلانات وراسل البائعين واطلب القطع عندما تصبح جاهزاً.`
  String get onboardingBodyThree {
    return Intl.message(
      'احفظ الإعلانات وراسل البائعين واطلب القطع عندما تصبح جاهزاً.',
      name: 'onboardingBodyThree',
      desc: '',
      args: [],
    );
  }

  /// `تصفح كزائر`
  String get onboardingPanelBrowse {
    return Intl.message(
      'تصفح كزائر',
      name: 'onboardingPanelBrowse',
      desc: '',
      args: [],
    );
  }

  /// `الحساب لاحقاً`
  String get onboardingPanelGuest {
    return Intl.message(
      'الحساب لاحقاً',
      name: 'onboardingPanelGuest',
      desc: '',
      args: [],
    );
  }

  /// `قارن الخيارات`
  String get onboardingPanelCompare {
    return Intl.message(
      'قارن الخيارات',
      name: 'onboardingPanelCompare',
      desc: '',
      args: [],
    );
  }

  /// `فلاتر دقيقة`
  String get onboardingPanelFilters {
    return Intl.message(
      'فلاتر دقيقة',
      name: 'onboardingPanelFilters',
      desc: '',
      args: [],
    );
  }

  /// `ابحث أولاً`
  String get onboardingPanelSearch {
    return Intl.message(
      'ابحث أولاً',
      name: 'onboardingPanelSearch',
      desc: '',
      args: [],
    );
  }

  /// `حفظ • مراسلة • طلب`
  String get onboardingPanelActions {
    return Intl.message(
      'حفظ • مراسلة • طلب',
      name: 'onboardingPanelActions',
      desc: '',
      args: [],
    );
  }

  /// `سجل الدخول عند الحاجة`
  String get onboardingPanelSignInWhenReady {
    return Intl.message(
      'سجل الدخول عند الحاجة',
      name: 'onboardingPanelSignInWhenReady',
      desc: '',
      args: [],
    );
  }

  /// `الفئة`
  String get onboardingFilterCategory {
    return Intl.message(
      'الفئة',
      name: 'onboardingFilterCategory',
      desc: '',
      args: [],
    );
  }

  /// `الولاية • البلدية`
  String get onboardingFilterLocation {
    return Intl.message(
      'الولاية • البلدية',
      name: 'onboardingFilterLocation',
      desc: '',
      args: [],
    );
  }

  /// `التوافق`
  String get onboardingFilterFitment {
    return Intl.message(
      'التوافق',
      name: 'onboardingFilterFitment',
      desc: '',
      args: [],
    );
  }

  /// `العلامة`
  String get onboardingFilterMake {
    return Intl.message(
      'العلامة',
      name: 'onboardingFilterMake',
      desc: '',
      args: [],
    );
  }

  /// `الموديل`
  String get onboardingFilterModel {
    return Intl.message(
      'الموديل',
      name: 'onboardingFilterModel',
      desc: '',
      args: [],
    );
  }

  /// `السنة`
  String get onboardingFilterYear {
    return Intl.message(
      'السنة',
      name: 'onboardingFilterYear',
      desc: '',
      args: [],
    );
  }

  /// `العناصر المحفوظة`
  String get onboardingActionSaved {
    return Intl.message(
      'العناصر المحفوظة',
      name: 'onboardingActionSaved',
      desc: '',
      args: [],
    );
  }

  /// `الرسائل`
  String get onboardingActionMessages {
    return Intl.message(
      'الرسائل',
      name: 'onboardingActionMessages',
      desc: '',
      args: [],
    );
  }

  /// `مصباح أمامي`
  String get onboardingListingOne {
    return Intl.message(
      'مصباح أمامي',
      name: 'onboardingListingOne',
      desc: '',
      args: [],
    );
  }

  /// `فحمات فرامل`
  String get onboardingListingTwo {
    return Intl.message(
      'فحمات فرامل',
      name: 'onboardingListingTwo',
      desc: '',
      args: [],
    );
  }

  /// `البداية`
  String get authChoiceEyebrow {
    return Intl.message(
      'البداية',
      name: 'authChoiceEyebrow',
      desc: '',
      args: [],
    );
  }

  /// `سجّل الدخول أو تصفح أولاً`
  String get authChoiceTitle {
    return Intl.message(
      'سجّل الدخول أو تصفح أولاً',
      name: 'authChoiceTitle',
      desc: '',
      args: [],
    );
  }

  /// `تسجيل دخول البائع`
  String get sellerSignIn {
    return Intl.message(
      'تسجيل دخول البائع',
      name: 'sellerSignIn',
      desc: '',
      args: [],
    );
  }

  /// `تسجيل دخول مخصص لحسابات البائع فقط.`
  String get sellerSignInSubtitle {
    return Intl.message(
      'تسجيل دخول مخصص لحسابات البائع فقط.',
      name: 'sellerSignInSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `إنشاء حساب بائع`
  String get sellerCreateAccount {
    return Intl.message(
      'إنشاء حساب بائع',
      name: 'sellerCreateAccount',
      desc: '',
      args: [],
    );
  }

  /// `تحتاج حساب بائع؟ أنشئ واحداً`
  String get sellerCreateAccountPrompt {
    return Intl.message(
      'تحتاج حساب بائع؟ أنشئ واحداً',
      name: 'sellerCreateAccountPrompt',
      desc: '',
      args: [],
    );
  }

  /// `أنشئ حساب بائع ثم أكمل التوثيق قبل فتح مساحة البائع.`
  String get sellerSignUpSubtitle {
    return Intl.message(
      'أنشئ حساب بائع ثم أكمل التوثيق قبل فتح مساحة البائع.',
      name: 'sellerSignUpSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `هذا الحساب ليس حساب بائع.`
  String get sellerAccessDenied {
    return Intl.message(
      'هذا الحساب ليس حساب بائع.',
      name: 'sellerAccessDenied',
      desc: '',
      args: [],
    );
  }

  /// `هذا الحساب ليس حساب مشتري.`
  String get buyerAccessDenied {
    return Intl.message(
      'هذا الحساب ليس حساب مشتري.',
      name: 'buyerAccessDenied',
      desc: '',
      args: [],
    );
  }

  /// `دخول الإدارة`
  String get adminAccess {
    return Intl.message(
      'دخول الإدارة',
      name: 'adminAccess',
      desc: '',
      args: [],
    );
  }

  /// `تسجيل دخول الإدارة`
  String get adminSignIn {
    return Intl.message(
      'تسجيل دخول الإدارة',
      name: 'adminSignIn',
      desc: '',
      args: [],
    );
  }

  /// `تسجيل دخول مخصّص لمستخدمي الإدارة فقط.`
  String get adminSignInSubtitle {
    return Intl.message(
      'تسجيل دخول مخصّص لمستخدمي الإدارة فقط.',
      name: 'adminSignInSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `العودة إلى دخول المستخدم`
  String get backToUserAuth {
    return Intl.message(
      'العودة إلى دخول المستخدم',
      name: 'backToUserAuth',
      desc: '',
      args: [],
    );
  }

  /// `هذا الحساب لا يملك صلاحية دخول الإدارة.`
  String get adminAccessDenied {
    return Intl.message(
      'هذا الحساب لا يملك صلاحية دخول الإدارة.',
      name: 'adminAccessDenied',
      desc: '',
      args: [],
    );
  }

  /// `المساعدة`
  String get supportHelpEyebrow {
    return Intl.message(
      'المساعدة',
      name: 'supportHelpEyebrow',
      desc: '',
      args: [],
    );
  }

  /// `المساعدة والدعم`
  String get supportHelpTitle {
    return Intl.message(
      'المساعدة والدعم',
      name: 'supportHelpTitle',
      desc: '',
      args: [],
    );
  }

  /// `اعثر على إرشادات الحساب والثقة والإشعارات من مكان واحد.`
  String get supportHelpSubtitle {
    return Intl.message(
      'اعثر على إرشادات الحساب والثقة والإشعارات من مكان واحد.',
      name: 'supportHelpSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `مساعدة الحساب`
  String get supportHelpAccountTitle {
    return Intl.message(
      'مساعدة الحساب',
      name: 'supportHelpAccountTitle',
      desc: '',
      args: [],
    );
  }

  /// `استخدم إعدادات الحساب لبيانات الهوية، واسترجاع كلمة المرور للوصول الآمن.`
  String get supportHelpAccountBody {
    return Intl.message(
      'استخدم إعدادات الحساب لبيانات الهوية، واسترجاع كلمة المرور للوصول الآمن.',
      name: 'supportHelpAccountBody',
      desc: '',
      args: [],
    );
  }

  /// `الثقة والأمان`
  String get supportHelpSafetyTitle {
    return Intl.message(
      'الثقة والأمان',
      name: 'supportHelpSafetyTitle',
      desc: '',
      args: [],
    );
  }

  /// `استخدم شاشات المعاملة والتقييم والنزاع حتى تبقى مشاكل السوق مرتبطة بالصفقة الصحيحة.`
  String get supportHelpSafetyBody {
    return Intl.message(
      'استخدم شاشات المعاملة والتقييم والنزاع حتى تبقى مشاكل السوق مرتبطة بالصفقة الصحيحة.',
      name: 'supportHelpSafetyBody',
      desc: '',
      args: [],
    );
  }

  /// `الإشعارات والتحديثات`
  String get supportHelpNotificationTitle {
    return Intl.message(
      'الإشعارات والتحديثات',
      name: 'supportHelpNotificationTitle',
      desc: '',
      args: [],
    );
  }

  /// `تابع الرسائل وقرارات البائع وتغييرات الإعلانات من مركز الإشعارات.`
  String get supportHelpNotificationBody {
    return Intl.message(
      'تابع الرسائل وقرارات البائع وتغييرات الإعلانات من مركز الإشعارات.',
      name: 'supportHelpNotificationBody',
      desc: '',
      args: [],
    );
  }

  /// `دليل`
  String get supportHelpStatusGuide {
    return Intl.message(
      'دليل',
      name: 'supportHelpStatusGuide',
      desc: '',
      args: [],
    );
  }

  /// `ثقة`
  String get supportHelpStatusTrust {
    return Intl.message(
      'ثقة',
      name: 'supportHelpStatusTrust',
      desc: '',
      args: [],
    );
  }

  /// `تنبيهات`
  String get supportHelpStatusAlerts {
    return Intl.message(
      'تنبيهات',
      name: 'supportHelpStatusAlerts',
      desc: '',
      args: [],
    );
  }

  /// `هل تحتاج إلى متابعة شيء؟`
  String get supportHelpNeedActionTitle {
    return Intl.message(
      'هل تحتاج إلى متابعة شيء؟',
      name: 'supportHelpNeedActionTitle',
      desc: '',
      args: [],
    );
  }

  /// `يحافظ Qitak على الخطوات التالية داخل الشاشات الصحيحة بدلاً من إخفائها خلف محادثة دعم عامة.`
  String get supportHelpNeedActionBody {
    return Intl.message(
      'يحافظ Qitak على الخطوات التالية داخل الشاشات الصحيحة بدلاً من إخفائها خلف محادثة دعم عامة.',
      name: 'supportHelpNeedActionBody',
      desc: '',
      args: [],
    );
  }

  /// `القانوني`
  String get legalInformationEyebrow {
    return Intl.message(
      'القانوني',
      name: 'legalInformationEyebrow',
      desc: '',
      args: [],
    );
  }

  /// `الشروط والخصوصية`
  String get legalInformationTitle {
    return Intl.message(
      'الشروط والخصوصية',
      name: 'legalInformationTitle',
      desc: '',
      args: [],
    );
  }

  /// `راجع شروط السوق ومتطلبات الخصوصية وقواعد بيانات الحساب من مكان واحد.`
  String get legalInformationSubtitle {
    return Intl.message(
      'راجع شروط السوق ومتطلبات الخصوصية وقواعد بيانات الحساب من مكان واحد.',
      name: 'legalInformationSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `سياسة`
  String get legalInformationStatus {
    return Intl.message(
      'سياسة',
      name: 'legalInformationStatus',
      desc: '',
      args: [],
    );
  }

  /// `السوق`
  String get legalInformationMarketplaceStatus {
    return Intl.message(
      'السوق',
      name: 'legalInformationMarketplaceStatus',
      desc: '',
      args: [],
    );
  }

  /// `شروط الاستخدام`
  String get legalInformationTermsTitle {
    return Intl.message(
      'شروط الاستخدام',
      name: 'legalInformationTermsTitle',
      desc: '',
      args: [],
    );
  }

  /// `يجب أن يلتزم الوصول إلى الحساب والرسائل وإجراءات السوق بقواعد Qitak المنشورة.`
  String get legalInformationTermsBody {
    return Intl.message(
      'يجب أن يلتزم الوصول إلى الحساب والرسائل وإجراءات السوق بقواعد Qitak المنشورة.',
      name: 'legalInformationTermsBody',
      desc: '',
      args: [],
    );
  }

  /// `الخصوصية وبيانات الحساب`
  String get legalInformationPrivacyTitle {
    return Intl.message(
      'الخصوصية وبيانات الحساب',
      name: 'legalInformationPrivacyTitle',
      desc: '',
      args: [],
    );
  }

  /// `لا تُستخدم بيانات الملف الشخصي وحقول الموقع وقنوات التواصل إلا لنشاط سوق مشروع.`
  String get legalInformationPrivacyBody {
    return Intl.message(
      'لا تُستخدم بيانات الملف الشخصي وحقول الموقع وقنوات التواصل إلا لنشاط سوق مشروع.',
      name: 'legalInformationPrivacyBody',
      desc: '',
      args: [],
    );
  }

  /// `سلوك السوق`
  String get legalInformationMarketplaceTitle {
    return Intl.message(
      'سلوك السوق',
      name: 'legalInformationMarketplaceTitle',
      desc: '',
      args: [],
    );
  }

  /// `تظل الإعلانات والنزاعات وعمليات البائع خاضعة لسياسات الإشراف والثقة والمعاملات.`
  String get legalInformationMarketplaceBody {
    return Intl.message(
      'تظل الإعلانات والنزاعات وعمليات البائع خاضعة لسياسات الإشراف والثقة والمعاملات.',
      name: 'legalInformationMarketplaceBody',
      desc: '',
      args: [],
    );
  }

  /// `قبل تسجيل الدخول، ما زال بإمكانك ضبط اللغة والمظهر ومسار المساعدة.`
  String get accountUtilitiesGuestSubtitle {
    return Intl.message(
      'قبل تسجيل الدخول، ما زال بإمكانك ضبط اللغة والمظهر ومسار المساعدة.',
      name: 'accountUtilitiesGuestSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `مساحة البائع`
  String get sellerStatusEyebrow {
    return Intl.message(
      'مساحة البائع',
      name: 'sellerStatusEyebrow',
      desc: '',
      args: [],
    );
  }

  /// `حالة توثيق البائع`
  String get sellerStatusTitle {
    return Intl.message(
      'حالة توثيق البائع',
      name: 'sellerStatusTitle',
      desc: '',
      args: [],
    );
  }

  /// `تابع تقدم المراجعة والوثائق المرسلة والخطوات التالية من شاشة مخصّصة للبائع.`
  String get sellerStatusSubtitle {
    return Intl.message(
      'تابع تقدم المراجعة والوثائق المرسلة والخطوات التالية من شاشة مخصّصة للبائع.',
      name: 'sellerStatusSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `هوية الحساب`
  String get sellerStatusProfile {
    return Intl.message(
      'هوية الحساب',
      name: 'sellerStatusProfile',
      desc: '',
      args: [],
    );
  }

  /// `اسم الحساب ورقم الهاتف مرتبطان بطلب توثيق البائع هذا.`
  String get sellerStatusProfileBody {
    return Intl.message(
      'اسم الحساب ورقم الهاتف مرتبطان بطلب توثيق البائع هذا.',
      name: 'sellerStatusProfileBody',
      desc: '',
      args: [],
    );
  }

  /// `مراجعة التوثيق`
  String get sellerStatusVerification {
    return Intl.message(
      'مراجعة التوثيق',
      name: 'sellerStatusVerification',
      desc: '',
      args: [],
    );
  }

  /// `وصول البائع`
  String get sellerStatusWorkspace {
    return Intl.message(
      'وصول البائع',
      name: 'sellerStatusWorkspace',
      desc: '',
      args: [],
    );
  }

  /// `الانتقال إلى مساحة البائع`
  String get sellerStatusBackToWorkspace {
    return Intl.message(
      'الانتقال إلى مساحة البائع',
      name: 'sellerStatusBackToWorkspace',
      desc: '',
      args: [],
    );
  }

  /// `إكمال الطلب`
  String get sellerStatusContinueApplication {
    return Intl.message(
      'إكمال الطلب',
      name: 'sellerStatusContinueApplication',
      desc: '',
      args: [],
    );
  }

  /// `لم يبدأ`
  String get sellerStatusNotStarted {
    return Intl.message(
      'لم يبدأ',
      name: 'sellerStatusNotStarted',
      desc: '',
      args: [],
    );
  }

  /// `قيد المراجعة`
  String get sellerStatusSubmitted {
    return Intl.message(
      'قيد المراجعة',
      name: 'sellerStatusSubmitted',
      desc: '',
      args: [],
    );
  }

  /// `تمت الموافقة`
  String get sellerStatusApproved {
    return Intl.message(
      'تمت الموافقة',
      name: 'sellerStatusApproved',
      desc: '',
      args: [],
    );
  }

  /// `مرفوض`
  String get sellerStatusRejected {
    return Intl.message(
      'مرفوض',
      name: 'sellerStatusRejected',
      desc: '',
      args: [],
    );
  }

  /// `يحتاج معلومات`
  String get sellerStatusNeedsInfo {
    return Intl.message(
      'يحتاج معلومات',
      name: 'sellerStatusNeedsInfo',
      desc: '',
      args: [],
    );
  }

  /// `لم تُرسل طلب توثيق البائع بعد.`
  String get sellerStatusProfileDraftBody {
    return Intl.message(
      'لم تُرسل طلب توثيق البائع بعد.',
      name: 'sellerStatusProfileDraftBody',
      desc: '',
      args: [],
    );
  }

  /// `أكمل الخطوات المتبقية ثم أرسل الطلب للمراجعة.`
  String get sellerStatusVerificationDraftBody {
    return Intl.message(
      'أكمل الخطوات المتبقية ثم أرسل الطلب للمراجعة.',
      name: 'sellerStatusVerificationDraftBody',
      desc: '',
      args: [],
    );
  }

  /// `طلبك قيد المراجعة. سيبقى وصول البائع مغلقاً حتى الموافقة.`
  String get sellerStatusVerificationSubmittedBody {
    return Intl.message(
      'طلبك قيد المراجعة. سيبقى وصول البائع مغلقاً حتى الموافقة.',
      name: 'sellerStatusVerificationSubmittedBody',
      desc: '',
      args: [],
    );
  }

  /// `تمت الموافقة على التوثيق وتم تفعيل وصول البائع.`
  String get sellerStatusVerificationApprovedBody {
    return Intl.message(
      'تمت الموافقة على التوثيق وتم تفعيل وصول البائع.',
      name: 'sellerStatusVerificationApprovedBody',
      desc: '',
      args: [],
    );
  }

  /// `تم رفض آخر مراجعة. حدّث الطلب ثم أعد إرساله.`
  String get sellerStatusVerificationRejectedBody {
    return Intl.message(
      'تم رفض آخر مراجعة. حدّث الطلب ثم أعد إرساله.',
      name: 'sellerStatusVerificationRejectedBody',
      desc: '',
      args: [],
    );
  }

  /// `مطلوب معلومات إضافية قبل الموافقة.`
  String get sellerStatusVerificationNeedsInfoBody {
    return Intl.message(
      'مطلوب معلومات إضافية قبل الموافقة.',
      name: 'sellerStatusVerificationNeedsInfoBody',
      desc: '',
      args: [],
    );
  }

  /// `تبقى أدوات البائع مغلقة حتى تتم الموافقة على التوثيق.`
  String get sellerStatusWorkspaceWaitingBody {
    return Intl.message(
      'تبقى أدوات البائع مغلقة حتى تتم الموافقة على التوثيق.',
      name: 'sellerStatusWorkspaceWaitingBody',
      desc: '',
      args: [],
    );
  }

  /// `أدوات البائع مفعّلة لهذا الحساب.`
  String get sellerStatusWorkspaceApprovedBody {
    return Intl.message(
      'أدوات البائع مفعّلة لهذا الحساب.',
      name: 'sellerStatusWorkspaceApprovedBody',
      desc: '',
      args: [],
    );
  }

  /// `الوثائق المرسلة`
  String get sellerStatusDocumentsTitle {
    return Intl.message(
      'الوثائق المرسلة',
      name: 'sellerStatusDocumentsTitle',
      desc: '',
      args: [],
    );
  }

  /// `لا توجد وثائق تحقق مرفقة بعد.`
  String get sellerStatusDocumentsEmpty {
    return Intl.message(
      'لا توجد وثائق تحقق مرفقة بعد.',
      name: 'sellerStatusDocumentsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `آخر ملاحظات المراجعة`
  String get sellerStatusReviewFeedbackTitle {
    return Intl.message(
      'آخر ملاحظات المراجعة',
      name: 'sellerStatusReviewFeedbackTitle',
      desc: '',
      args: [],
    );
  }

  /// `ملاحظة المراجعة`
  String get sellerStatusRequirementsTitle {
    return Intl.message(
      'ملاحظة المراجعة',
      name: 'sellerStatusRequirementsTitle',
      desc: '',
      args: [],
    );
  }

  /// `تحديث الطلب`
  String get sellerStatusRestartApplication {
    return Intl.message(
      'تحديث الطلب',
      name: 'sellerStatusRestartApplication',
      desc: '',
      args: [],
    );
  }

  /// `العودة إلى الحساب`
  String get sellerStatusBackToProfile {
    return Intl.message(
      'العودة إلى الحساب',
      name: 'sellerStatusBackToProfile',
      desc: '',
      args: [],
    );
  }

  /// `مخزون البائع`
  String get sellerListingsEyebrow {
    return Intl.message(
      'مخزون البائع',
      name: 'sellerListingsEyebrow',
      desc: '',
      args: [],
    );
  }

  /// `إعلاناتي`
  String get sellerListingsTitle {
    return Intl.message(
      'إعلاناتي',
      name: 'sellerListingsTitle',
      desc: '',
      args: [],
    );
  }

  /// `راجع القطع النشطة المرتبطة بحساب البائع الخاص بك.`
  String get sellerListingsSubtitle {
    return Intl.message(
      'راجع القطع النشطة المرتبطة بحساب البائع الخاص بك.',
      name: 'sellerListingsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `لا توجد لديك إعلانات كبائع بعد.`
  String get sellerListingsEmptyBody {
    return Intl.message(
      'لا توجد لديك إعلانات كبائع بعد.',
      name: 'sellerListingsEmptyBody',
      desc: '',
      args: [],
    );
  }

  /// `معاينة`
  String get sellerListingsPreviewAction {
    return Intl.message(
      'معاينة',
      name: 'sellerListingsPreviewAction',
      desc: '',
      args: [],
    );
  }

  /// `تعذر تحميل إعلانات البائع حالياً.`
  String get sellerListingsErrorBody {
    return Intl.message(
      'تعذر تحميل إعلانات البائع حالياً.',
      name: 'sellerListingsErrorBody',
      desc: '',
      args: [],
    );
  }

  /// `شبه جديد`
  String get localListingConditionLikeNew {
    return Intl.message(
      'شبه جديد',
      name: 'localListingConditionLikeNew',
      desc: '',
      args: [],
    );
  }

  /// `جديد`
  String get localListingConditionNew {
    return Intl.message(
      'جديد',
      name: 'localListingConditionNew',
      desc: '',
      args: [],
    );
  }

  /// `بائع موثّق`
  String get localSellerLabelVerified {
    return Intl.message(
      'بائع موثّق',
      name: 'localSellerLabelVerified',
      desc: '',
      args: [],
    );
  }

  /// `بائع تجاري`
  String get localSellerLabelBusiness {
    return Intl.message(
      'بائع تجاري',
      name: 'localSellerLabelBusiness',
      desc: '',
      args: [],
    );
  }

  /// `أدخل بريداً إلكترونياً صحيحاً.`
  String get emailValidationError {
    return Intl.message(
      'أدخل بريداً إلكترونياً صحيحاً.',
      name: 'emailValidationError',
      desc: '',
      args: [],
    );
  }

  /// `يجب أن تتكون كلمة المرور من 8 أحرف على الأقل.`
  String get passwordValidationError {
    return Intl.message(
      'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل.',
      name: 'passwordValidationError',
      desc: '',
      args: [],
    );
  }

  /// `أدخل اسمك الكامل.`
  String get fullNameValidationError {
    return Intl.message(
      'أدخل اسمك الكامل.',
      name: 'fullNameValidationError',
      desc: '',
      args: [],
    );
  }

  /// `أدخل رقم هاتف جزائري صالحاً.`
  String get phoneValidationError {
    return Intl.message(
      'أدخل رقم هاتف جزائري صالحاً.',
      name: 'phoneValidationError',
      desc: '',
      args: [],
    );
  }

  /// `كلمتا المرور غير متطابقتين.`
  String get confirmPasswordValidationError {
    return Intl.message(
      'كلمتا المرور غير متطابقتين.',
      name: 'confirmPasswordValidationError',
      desc: '',
      args: [],
    );
  }

  /// `يجب قبول الشروط لإنشاء الحساب.`
  String get termsValidationError {
    return Intl.message(
      'يجب قبول الشروط لإنشاء الحساب.',
      name: 'termsValidationError',
      desc: '',
      args: [],
    );
  }

  /// `بيانات الدخول غير صحيحة أو الحساب غير متاح.`
  String get invalidCredentialsGeneric {
    return Intl.message(
      'بيانات الدخول غير صحيحة أو الحساب غير متاح.',
      name: 'invalidCredentialsGeneric',
      desc: '',
      args: [],
    );
  }

  /// `تعذر إنشاء الحساب.`
  String get createAccountFailure {
    return Intl.message(
      'تعذر إنشاء الحساب.',
      name: 'createAccountFailure',
      desc: '',
      args: [],
    );
  }

  /// `لم يتم العثور على الجلسة.`
  String get authErrorSessionNotFound {
    return Intl.message(
      'لم يتم العثور على الجلسة.',
      name: 'authErrorSessionNotFound',
      desc: '',
      args: [],
    );
  }

  /// `يرجى تأكيد بريدك الإلكتروني قبل تسجيل الدخول. تحقق من بريدك الوارد لرسالة التأكيد.`
  String get authErrorConfirmEmailBeforeSignIn {
    return Intl.message(
      'يرجى تأكيد بريدك الإلكتروني قبل تسجيل الدخول. تحقق من بريدك الوارد لرسالة التأكيد.',
      name: 'authErrorConfirmEmailBeforeSignIn',
      desc: '',
      args: [],
    );
  }

  /// `البريد الإلكتروني أو كلمة المرور غير صحيحة.`
  String get authErrorInvalidEmailOrPassword {
    return Intl.message(
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
      name: 'authErrorInvalidEmailOrPassword',
      desc: '',
      args: [],
    );
  }

  /// `تعذر تسجيل الدخول. حاول مرة أخرى.`
  String get authErrorUnableSignIn {
    return Intl.message(
      'تعذر تسجيل الدخول. حاول مرة أخرى.',
      name: 'authErrorUnableSignIn',
      desc: '',
      args: [],
    );
  }

  /// `الشبكة غير متاحة. تحقق من الاتصال ثم أعد المحاولة.`
  String get errorNetworkUnavailable {
    return Intl.message(
      'الشبكة غير متاحة. تحقق من الاتصال ثم أعد المحاولة.',
      name: 'errorNetworkUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `يوجد حساب مرتبط بهذا البريد الإلكتروني بالفعل.`
  String get authErrorEmailAlreadyExists {
    return Intl.message(
      'يوجد حساب مرتبط بهذا البريد الإلكتروني بالفعل.',
      name: 'authErrorEmailAlreadyExists',
      desc: '',
      args: [],
    );
  }

  /// `كلمة المرور لا تستوفي متطلبات الأمان.`
  String get authErrorPasswordRequirements {
    return Intl.message(
      'كلمة المرور لا تستوفي متطلبات الأمان.',
      name: 'authErrorPasswordRequirements',
      desc: '',
      args: [],
    );
  }

  /// `تم إنشاء الحساب، لكن إعداد الملف الشخصي تم حظره. حاول تسجيل الدخول مرة أخرى بعد تحديث الخلفية.`
  String get authErrorProfileSetupBlockedRls {
    return Intl.message(
      'تم إنشاء الحساب، لكن إعداد الملف الشخصي تم حظره. حاول تسجيل الدخول مرة أخرى بعد تحديث الخلفية.',
      name: 'authErrorProfileSetupBlockedRls',
      desc: '',
      args: [],
    );
  }

  /// `تم إنشاء الحساب، لكن إعداد الملف الشخصي محجوب بسبب سياسة في الخلفية.`
  String get authErrorProfileSetupBlockedPolicy {
    return Intl.message(
      'تم إنشاء الحساب، لكن إعداد الملف الشخصي محجوب بسبب سياسة في الخلفية.',
      name: 'authErrorProfileSetupBlockedPolicy',
      desc: '',
      args: [],
    );
  }

  /// `تم إنشاء الحساب. يرجى التحقق من بريدك الإلكتروني والضغط على رابط التأكيد قبل تسجيل الدخول.`
  String get authErrorCheckEmailConfirmation {
    return Intl.message(
      'تم إنشاء الحساب. يرجى التحقق من بريدك الإلكتروني والضغط على رابط التأكيد قبل تسجيل الدخول.',
      name: 'authErrorCheckEmailConfirmation',
      desc: '',
      args: [],
    );
  }

  /// `توثيق البائع`
  String get sellerOnboardingTitle {
    return Intl.message(
      'توثيق البائع',
      name: 'sellerOnboardingTitle',
      desc: '',
      args: [],
    );
  }

  /// `أرسل بيانات البائع مرة واحدة حتى نراجع هذا الحساب ونفعّل وصول البائع.`
  String get sellerOnboardingBody {
    return Intl.message(
      'أرسل بيانات البائع مرة واحدة حتى نراجع هذا الحساب ونفعّل وصول البائع.',
      name: 'sellerOnboardingBody',
      desc: '',
      args: [],
    );
  }

  /// `رجوع`
  String get sellerOnboardingBack {
    return Intl.message(
      'رجوع',
      name: 'sellerOnboardingBack',
      desc: '',
      args: [],
    );
  }

  /// `إرسال طلب التوثيق`
  String get sellerOnboardingSubmit {
    return Intl.message(
      'إرسال طلب التوثيق',
      name: 'sellerOnboardingSubmit',
      desc: '',
      args: [],
    );
  }

  /// `الخطوة 1 · نوع البائع`
  String get sellerOnboardingStepTypeTitle {
    return Intl.message(
      'الخطوة 1 · نوع البائع',
      name: 'sellerOnboardingStepTypeTitle',
      desc: '',
      args: [],
    );
  }

  /// `اختر ما إذا كنت تتقدم كبائع فردي أو كبائع نشاط تجاري.`
  String get sellerOnboardingStepTypeBody {
    return Intl.message(
      'اختر ما إذا كنت تتقدم كبائع فردي أو كبائع نشاط تجاري.',
      name: 'sellerOnboardingStepTypeBody',
      desc: '',
      args: [],
    );
  }

  /// `الخطوة 2 · الحساب والموقع`
  String get sellerOnboardingStepProfileTitle {
    return Intl.message(
      'الخطوة 2 · الحساب والموقع',
      name: 'sellerOnboardingStepProfileTitle',
      desc: '',
      args: [],
    );
  }

  /// `راجع بيانات الحساب المرتبطة بهذا الحساب ثم اختر موقع نشاطك.`
  String get sellerOnboardingStepProfileBody {
    return Intl.message(
      'راجع بيانات الحساب المرتبطة بهذا الحساب ثم اختر موقع نشاطك.',
      name: 'sellerOnboardingStepProfileBody',
      desc: '',
      args: [],
    );
  }

  /// `الخطوة 3 · الوثائق`
  String get sellerOnboardingStepDocumentsTitle {
    return Intl.message(
      'الخطوة 3 · الوثائق',
      name: 'sellerOnboardingStepDocumentsTitle',
      desc: '',
      args: [],
    );
  }

  /// `أرفق الوثائق المطلوبة بحسب نوع البائع.`
  String get sellerOnboardingStepDocumentsBody {
    return Intl.message(
      'أرفق الوثائق المطلوبة بحسب نوع البائع.',
      name: 'sellerOnboardingStepDocumentsBody',
      desc: '',
      args: [],
    );
  }

  /// `الخطوة 4 · الشروط`
  String get sellerOnboardingStepPolicyTitle {
    return Intl.message(
      'الخطوة 4 · الشروط',
      name: 'sellerOnboardingStepPolicyTitle',
      desc: '',
      args: [],
    );
  }

  /// `اقبل شروط البائع قبل إرسال الطلب.`
  String get sellerOnboardingStepPolicyBody {
    return Intl.message(
      'اقبل شروط البائع قبل إرسال الطلب.',
      name: 'sellerOnboardingStepPolicyBody',
      desc: '',
      args: [],
    );
  }

  /// `الخطوة 5 · التأكيد`
  String get sellerOnboardingStepConfirmationTitle {
    return Intl.message(
      'الخطوة 5 · التأكيد',
      name: 'sellerOnboardingStepConfirmationTitle',
      desc: '',
      args: [],
    );
  }

  /// `طلب توثيق البائع الآن قيد المراجعة.`
  String get sellerOnboardingStepConfirmationBody {
    return Intl.message(
      'طلب توثيق البائع الآن قيد المراجعة.',
      name: 'sellerOnboardingStepConfirmationBody',
      desc: '',
      args: [],
    );
  }

  /// `سيراجع فريقنا وثائقك خلال 24 إلى 48 ساعة. سنخطرك عندما يصبح وصول البائع جاهزاً.`
  String get sellerOnboardingConfirmationBody {
    return Intl.message(
      'سيراجع فريقنا وثائقك خلال 24 إلى 48 ساعة. سنخطرك عندما يصبح وصول البائع جاهزاً.',
      name: 'sellerOnboardingConfirmationBody',
      desc: '',
      args: [],
    );
  }

  /// `مراجعة خلال 24-48 ساعة`
  String get sellerOnboardingReviewWindow {
    return Intl.message(
      'مراجعة خلال 24-48 ساعة',
      name: 'sellerOnboardingReviewWindow',
      desc: '',
      args: [],
    );
  }

  /// `عرض حالة التوثيق`
  String get sellerOnboardingViewStatus {
    return Intl.message(
      'عرض حالة التوثيق',
      name: 'sellerOnboardingViewStatus',
      desc: '',
      args: [],
    );
  }

  /// `يتم استخدام اسم الحساب ورقم الهاتف تلقائياً في توثيق البائع.`
  String get sellerOnboardingAccountIdentityNote {
    return Intl.message(
      'يتم استخدام اسم الحساب ورقم الهاتف تلقائياً في توثيق البائع.',
      name: 'sellerOnboardingAccountIdentityNote',
      desc: '',
      args: [],
    );
  }

  /// `بطاقة الهوية (الوجه الأمامي)`
  String get sellerDocumentIdFrontLabel {
    return Intl.message(
      'بطاقة الهوية (الوجه الأمامي)',
      name: 'sellerDocumentIdFrontLabel',
      desc: '',
      args: [],
    );
  }

  /// `بطاقة الهوية (الوجه الخلفي)`
  String get sellerDocumentIdBackLabel {
    return Intl.message(
      'بطاقة الهوية (الوجه الخلفي)',
      name: 'sellerDocumentIdBackLabel',
      desc: '',
      args: [],
    );
  }

  /// `السجل التجاري`
  String get sellerDocumentBusinessRegistrationLabel {
    return Intl.message(
      'السجل التجاري',
      name: 'sellerDocumentBusinessRegistrationLabel',
      desc: '',
      args: [],
    );
  }

  /// `أرفق وثائق التحقق المطلوبة قبل الإرسال.`
  String get sellerOnboardingDocumentsRequired {
    return Intl.message(
      'أرفق وثائق التحقق المطلوبة قبل الإرسال.',
      name: 'sellerOnboardingDocumentsRequired',
      desc: '',
      args: [],
    );
  }

  /// `لا يوجد ملف مرفق بعد.`
  String get sellerOnboardingDocumentMissing {
    return Intl.message(
      'لا يوجد ملف مرفق بعد.',
      name: 'sellerOnboardingDocumentMissing',
      desc: '',
      args: [],
    );
  }

  /// `إرفاق وثيقة`
  String get sellerOnboardingDocumentAttachAction {
    return Intl.message(
      'إرفاق وثيقة',
      name: 'sellerOnboardingDocumentAttachAction',
      desc: '',
      args: [],
    );
  }

  /// `استبدال الوثيقة`
  String get sellerOnboardingDocumentReplaceAction {
    return Intl.message(
      'استبدال الوثيقة',
      name: 'sellerOnboardingDocumentReplaceAction',
      desc: '',
      args: [],
    );
  }

  /// `يتم حفظ وثائقك بشكل آمن ولا يطّلع عليها إلا فريق التحقق.`
  String get sellerOnboardingDocumentsPrivacyNote {
    return Intl.message(
      'يتم حفظ وثائقك بشكل آمن ولا يطّلع عليها إلا فريق التحقق.',
      name: 'sellerOnboardingDocumentsPrivacyNote',
      desc: '',
      args: [],
    );
  }

  /// `نوع البائع`
  String get sellerTypeLabel {
    return Intl.message(
      'نوع البائع',
      name: 'sellerTypeLabel',
      desc: '',
      args: [],
    );
  }

  /// `فرد`
  String get sellerTypeIndividual {
    return Intl.message(
      'فرد',
      name: 'sellerTypeIndividual',
      desc: '',
      args: [],
    );
  }

  /// `نشاط تجاري`
  String get sellerTypeBusiness {
    return Intl.message(
      'نشاط تجاري',
      name: 'sellerTypeBusiness',
      desc: '',
      args: [],
    );
  }

  /// `اختر البلدية.`
  String get sellerCommuneRequired {
    return Intl.message(
      'اختر البلدية.',
      name: 'sellerCommuneRequired',
      desc: '',
      args: [],
    );
  }

  /// `لوحة البائع`
  String get sellerDashboardTitle {
    return Intl.message(
      'لوحة البائع',
      name: 'sellerDashboardTitle',
      desc: '',
      args: [],
    );
  }

  /// `إنشاء إعلان`
  String get createListingCta {
    return Intl.message(
      'إنشاء إعلان',
      name: 'createListingCta',
      desc: '',
      args: [],
    );
  }

  /// `أضف توافق مركبة واحدة فقط لكل إعلان.`
  String get createListingSubtitle {
    return Intl.message(
      'أضف توافق مركبة واحدة فقط لكل إعلان.',
      name: 'createListingSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `زائر`
  String get profileRoleAnonymous {
    return Intl.message(
      'زائر',
      name: 'profileRoleAnonymous',
      desc: '',
      args: [],
    );
  }

  /// `مشتري`
  String get profileRoleBuyer {
    return Intl.message('مشتري', name: 'profileRoleBuyer', desc: '', args: []);
  }

  /// `بائع`
  String get profileRoleSeller {
    return Intl.message('بائع', name: 'profileRoleSeller', desc: '', args: []);
  }

  /// `مشرف`
  String get profileRoleAdmin {
    return Intl.message('مشرف', name: 'profileRoleAdmin', desc: '', args: []);
  }

  /// `مشرف عام`
  String get profileRoleSuperAdmin {
    return Intl.message(
      'مشرف عام',
      name: 'profileRoleSuperAdmin',
      desc: '',
      args: [],
    );
  }

  /// `تسجيل الخروج`
  String get signOutAction {
    return Intl.message(
      'تسجيل الخروج',
      name: 'signOutAction',
      desc: '',
      args: [],
    );
  }

  /// `تابع التوثيق والمخزون وحركة المعاملات الجارية.`
  String get sellerDashboardSubtitle {
    return Intl.message(
      'تابع التوثيق والمخزون وحركة المعاملات الجارية.',
      name: 'sellerDashboardSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `المعاملات المعلقة`
  String get sellerPendingDealsTitle {
    return Intl.message(
      'المعاملات المعلقة',
      name: 'sellerPendingDealsTitle',
      desc: '',
      args: [],
    );
  }

  /// `راجع نشاط المشترين المفتوح قبل أن يتعطل.`
  String get sellerPendingDealsBody {
    return Intl.message(
      'راجع نشاط المشترين المفتوح قبل أن يتعطل.',
      name: 'sellerPendingDealsBody',
      desc: '',
      args: [],
    );
  }

  /// `دورة المعاملة`
  String get sellerLifecycleTitle {
    return Intl.message(
      'دورة المعاملة',
      name: 'sellerLifecycleTitle',
      desc: '',
      args: [],
    );
  }

  /// `أدر الطلبات والقبول والإكمال بحالة واضحة.`
  String get sellerLifecycleBody {
    return Intl.message(
      'أدر الطلبات والقبول والإكمال بحالة واضحة.',
      name: 'sellerLifecycleBody',
      desc: '',
      args: [],
    );
  }

  /// `إجراء`
  String get sellerActionStatus {
    return Intl.message(
      'إجراء',
      name: 'sellerActionStatus',
      desc: '',
      args: [],
    );
  }

  /// `التشغيل`
  String get adminDashboardEyebrow {
    return Intl.message(
      'التشغيل',
      name: 'adminDashboardEyebrow',
      desc: '',
      args: [],
    );
  }

  /// `لوحة الإدارة`
  String get adminDashboardTitle {
    return Intl.message(
      'لوحة الإدارة',
      name: 'adminDashboardTitle',
      desc: '',
      args: [],
    );
  }

  /// `راجع طوابير التحقق والإعلانات والنزاعات والبلاغات من لوحة تشغيل واحدة.`
  String get adminDashboardSubtitle {
    return Intl.message(
      'راجع طوابير التحقق والإعلانات والنزاعات والبلاغات من لوحة تشغيل واحدة.',
      name: 'adminDashboardSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `توثيق البائعين`
  String get adminSellerVerificationsTitle {
    return Intl.message(
      'توثيق البائعين',
      name: 'adminSellerVerificationsTitle',
      desc: '',
      args: [],
    );
  }

  /// `راجع طلبات التوثيق وجودة الوثائق.`
  String get adminSellerVerificationsBody {
    return Intl.message(
      'راجع طلبات التوثيق وجودة الوثائق.',
      name: 'adminSellerVerificationsBody',
      desc: '',
      args: [],
    );
  }

  /// `مراجعات الإعلانات`
  String get adminListingReviewsTitle {
    return Intl.message(
      'مراجعات الإعلانات',
      name: 'adminListingReviewsTitle',
      desc: '',
      args: [],
    );
  }

  /// `راجع طابور الاعتدال ومخاطر التصنيف وسياق البائع.`
  String get adminListingReviewsBody {
    return Intl.message(
      'راجع طابور الاعتدال ومخاطر التصنيف وسياق البائع.',
      name: 'adminListingReviewsBody',
      desc: '',
      args: [],
    );
  }

  /// `قيد الانتظار`
  String get adminQueueStatus {
    return Intl.message(
      'قيد الانتظار',
      name: 'adminQueueStatus',
      desc: '',
      args: [],
    );
  }

  /// `الطوابير`
  String get adminQueuesTitle {
    return Intl.message(
      'الطوابير',
      name: 'adminQueuesTitle',
      desc: '',
      args: [],
    );
  }

  /// `افتح طوابير المراجعة التي تحتاج إلى متابعة تشغيلية من شاشة إدارة واحدة.`
  String get adminQueuesSubtitle {
    return Intl.message(
      'افتح طوابير المراجعة التي تحتاج إلى متابعة تشغيلية من شاشة إدارة واحدة.',
      name: 'adminQueuesSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `تعذر تحميل طوابير الإدارة. حاول مرة أخرى.`
  String get adminQueuesErrorBody {
    return Intl.message(
      'تعذر تحميل طوابير الإدارة. حاول مرة أخرى.',
      name: 'adminQueuesErrorBody',
      desc: '',
      args: [],
    );
  }

  /// `إعلان جديد`
  String get listingCreateTitle {
    return Intl.message(
      'إعلان جديد',
      name: 'listingCreateTitle',
      desc: '',
      args: [],
    );
  }

  /// `أضف بيانات المركبة المطابقة قبل نشر الإعلان.`
  String get listingOneVehicleHint {
    return Intl.message(
      'أضف بيانات المركبة المطابقة قبل نشر الإعلان.',
      name: 'listingOneVehicleHint',
      desc: '',
      args: [],
    );
  }

  /// `اسم القطعة`
  String get listingTitleLabel {
    return Intl.message(
      'اسم القطعة',
      name: 'listingTitleLabel',
      desc: '',
      args: [],
    );
  }

  /// `العلامة`
  String get brandLabel {
    return Intl.message('العلامة', name: 'brandLabel', desc: '', args: []);
  }

  /// `الموديل`
  String get modelLabel {
    return Intl.message('الموديل', name: 'modelLabel', desc: '', args: []);
  }

  /// `السنة`
  String get yearLabel {
    return Intl.message('السنة', name: 'yearLabel', desc: '', args: []);
  }

  /// `الولاية`
  String get wilayaLabel {
    return Intl.message('الولاية', name: 'wilayaLabel', desc: '', args: []);
  }

  /// `البلدية`
  String get communeLabel {
    return Intl.message('البلدية', name: 'communeLabel', desc: '', args: []);
  }

  /// `أدخل اسم القطعة.`
  String get listingTitleRequired {
    return Intl.message(
      'أدخل اسم القطعة.',
      name: 'listingTitleRequired',
      desc: '',
      args: [],
    );
  }

  /// `اختر الفئة.`
  String get listingCategoryRequired {
    return Intl.message(
      'اختر الفئة.',
      name: 'listingCategoryRequired',
      desc: '',
      args: [],
    );
  }

  /// `اختر الولاية.`
  String get listingWilayaRequired {
    return Intl.message(
      'اختر الولاية.',
      name: 'listingWilayaRequired',
      desc: '',
      args: [],
    );
  }

  /// `اختر العلامة.`
  String get listingMakeRequired {
    return Intl.message(
      'اختر العلامة.',
      name: 'listingMakeRequired',
      desc: '',
      args: [],
    );
  }

  /// `اختر الموديل.`
  String get listingModelRequired {
    return Intl.message(
      'اختر الموديل.',
      name: 'listingModelRequired',
      desc: '',
      args: [],
    );
  }

  /// `اختر السنة.`
  String get listingYearRequired {
    return Intl.message(
      'اختر السنة.',
      name: 'listingYearRequired',
      desc: '',
      args: [],
    );
  }

  /// `أدخل سعراً صحيحاً.`
  String get listingPriceError {
    return Intl.message(
      'أدخل سعراً صحيحاً.',
      name: 'listingPriceError',
      desc: '',
      args: [],
    );
  }

  /// `أدخل كمية صحيحة.`
  String get listingQuantityError {
    return Intl.message(
      'أدخل كمية صحيحة.',
      name: 'listingQuantityError',
      desc: '',
      args: [],
    );
  }

  /// `أدخل وصفاً.`
  String get listingDescriptionRequired {
    return Intl.message(
      'أدخل وصفاً.',
      name: 'listingDescriptionRequired',
      desc: '',
      args: [],
    );
  }

  /// `تم نشر الإعلان وإضافته إلى مخزونك.`
  String get listingPublishedSuccess {
    return Intl.message(
      'تم نشر الإعلان وإضافته إلى مخزونك.',
      name: 'listingPublishedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `تم حفظ المسودة في مخزون البائع.`
  String get listingDraftSavedSuccess {
    return Intl.message(
      'تم حفظ المسودة في مخزون البائع.',
      name: 'listingDraftSavedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `تم إرسال الإعلان للمراجعة.`
  String get listingSubmittedForReviewSuccess {
    return Intl.message(
      'تم إرسال الإعلان للمراجعة.',
      name: 'listingSubmittedForReviewSuccess',
      desc: '',
      args: [],
    );
  }

  /// `نشر الإعلان`
  String get listingPublishAction {
    return Intl.message(
      'نشر الإعلان',
      name: 'listingPublishAction',
      desc: '',
      args: [],
    );
  }

  /// `حفظ كمسودة`
  String get listingSaveDraftAction {
    return Intl.message(
      'حفظ كمسودة',
      name: 'listingSaveDraftAction',
      desc: '',
      args: [],
    );
  }

  /// `إرسال للمراجعة`
  String get listingSubmitForReviewAction {
    return Intl.message(
      'إرسال للمراجعة',
      name: 'listingSubmitForReviewAction',
      desc: '',
      args: [],
    );
  }

  /// `متطلبات الصور`
  String get listingMediaSectionTitle {
    return Intl.message(
      'متطلبات الصور',
      name: 'listingMediaSectionTitle',
      desc: '',
      args: [],
    );
  }

  /// `حضّر صوراً واضحة للقطعة قبل النشر.`
  String get listingMediaSectionBody {
    return Intl.message(
      'حضّر صوراً واضحة للقطعة قبل النشر.',
      name: 'listingMediaSectionBody',
      desc: '',
      args: [],
    );
  }

  /// `إضافة صور`
  String get listingMediaAttachAction {
    return Intl.message(
      'إضافة صور',
      name: 'listingMediaAttachAction',
      desc: '',
      args: [],
    );
  }

  /// `حذف الصورة`
  String get listingMediaRemoveAction {
    return Intl.message(
      'حذف الصورة',
      name: 'listingMediaRemoveAction',
      desc: '',
      args: [],
    );
  }

  /// `أضف صورة واحدة على الأقل للإعلان.`
  String get listingMediaRequired {
    return Intl.message(
      'أضف صورة واحدة على الأقل للإعلان.',
      name: 'listingMediaRequired',
      desc: '',
      args: [],
    );
  }

  /// `أضف صورتين على الأقل قبل إرسال الإعلان للمراجعة.`
  String get listingMediaMinimumRequired {
    return Intl.message(
      'أضف صورتين على الأقل قبل إرسال الإعلان للمراجعة.',
      name: 'listingMediaMinimumRequired',
      desc: '',
      args: [],
    );
  }

  /// `الرسائل`
  String get messagesTitle {
    return Intl.message('الرسائل', name: 'messagesTitle', desc: '', args: []);
  }

  /// `محادثة الإعلان`
  String get messagesConversationTitle {
    return Intl.message(
      'محادثة الإعلان',
      name: 'messagesConversationTitle',
      desc: '',
      args: [],
    );
  }

  /// `أبقِ نقاش المعاملة مرتبطاً بالإعلان وعبر الإنترنت فقط.`
  String get messagesConversationSubtitle {
    return Intl.message(
      'أبقِ نقاش المعاملة مرتبطاً بالإعلان وعبر الإنترنت فقط.',
      name: 'messagesConversationSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `لا توجد رسائل بعد`
  String get messagesEmptyTitle {
    return Intl.message(
      'لا توجد رسائل بعد',
      name: 'messagesEmptyTitle',
      desc: '',
      args: [],
    );
  }

  /// `محادثات الإعلانات`
  String get messagesInboxTitle {
    return Intl.message(
      'محادثات الإعلانات',
      name: 'messagesInboxTitle',
      desc: '',
      args: [],
    );
  }

  /// `كل محادثة تبقى مرتبطة بإعلان ونية تعامل نشطة.`
  String get messagesInboxSubtitle {
    return Intl.message(
      'كل محادثة تبقى مرتبطة بإعلان ونية تعامل نشطة.',
      name: 'messagesInboxSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `حالة الرسائل`
  String get messagesStatusLabel {
    return Intl.message(
      'حالة الرسائل',
      name: 'messagesStatusLabel',
      desc: '',
      args: [],
    );
  }

  /// `محجوب`
  String get messagesBlockedStatus {
    return Intl.message(
      'محجوب',
      name: 'messagesBlockedStatus',
      desc: '',
      args: [],
    );
  }

  /// `اكتب رسالة...`
  String get messagesInputHint {
    return Intl.message(
      'اكتب رسالة...',
      name: 'messagesInputHint',
      desc: '',
      args: [],
    );
  }

  /// `إرسال`
  String get messagesSend {
    return Intl.message('إرسال', name: 'messagesSend', desc: '', args: []);
  }

  /// `تعذّر إرسال الرسالة. يرجى المحاولة مرة أخرى.`
  String get messagesSendError {
    return Intl.message(
      'تعذّر إرسال الرسالة. يرجى المحاولة مرة أخرى.',
      name: 'messagesSendError',
      desc: '',
      args: [],
    );
  }

  /// `الرسائل متاحة عبر الإنترنت فقط حالياً.`
  String get messagesOnlineOnly {
    return Intl.message(
      'الرسائل متاحة عبر الإنترنت فقط حالياً.',
      name: 'messagesOnlineOnly',
      desc: '',
      args: [],
    );
  }

  /// `لا توجد محادثات مرتبطة بإعلانات بعد. ابدأ من الإعلان عندما تحتاج مراسلة البائع.`
  String get messagesInboxEmpty {
    return Intl.message(
      'لا توجد محادثات مرتبطة بإعلانات بعد. ابدأ من الإعلان عندما تحتاج مراسلة البائع.',
      name: 'messagesInboxEmpty',
      desc: '',
      args: [],
    );
  }

  /// `تصفح الإعلانات`
  String get messagesBrowseListingsAction {
    return Intl.message(
      'تصفح الإعلانات',
      name: 'messagesBrowseListingsAction',
      desc: '',
      args: [],
    );
  }

  /// `مفتوح`
  String get messagesOpenStatus {
    return Intl.message(
      'مفتوح',
      name: 'messagesOpenStatus',
      desc: '',
      args: [],
    );
  }

  /// `قيّم هذه المعاملة`
  String get ratingTitle {
    return Intl.message(
      'قيّم هذه المعاملة',
      name: 'ratingTitle',
      desc: '',
      args: [],
    );
  }

  /// `إرسال التقييم`
  String get ratingSubmit {
    return Intl.message(
      'إرسال التقييم',
      name: 'ratingSubmit',
      desc: '',
      args: [],
    );
  }

  /// `تم إرسال التقييم.`
  String get ratingSubmitted {
    return Intl.message(
      'تم إرسال التقييم.',
      name: 'ratingSubmitted',
      desc: '',
      args: [],
    );
  }

  /// `تم إرسال تقييم سابق لهذه المعاملة.`
  String get ratingAlreadySubmitted {
    return Intl.message(
      'تم إرسال تقييم سابق لهذه المعاملة.',
      name: 'ratingAlreadySubmitted',
      desc: '',
      args: [],
    );
  }

  /// `يسمح بالتقييم فقط بعد اكتمال المعاملة.`
  String get ratingRequiresCompletedTransaction {
    return Intl.message(
      'يسمح بالتقييم فقط بعد اكتمال المعاملة.',
      name: 'ratingRequiresCompletedTransaction',
      desc: '',
      args: [],
    );
  }

  /// `حلقة الثقة`
  String get ratingContextEyebrow {
    return Intl.message(
      'حلقة الثقة',
      name: 'ratingContextEyebrow',
      desc: '',
      args: [],
    );
  }

  /// `سياق الصفقة`
  String get ratingContextTitle {
    return Intl.message(
      'سياق الصفقة',
      name: 'ratingContextTitle',
      desc: '',
      args: [],
    );
  }

  /// `أكد اكتمال الصفقة قبل تقييم الطرف المقابل.`
  String get ratingContextSubtitle {
    return Intl.message(
      'أكد اكتمال الصفقة قبل تقييم الطرف المقابل.',
      name: 'ratingContextSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `الإعلان المرتبط`
  String get ratingListingContextValue {
    return Intl.message(
      'الإعلان المرتبط',
      name: 'ratingListingContextValue',
      desc: '',
      args: [],
    );
  }

  /// `يجري تحميل سياق الإعلان`
  String get ratingListingContextFallback {
    return Intl.message(
      'يجري تحميل سياق الإعلان',
      name: 'ratingListingContextFallback',
      desc: '',
      args: [],
    );
  }

  /// `ما زلنا نستخرج الإعلان المرتبط بهذه الصفقة.`
  String get ratingListingContextPending {
    return Intl.message(
      'ما زلنا نستخرج الإعلان المرتبط بهذه الصفقة.',
      name: 'ratingListingContextPending',
      desc: '',
      args: [],
    );
  }

  /// `الطرف المقابل`
  String get ratingCounterpartyPending {
    return Intl.message(
      'الطرف المقابل',
      name: 'ratingCounterpartyPending',
      desc: '',
      args: [],
    );
  }

  /// `ابحث بالقطعة أو العلامة أو المركبة`
  String get discoverySearchHint {
    return Intl.message(
      'ابحث بالقطعة أو العلامة أو المركبة',
      name: 'discoverySearchHint',
      desc: '',
      args: [],
    );
  }

  /// `تصفية`
  String get discoveryFilterButton {
    return Intl.message(
      'تصفية',
      name: 'discoveryFilterButton',
      desc: '',
      args: [],
    );
  }

  /// `بحث`
  String get discoverySearchButton {
    return Intl.message(
      'بحث',
      name: 'discoverySearchButton',
      desc: '',
      args: [],
    );
  }

  /// `إعلانات مميزة`
  String get discoveryFeaturedListingsTitle {
    return Intl.message(
      'إعلانات مميزة',
      name: 'discoveryFeaturedListingsTitle',
      desc: '',
      args: [],
    );
  }

  /// `أحدث الإعلانات`
  String get discoveryLatestListingsTitle {
    return Intl.message(
      'أحدث الإعلانات',
      name: 'discoveryLatestListingsTitle',
      desc: '',
      args: [],
    );
  }

  /// `التصفية`
  String get discoveryFiltersTitle {
    return Intl.message(
      'التصفية',
      name: 'discoveryFiltersTitle',
      desc: '',
      args: [],
    );
  }

  /// `حدّد الفئة والموقع وتفاصيل المركبة.`
  String get discoveryFiltersSubtitle {
    return Intl.message(
      'حدّد الفئة والموقع وتفاصيل المركبة.',
      name: 'discoveryFiltersSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `تعديل التصفية`
  String get discoveryEditFiltersButton {
    return Intl.message(
      'تعديل التصفية',
      name: 'discoveryEditFiltersButton',
      desc: '',
      args: [],
    );
  }

  /// `يتفعّل بعد اختيار الولاية.`
  String get discoveryFilterCommuneHelper {
    return Intl.message(
      'يتفعّل بعد اختيار الولاية.',
      name: 'discoveryFilterCommuneHelper',
      desc: '',
      args: [],
    );
  }

  /// `يتفعّل بعد اختيار العلامة.`
  String get discoveryFilterModelHelper {
    return Intl.message(
      'يتفعّل بعد اختيار العلامة.',
      name: 'discoveryFilterModelHelper',
      desc: '',
      args: [],
    );
  }

  /// `يتفعّل بعد اختيار الموديل.`
  String get discoveryFilterYearHelper {
    return Intl.message(
      'يتفعّل بعد اختيار الموديل.',
      name: 'discoveryFilterYearHelper',
      desc: '',
      args: [],
    );
  }

  /// `السعر الأدنى`
  String get discoveryMinPriceLabel {
    return Intl.message(
      'السعر الأدنى',
      name: 'discoveryMinPriceLabel',
      desc: '',
      args: [],
    );
  }

  /// `السعر الأقصى`
  String get discoveryMaxPriceLabel {
    return Intl.message(
      'السعر الأقصى',
      name: 'discoveryMaxPriceLabel',
      desc: '',
      args: [],
    );
  }

  /// `الحالة`
  String get discoveryConditionFieldLabel {
    return Intl.message(
      'الحالة',
      name: 'discoveryConditionFieldLabel',
      desc: '',
      args: [],
    );
  }

  /// `نوع العملية`
  String get discoveryDealTypeFieldLabel {
    return Intl.message(
      'نوع العملية',
      name: 'discoveryDealTypeFieldLabel',
      desc: '',
      args: [],
    );
  }

  /// `الترتيب`
  String get discoverySortFieldLabel {
    return Intl.message(
      'الترتيب',
      name: 'discoverySortFieldLabel',
      desc: '',
      args: [],
    );
  }

  /// `إعادة ضبط`
  String get discoveryResetFiltersButton {
    return Intl.message(
      'إعادة ضبط',
      name: 'discoveryResetFiltersButton',
      desc: '',
      args: [],
    );
  }

  /// `تطبيق`
  String get discoveryApplyFiltersButton {
    return Intl.message(
      'تطبيق',
      name: 'discoveryApplyFiltersButton',
      desc: '',
      args: [],
    );
  }

  /// `مستعمل`
  String get discoveryConditionUsed {
    return Intl.message(
      'مستعمل',
      name: 'discoveryConditionUsed',
      desc: '',
      args: [],
    );
  }

  /// `شراء`
  String get discoveryDealTypeBuy {
    return Intl.message(
      'شراء',
      name: 'discoveryDealTypeBuy',
      desc: '',
      args: [],
    );
  }

  /// `شراء أو تبديل إذا كان متاحاً`
  String get discoveryDealTypeBuyOrExchange {
    return Intl.message(
      'شراء أو تبديل إذا كان متاحاً',
      name: 'discoveryDealTypeBuyOrExchange',
      desc: '',
      args: [],
    );
  }

  /// `الأحدث`
  String get discoverySortNewest {
    return Intl.message(
      'الأحدث',
      name: 'discoverySortNewest',
      desc: '',
      args: [],
    );
  }

  /// `الإنارة`
  String get discoveryFilterLighting {
    return Intl.message(
      'الإنارة',
      name: 'discoveryFilterLighting',
      desc: '',
      args: [],
    );
  }

  /// `المحرك والإشعال`
  String get categoryEngineIgnition {
    return Intl.message(
      'المحرك والإشعال',
      name: 'categoryEngineIgnition',
      desc: '',
      args: [],
    );
  }

  /// `نظام التبريد`
  String get categoryCoolingSystem {
    return Intl.message(
      'نظام التبريد',
      name: 'categoryCoolingSystem',
      desc: '',
      args: [],
    );
  }

  /// `الكهرباء والإلكترونيات`
  String get categoryElectricalElectronics {
    return Intl.message(
      'الكهرباء والإلكترونيات',
      name: 'categoryElectricalElectronics',
      desc: '',
      args: [],
    );
  }

  /// `الهيكل والخارجية`
  String get categoryBodyExterior {
    return Intl.message(
      'الهيكل والخارجية',
      name: 'categoryBodyExterior',
      desc: '',
      args: [],
    );
  }

  /// `الداخلية وأدوات التحكم`
  String get categoryInteriorControls {
    return Intl.message(
      'الداخلية وأدوات التحكم',
      name: 'categoryInteriorControls',
      desc: '',
      args: [],
    );
  }

  /// `التعليق والتوجيه`
  String get categorySuspensionSteering {
    return Intl.message(
      'التعليق والتوجيه',
      name: 'categorySuspensionSteering',
      desc: '',
      args: [],
    );
  }

  /// `ناقل الحركة ونظام الدفع`
  String get categoryTransmissionDrivetrain {
    return Intl.message(
      'ناقل الحركة ونظام الدفع',
      name: 'categoryTransmissionDrivetrain',
      desc: '',
      args: [],
    );
  }

  /// `الفلاتر والصيانة الدورية`
  String get categoryFiltersMaintenance {
    return Intl.message(
      'الفلاتر والصيانة الدورية',
      name: 'categoryFiltersMaintenance',
      desc: '',
      args: [],
    );
  }

  /// `العجلات والإطارات`
  String get categoryWheelsTires {
    return Intl.message(
      'العجلات والإطارات',
      name: 'categoryWheelsTires',
      desc: '',
      args: [],
    );
  }

  /// `نظام الفرامل`
  String get categoryBraking {
    return Intl.message(
      'نظام الفرامل',
      name: 'categoryBraking',
      desc: '',
      args: [],
    );
  }

  /// `العادم والانبعاثات`
  String get categoryExhaustEmissions {
    return Intl.message(
      'العادم والانبعاثات',
      name: 'categoryExhaustEmissions',
      desc: '',
      args: [],
    );
  }

  /// `لا توجد إعلانات بعد`
  String get discoveryEmptyTitle {
    return Intl.message(
      'لا توجد إعلانات بعد',
      name: 'discoveryEmptyTitle',
      desc: '',
      args: [],
    );
  }

  /// `عند توفر مخزون فعلي في السوق الإنتاجي ستظهر الإعلانات هنا.`
  String get discoveryEmptyBody {
    return Intl.message(
      'عند توفر مخزون فعلي في السوق الإنتاجي ستظهر الإعلانات هنا.',
      name: 'discoveryEmptyBody',
      desc: '',
      args: [],
    );
  }

  /// `تعذر تحميل إعلانات السوق. حاول مرة أخرى.`
  String get discoveryErrorBody {
    return Intl.message(
      'تعذر تحميل إعلانات السوق. حاول مرة أخرى.',
      name: 'discoveryErrorBody',
      desc: '',
      args: [],
    );
  }

  /// `تعذر تحميل خيارات التصفية. حاول مرة أخرى.`
  String get discoveryFilterErrorBody {
    return Intl.message(
      'تعذر تحميل خيارات التصفية. حاول مرة أخرى.',
      name: 'discoveryFilterErrorBody',
      desc: '',
      args: [],
    );
  }

  /// `حفظ`
  String get discoverySave {
    return Intl.message('حفظ', name: 'discoverySave', desc: '', args: []);
  }

  /// `مراسلة البائع`
  String get discoveryMessageSeller {
    return Intl.message(
      'مراسلة البائع',
      name: 'discoveryMessageSeller',
      desc: '',
      args: [],
    );
  }

  /// `نتائج`
  String get searchResultsSuffix {
    return Intl.message(
      'نتائج',
      name: 'searchResultsSuffix',
      desc: '',
      args: [],
    );
  }

  /// `الفئة`
  String get categoryLabel {
    return Intl.message('الفئة', name: 'categoryLabel', desc: '', args: []);
  }

  /// `تفاصيل الإعلان`
  String get listingDetailEyebrow {
    return Intl.message(
      'تفاصيل الإعلان',
      name: 'listingDetailEyebrow',
      desc: '',
      args: [],
    );
  }

  /// `إعلاني`
  String get sellerOwnedListingEyebrow {
    return Intl.message(
      'إعلاني',
      name: 'sellerOwnedListingEyebrow',
      desc: '',
      args: [],
    );
  }

  /// `السعر`
  String get listingPriceLabel {
    return Intl.message('السعر', name: 'listingPriceLabel', desc: '', args: []);
  }

  /// `معلومات القطعة`
  String get listingPartDetailsTitle {
    return Intl.message(
      'معلومات القطعة',
      name: 'listingPartDetailsTitle',
      desc: '',
      args: [],
    );
  }

  /// `الوصف`
  String get listingDescriptionTitle {
    return Intl.message(
      'الوصف',
      name: 'listingDescriptionTitle',
      desc: '',
      args: [],
    );
  }

  /// `البائع`
  String get listingSellerSectionTitle {
    return Intl.message(
      'البائع',
      name: 'listingSellerSectionTitle',
      desc: '',
      args: [],
    );
  }

  /// `الكمية`
  String get quantityLabel {
    return Intl.message('الكمية', name: 'quantityLabel', desc: '', args: []);
  }

  /// `الحالة`
  String get listingStatusLabel {
    return Intl.message(
      'الحالة',
      name: 'listingStatusLabel',
      desc: '',
      args: [],
    );
  }

  /// `التبادل مفعّل`
  String get listingExchangeEnabled {
    return Intl.message(
      'التبادل مفعّل',
      name: 'listingExchangeEnabled',
      desc: '',
      args: [],
    );
  }

  /// `منطقة الاستلام`
  String get listingLocationLabel {
    return Intl.message(
      'منطقة الاستلام',
      name: 'listingLocationLabel',
      desc: '',
      args: [],
    );
  }

  /// `الخطوة التالية`
  String get listingActionDockTitle {
    return Intl.message(
      'الخطوة التالية',
      name: 'listingActionDockTitle',
      desc: '',
      args: [],
    );
  }

  /// `تعديل الإعلان`
  String get listingEditAction {
    return Intl.message(
      'تعديل الإعلان',
      name: 'listingEditAction',
      desc: '',
      args: [],
    );
  }

  /// `طلب شراء`
  String get listingRequestToBuyAction {
    return Intl.message(
      'طلب شراء',
      name: 'listingRequestToBuyAction',
      desc: '',
      args: [],
    );
  }

  /// `مشاركة الإعلان`
  String get listingShareAction {
    return Intl.message(
      'مشاركة الإعلان',
      name: 'listingShareAction',
      desc: '',
      args: [],
    );
  }

  /// `الإعلان غير متاح`
  String get listingUnavailableTitle {
    return Intl.message(
      'الإعلان غير متاح',
      name: 'listingUnavailableTitle',
      desc: '',
      args: [],
    );
  }

  /// `هذا الإعلان لم يعد متاحاً أو لا يمكن فتحه حالياً.`
  String get listingUnavailableBody {
    return Intl.message(
      'هذا الإعلان لم يعد متاحاً أو لا يمكن فتحه حالياً.',
      name: 'listingUnavailableBody',
      desc: '',
      args: [],
    );
  }

  /// `المحفوظات`
  String get savedListingsEyebrow {
    return Intl.message(
      'المحفوظات',
      name: 'savedListingsEyebrow',
      desc: '',
      args: [],
    );
  }

  /// `الإعلانات المحفوظة`
  String get savedListingsTitle {
    return Intl.message(
      'الإعلانات المحفوظة',
      name: 'savedListingsTitle',
      desc: '',
      args: [],
    );
  }

  /// `احتفظ بقائمة قصيرة للقطع التي قد تعود إليها لاحقاً.`
  String get savedListingsSubtitle {
    return Intl.message(
      'احتفظ بقائمة قصيرة للقطع التي قد تعود إليها لاحقاً.',
      name: 'savedListingsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `لا توجد إعلانات محفوظة بعد. تصفح السوق واحفظ القطع التي تهمك.`
  String get savedListingsEmptyBody {
    return Intl.message(
      'لا توجد إعلانات محفوظة بعد. تصفح السوق واحفظ القطع التي تهمك.',
      name: 'savedListingsEmptyBody',
      desc: '',
      args: [],
    );
  }

  /// `تصفح الإعلانات`
  String get savedListingsBrowseAction {
    return Intl.message(
      'تصفح الإعلانات',
      name: 'savedListingsBrowseAction',
      desc: '',
      args: [],
    );
  }

  /// `إزالة`
  String get savedListingsRemoveAction {
    return Intl.message(
      'إزالة',
      name: 'savedListingsRemoveAction',
      desc: '',
      args: [],
    );
  }

  /// `تعذر تحميل الإعلانات المحفوظة حالياً.`
  String get savedListingsErrorBody {
    return Intl.message(
      'تعذر تحميل الإعلانات المحفوظة حالياً.',
      name: 'savedListingsErrorBody',
      desc: '',
      args: [],
    );
  }

  /// `أنت غير متصل`
  String get offlineBannerLabel {
    return Intl.message(
      'أنت غير متصل',
      name: 'offlineBannerLabel',
      desc: '',
      args: [],
    );
  }

  /// `الوارد`
  String get notificationsEyebrow {
    return Intl.message(
      'الوارد',
      name: 'notificationsEyebrow',
      desc: '',
      args: [],
    );
  }

  /// `الإشعارات`
  String get notificationsTitle {
    return Intl.message(
      'الإشعارات',
      name: 'notificationsTitle',
      desc: '',
      args: [],
    );
  }

  /// `تفضيلات الإشعارات`
  String get notificationPreferencesTitle {
    return Intl.message(
      'تفضيلات الإشعارات',
      name: 'notificationPreferencesTitle',
      desc: '',
      args: [],
    );
  }

  /// `اختر أي تحديثات للحساب والمعاملة والإعلانات المحفوظة يمكن أن تصلك.`
  String get notificationPreferencesSubtitle {
    return Intl.message(
      'اختر أي تحديثات للحساب والمعاملة والإعلانات المحفوظة يمكن أن تصلك.',
      name: 'notificationPreferencesSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `إشعارات فورية للرسائل الجديدة`
  String get notificationPreferenceMessages {
    return Intl.message(
      'إشعارات فورية للرسائل الجديدة',
      name: 'notificationPreferenceMessages',
      desc: '',
      args: [],
    );
  }

  /// `إشعارات فورية لتحديثات المعاملة`
  String get notificationPreferenceDealPush {
    return Intl.message(
      'إشعارات فورية لتحديثات المعاملة',
      name: 'notificationPreferenceDealPush',
      desc: '',
      args: [],
    );
  }

  /// `إشعارات فورية لتغييرات الإعلانات المحفوظة`
  String get notificationPreferenceSavedListingPush {
    return Intl.message(
      'إشعارات فورية لتغييرات الإعلانات المحفوظة',
      name: 'notificationPreferenceSavedListingPush',
      desc: '',
      args: [],
    );
  }

  /// `بريد إلكتروني لتحديثات الحساب`
  String get notificationPreferenceAccountEmail {
    return Intl.message(
      'بريد إلكتروني لتحديثات الحساب',
      name: 'notificationPreferenceAccountEmail',
      desc: '',
      args: [],
    );
  }

  /// `بريد إلكتروني لتحديثات المعاملة والنزاع`
  String get notificationPreferenceDealEmail {
    return Intl.message(
      'بريد إلكتروني لتحديثات المعاملة والنزاع',
      name: 'notificationPreferenceDealEmail',
      desc: '',
      args: [],
    );
  }

  /// `تابع الرسائل وتغييرات الإعلانات وإجراءات الحساب من مكان واحد.`
  String get notificationsSubtitle {
    return Intl.message(
      'تابع الرسائل وتغييرات الإعلانات وإجراءات الحساب من مكان واحد.',
      name: 'notificationsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `لا توجد إشعارات بعد. ستظهر هنا أحداث الحساب والرسائل والإعلانات الجديدة.`
  String get notificationsEmptyBody {
    return Intl.message(
      'لا توجد إشعارات بعد. ستظهر هنا أحداث الحساب والرسائل والإعلانات الجديدة.',
      name: 'notificationsEmptyBody',
      desc: '',
      args: [],
    );
  }

  /// `تعليم الكل كمقروء`
  String get notificationsMarkAllRead {
    return Intl.message(
      'تعليم الكل كمقروء',
      name: 'notificationsMarkAllRead',
      desc: '',
      args: [],
    );
  }

  /// `تعليم كمقروء`
  String get notificationsMarkRead {
    return Intl.message(
      'تعليم كمقروء',
      name: 'notificationsMarkRead',
      desc: '',
      args: [],
    );
  }

  /// `تعليم كغير مقروء`
  String get notificationsMarkUnread {
    return Intl.message(
      'تعليم كغير مقروء',
      name: 'notificationsMarkUnread',
      desc: '',
      args: [],
    );
  }

  /// `كل الإشعارات محدّثة بالفعل.`
  String get notificationsAllCaughtUp {
    return Intl.message(
      'كل الإشعارات محدّثة بالفعل.',
      name: 'notificationsAllCaughtUp',
      desc: '',
      args: [],
    );
  }

  /// `تعذر تحميل الإشعارات حالياً.`
  String get notificationsErrorBody {
    return Intl.message(
      'تعذر تحميل الإشعارات حالياً.',
      name: 'notificationsErrorBody',
      desc: '',
      args: [],
    );
  }

  /// `رسالة جديدة على إعلانك المحفوظ`
  String get notificationsSavedMessageTitle {
    return Intl.message(
      'رسالة جديدة على إعلانك المحفوظ',
      name: 'notificationsSavedMessageTitle',
      desc: '',
      args: [],
    );
  }

  /// `ردّ بائع موثّق على أحد إعلاناتك المحفوظة.`
  String get notificationsSavedMessageBody {
    return Intl.message(
      'ردّ بائع موثّق على أحد إعلاناتك المحفوظة.',
      name: 'notificationsSavedMessageBody',
      desc: '',
      args: [],
    );
  }

  /// `رسالة`
  String get notificationsCategoryMessage {
    return Intl.message(
      'رسالة',
      name: 'notificationsCategoryMessage',
      desc: '',
      args: [],
    );
  }

  /// `إعلان`
  String get notificationsCategoryListing {
    return Intl.message(
      'إعلان',
      name: 'notificationsCategoryListing',
      desc: '',
      args: [],
    );
  }

  /// `معاملة`
  String get notificationsCategoryTransaction {
    return Intl.message(
      'معاملة',
      name: 'notificationsCategoryTransaction',
      desc: '',
      args: [],
    );
  }

  /// `التحقق`
  String get notificationsCategoryVerification {
    return Intl.message(
      'التحقق',
      name: 'notificationsCategoryVerification',
      desc: '',
      args: [],
    );
  }

  /// `نزاع`
  String get notificationsCategoryDispute {
    return Intl.message(
      'نزاع',
      name: 'notificationsCategoryDispute',
      desc: '',
      args: [],
    );
  }

  /// `النظام`
  String get notificationsCategorySystem {
    return Intl.message(
      'النظام',
      name: 'notificationsCategorySystem',
      desc: '',
      args: [],
    );
  }

  /// `تمت الموافقة على الإعلان`
  String get notificationsListingApprovedTitle {
    return Intl.message(
      'تمت الموافقة على الإعلان',
      name: 'notificationsListingApprovedTitle',
      desc: '',
      args: [],
    );
  }

  /// `تم رفض الإعلان`
  String get notificationsListingRejectedTitle {
    return Intl.message(
      'تم رفض الإعلان',
      name: 'notificationsListingRejectedTitle',
      desc: '',
      args: [],
    );
  }

  /// `تحديث على المعاملة`
  String get notificationsDealUpdateTitle {
    return Intl.message(
      'تحديث على المعاملة',
      name: 'notificationsDealUpdateTitle',
      desc: '',
      args: [],
    );
  }

  /// `منذ دقيقتين`
  String get notificationsTime2mAgo {
    return Intl.message(
      'منذ دقيقتين',
      name: 'notificationsTime2mAgo',
      desc: '',
      args: [],
    );
  }

  /// `منذ ساعة`
  String get notificationsTime1hAgo {
    return Intl.message(
      'منذ ساعة',
      name: 'notificationsTime1hAgo',
      desc: '',
      args: [],
    );
  }

  /// `{count} س`
  String notificationsTimeHoursShort(Object count) {
    return Intl.message(
      '$count س',
      name: 'notificationsTimeHoursShort',
      desc: '',
      args: [count],
    );
  }

  /// `{count} ي`
  String notificationsTimeDaysShort(Object count) {
    return Intl.message(
      '$count ي',
      name: 'notificationsTimeDaysShort',
      desc: '',
      args: [count],
    );
  }

  /// `لا توجد نتائج لهذا الحد الأدنى من التقييم.`
  String get noResultsTitle {
    return Intl.message(
      'لا توجد نتائج لهذا الحد الأدنى من التقييم.',
      name: 'noResultsTitle',
      desc: '',
      args: [],
    );
  }

  /// `اخفض الحد الأدنى للتقييم لرؤية نتائج أكثر.`
  String get noResultsBody {
    return Intl.message(
      'اخفض الحد الأدنى للتقييم لرؤية نتائج أكثر.',
      name: 'noResultsBody',
      desc: '',
      args: [],
    );
  }

  /// `لا توجد رسائل بعد. ابدأ المحادثة.`
  String get messagesEmptyState {
    return Intl.message(
      'لا توجد رسائل بعد. ابدأ المحادثة.',
      name: 'messagesEmptyState',
      desc: '',
      args: [],
    );
  }

  /// `التقييم`
  String get ratingScoreLabel {
    return Intl.message(
      'التقييم',
      name: 'ratingScoreLabel',
      desc: '',
      args: [],
    );
  }

  /// `بدء معاملة`
  String get transactionStartTitle {
    return Intl.message(
      'بدء معاملة',
      name: 'transactionStartTitle',
      desc: '',
      args: [],
    );
  }

  /// `أنشئ طلب معاملة مع البائع لهذا الإعلان.`
  String get transactionStartBody {
    return Intl.message(
      'أنشئ طلب معاملة مع البائع لهذا الإعلان.',
      name: 'transactionStartBody',
      desc: '',
      args: [],
    );
  }

  /// `طلب القطعة`
  String get requestPartCta {
    return Intl.message(
      'طلب القطعة',
      name: 'requestPartCta',
      desc: '',
      args: [],
    );
  }

  /// `الإعلان`
  String get transactionListingContextLabel {
    return Intl.message(
      'الإعلان',
      name: 'transactionListingContextLabel',
      desc: '',
      args: [],
    );
  }

  /// `سياق البائع`
  String get transactionSellerContextLabel {
    return Intl.message(
      'سياق البائع',
      name: 'transactionSellerContextLabel',
      desc: '',
      args: [],
    );
  }

  /// `المعاملة محجوبة`
  String get transactionBlockedTitle {
    return Intl.message(
      'المعاملة محجوبة',
      name: 'transactionBlockedTitle',
      desc: '',
      args: [],
    );
  }

  /// `الإعلان غير متاح`
  String get transactionListingUnavailableTitle {
    return Intl.message(
      'الإعلان غير متاح',
      name: 'transactionListingUnavailableTitle',
      desc: '',
      args: [],
    );
  }

  /// `لا يمكن استخدام هذا الإعلان لبدء معاملة الآن.`
  String get transactionListingUnavailableBody {
    return Intl.message(
      'لا يمكن استخدام هذا الإعلان لبدء معاملة الآن.',
      name: 'transactionListingUnavailableBody',
      desc: '',
      args: [],
    );
  }

  /// `تم إنشاء طلب المعاملة.`
  String get transactionIntentCreated {
    return Intl.message(
      'تم إنشاء طلب المعاملة.',
      name: 'transactionIntentCreated',
      desc: '',
      args: [],
    );
  }

  /// `يوجد طلب معاملة مفتوح بالفعل لهذا الإعلان.`
  String get transactionOpenIntentExists {
    return Intl.message(
      'يوجد طلب معاملة مفتوح بالفعل لهذا الإعلان.',
      name: 'transactionOpenIntentExists',
      desc: '',
      args: [],
    );
  }

  /// `المعاملات`
  String get transactionsTitle {
    return Intl.message(
      'المعاملات',
      name: 'transactionsTitle',
      desc: '',
      args: [],
    );
  }

  /// `لا توجد معاملات بعد.`
  String get transactionsEmpty {
    return Intl.message(
      'لا توجد معاملات بعد.',
      name: 'transactionsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `سجل المعاملات`
  String get transactionHistoryTitle {
    return Intl.message(
      'سجل المعاملات',
      name: 'transactionHistoryTitle',
      desc: '',
      args: [],
    );
  }

  /// `لا توجد صفقات بعد`
  String get transactionHistoryEmpty {
    return Intl.message(
      'لا توجد صفقات بعد',
      name: 'transactionHistoryEmpty',
      desc: '',
      args: [],
    );
  }

  /// `راجع الطلبات النشطة وحالات القبول والإكمال.`
  String get transactionLifecycleSubtitle {
    return Intl.message(
      'راجع الطلبات النشطة وحالات القبول والإكمال.',
      name: 'transactionLifecycleSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `سجل المعاملة`
  String get transactionRecordLabel {
    return Intl.message(
      'سجل المعاملة',
      name: 'transactionRecordLabel',
      desc: '',
      args: [],
    );
  }

  /// `طلب مفتوح`
  String get transactionStateRequested {
    return Intl.message(
      'طلب مفتوح',
      name: 'transactionStateRequested',
      desc: '',
      args: [],
    );
  }

  /// `تم القبول`
  String get transactionStateAccepted {
    return Intl.message(
      'تم القبول',
      name: 'transactionStateAccepted',
      desc: '',
      args: [],
    );
  }

  /// `مكتملة`
  String get transactionStateCompleted {
    return Intl.message(
      'مكتملة',
      name: 'transactionStateCompleted',
      desc: '',
      args: [],
    );
  }

  /// `ملغاة`
  String get transactionStateCancelled {
    return Intl.message(
      'ملغاة',
      name: 'transactionStateCancelled',
      desc: '',
      args: [],
    );
  }

  /// `مرفوضة`
  String get transactionStateRejected {
    return Intl.message(
      'مرفوضة',
      name: 'transactionStateRejected',
      desc: '',
      args: [],
    );
  }

  /// `قبول`
  String get transactionAccept {
    return Intl.message('قبول', name: 'transactionAccept', desc: '', args: []);
  }

  /// `إكمال`
  String get transactionComplete {
    return Intl.message(
      'إكمال',
      name: 'transactionComplete',
      desc: '',
      args: [],
    );
  }

  /// `تعليم كمنتهية`
  String get transactionExpire {
    return Intl.message(
      'تعليم كمنتهية',
      name: 'transactionExpire',
      desc: '',
      args: [],
    );
  }

  /// `إلغاء`
  String get transactionCancel {
    return Intl.message('إلغاء', name: 'transactionCancel', desc: '', args: []);
  }

  /// `إلغاء المعاملة`
  String get cancelTransactionTitle {
    return Intl.message(
      'إلغاء المعاملة',
      name: 'cancelTransactionTitle',
      desc: '',
      args: [],
    );
  }

  /// `هل أنت متأكد من إلغاء هذه المعاملة؟`
  String get cancelTransactionBody {
    return Intl.message(
      'هل أنت متأكد من إلغاء هذه المعاملة؟',
      name: 'cancelTransactionBody',
      desc: '',
      args: [],
    );
  }

  /// `إلغاء المعاملة`
  String get cancelTransactionConfirm {
    return Intl.message(
      'إلغاء المعاملة',
      name: 'cancelTransactionConfirm',
      desc: '',
      args: [],
    );
  }

  /// `إلغاء`
  String get cancel {
    return Intl.message('إلغاء', name: 'cancel', desc: '', args: []);
  }

  /// `تم تحديث حالة المعاملة.`
  String get transactionTransitionSuccess {
    return Intl.message(
      'تم تحديث حالة المعاملة.',
      name: 'transactionTransitionSuccess',
      desc: '',
      args: [],
    );
  }

  /// `تغيير الحالة هذا غير مسموح.`
  String get transactionTransitionDenied {
    return Intl.message(
      'تغيير الحالة هذا غير مسموح.',
      name: 'transactionTransitionDenied',
      desc: '',
      args: [],
    );
  }

  /// `المعاملة غير موجودة`
  String get transactionDetailMissingTitle {
    return Intl.message(
      'المعاملة غير موجودة',
      name: 'transactionDetailMissingTitle',
      desc: '',
      args: [],
    );
  }

  /// `هذه الصفقة غير متاحة أو لم يتم تحميلها لهذا الحساب بعد.`
  String get transactionDetailMissingBody {
    return Intl.message(
      'هذه الصفقة غير متاحة أو لم يتم تحميلها لهذا الحساب بعد.',
      name: 'transactionDetailMissingBody',
      desc: '',
      args: [],
    );
  }

  /// `تفاصيل الصفقة`
  String get transactionDetailTitle {
    return Intl.message(
      'تفاصيل الصفقة',
      name: 'transactionDetailTitle',
      desc: '',
      args: [],
    );
  }

  /// `تابع الحالة الحالية والخطوات التالية وروابط الثقة المرتبطة بها.`
  String get transactionDetailSubtitle {
    return Intl.message(
      'تابع الحالة الحالية والخطوات التالية وروابط الثقة المرتبطة بها.',
      name: 'transactionDetailSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `مكتملة`
  String get transactionDecisionComplete {
    return Intl.message(
      'مكتملة',
      name: 'transactionDecisionComplete',
      desc: '',
      args: [],
    );
  }

  /// `نشطة`
  String get transactionDecisionActive {
    return Intl.message(
      'نشطة',
      name: 'transactionDecisionActive',
      desc: '',
      args: [],
    );
  }

  /// `سياق الإعلان ودورك في الصفقة.`
  String get transactionDetailListingContext {
    return Intl.message(
      'سياق الإعلان ودورك في الصفقة.',
      name: 'transactionDetailListingContext',
      desc: '',
      args: [],
    );
  }

  /// `مشتري`
  String get transactionRoleBuyer {
    return Intl.message(
      'مشتري',
      name: 'transactionRoleBuyer',
      desc: '',
      args: [],
    );
  }

  /// `بائع`
  String get transactionRoleSeller {
    return Intl.message(
      'بائع',
      name: 'transactionRoleSeller',
      desc: '',
      args: [],
    );
  }

  /// `الخط الزمني`
  String get transactionTimelineTitle {
    return Intl.message(
      'الخط الزمني',
      name: 'transactionTimelineTitle',
      desc: '',
      args: [],
    );
  }

  /// `فتح الرسائل`
  String get transactionMessageAction {
    return Intl.message(
      'فتح الرسائل',
      name: 'transactionMessageAction',
      desc: '',
      args: [],
    );
  }

  /// `فتح نزاع`
  String get transactionOpenDisputeAction {
    return Intl.message(
      'فتح نزاع',
      name: 'transactionOpenDisputeAction',
      desc: '',
      args: [],
    );
  }

  /// `تقييم الطرف المقابل`
  String get transactionRateAction {
    return Intl.message(
      'تقييم الطرف المقابل',
      name: 'transactionRateAction',
      desc: '',
      args: [],
    );
  }

  /// `تم إنشاء الطلب`
  String get transactionTimelineRequested {
    return Intl.message(
      'تم إنشاء الطلب',
      name: 'transactionTimelineRequested',
      desc: '',
      args: [],
    );
  }

  /// `بدأ المشتري المعاملة وهي بانتظار مراجعة البائع.`
  String get transactionTimelineRequestedBody {
    return Intl.message(
      'بدأ المشتري المعاملة وهي بانتظار مراجعة البائع.',
      name: 'transactionTimelineRequestedBody',
      desc: '',
      args: [],
    );
  }

  /// `أكد البائع`
  String get transactionTimelineAccepted {
    return Intl.message(
      'أكد البائع',
      name: 'transactionTimelineAccepted',
      desc: '',
      args: [],
    );
  }

  /// `يمكن للطرفين الآن تنسيق الإكمال أو فتح نزاع عند الحاجة.`
  String get transactionTimelineAcceptedBody {
    return Intl.message(
      'يمكن للطرفين الآن تنسيق الإكمال أو فتح نزاع عند الحاجة.',
      name: 'transactionTimelineAcceptedBody',
      desc: '',
      args: [],
    );
  }

  /// `النتيجة`
  String get transactionTimelineCompleted {
    return Intl.message(
      'النتيجة',
      name: 'transactionTimelineCompleted',
      desc: '',
      args: [],
    );
  }

  /// `اكتملت هذه المعاملة وأصبح التقييم متاحاً الآن.`
  String get transactionTimelineCompletedBody {
    return Intl.message(
      'اكتملت هذه المعاملة وأصبح التقييم متاحاً الآن.',
      name: 'transactionTimelineCompletedBody',
      desc: '',
      args: [],
    );
  }

  /// `تم إلغاء هذه المعاملة قبل الإكمال.`
  String get transactionTimelineCancelledBody {
    return Intl.message(
      'تم إلغاء هذه المعاملة قبل الإكمال.',
      name: 'transactionTimelineCancelledBody',
      desc: '',
      args: [],
    );
  }

  /// `تم رفض هذه المعاملة من البائع.`
  String get transactionTimelineRejectedBody {
    return Intl.message(
      'تم رفض هذه المعاملة من البائع.',
      name: 'transactionTimelineRejectedBody',
      desc: '',
      args: [],
    );
  }

  /// `فتح نزاع`
  String get disputeTitle {
    return Intl.message('فتح نزاع', name: 'disputeTitle', desc: '', args: []);
  }

  /// `اشرح المشكلة وأرسل ما يكفي من الأدلة لفريق التشغيل.`
  String get disputeSubtitle {
    return Intl.message(
      'اشرح المشكلة وأرسل ما يكفي من الأدلة لفريق التشغيل.',
      name: 'disputeSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `السبب`
  String get disputeReasonLabel {
    return Intl.message(
      'السبب',
      name: 'disputeReasonLabel',
      desc: '',
      args: [],
    );
  }

  /// `الوصف`
  String get disputeDescriptionLabel {
    return Intl.message(
      'الوصف',
      name: 'disputeDescriptionLabel',
      desc: '',
      args: [],
    );
  }

  /// `اشرح المشكلة بوضوح. الحد الأدنى 50 حرفاً.`
  String get disputeDescriptionHelper {
    return Intl.message(
      'اشرح المشكلة بوضوح. الحد الأدنى 50 حرفاً.',
      name: 'disputeDescriptionHelper',
      desc: '',
      args: [],
    );
  }

  /// `أدخل 50 حرفاً على الأقل حتى يمكن مراجعة الحالة.`
  String get disputeDescriptionError {
    return Intl.message(
      'أدخل 50 حرفاً على الأقل حتى يمكن مراجعة الحالة.',
      name: 'disputeDescriptionError',
      desc: '',
      args: [],
    );
  }

  /// `الأدلة`
  String get disputeEvidenceLabel {
    return Intl.message(
      'الأدلة',
      name: 'disputeEvidenceLabel',
      desc: '',
      args: [],
    );
  }

  /// `سيُطلب منك إرفاق صور كأدلة.`
  String get disputeEvidenceValue {
    return Intl.message(
      'سيُطلب منك إرفاق صور كأدلة.',
      name: 'disputeEvidenceValue',
      desc: '',
      args: [],
    );
  }

  /// `تحضير`
  String get disputeEvidenceStatus {
    return Intl.message(
      'تحضير',
      name: 'disputeEvidenceStatus',
      desc: '',
      args: [],
    );
  }

  /// `إرسال النزاع`
  String get disputeSubmit {
    return Intl.message(
      'إرسال النزاع',
      name: 'disputeSubmit',
      desc: '',
      args: [],
    );
  }

  /// `تم إرسال النزاع`
  String get disputeSuccessTitle {
    return Intl.message(
      'تم إرسال النزاع',
      name: 'disputeSuccessTitle',
      desc: '',
      args: [],
    );
  }

  /// `تم إرسال النزاع. سيراجع فريقنا الحالة خلال 24 إلى 48 ساعة.`
  String get disputeSuccessBody {
    return Intl.message(
      'تم إرسال النزاع. سيراجع فريقنا الحالة خلال 24 إلى 48 ساعة.',
      name: 'disputeSuccessBody',
      desc: '',
      args: [],
    );
  }

  /// `تم استلام قطعة خاطئة`
  String get disputeReasonWrongPart {
    return Intl.message(
      'تم استلام قطعة خاطئة',
      name: 'disputeReasonWrongPart',
      desc: '',
      args: [],
    );
  }

  /// `الحالة غير مطابقة للوصف`
  String get disputeReasonCondition {
    return Intl.message(
      'الحالة غير مطابقة للوصف',
      name: 'disputeReasonCondition',
      desc: '',
      args: [],
    );
  }

  /// `لم يتم استلام القطعة`
  String get disputeReasonNotReceived {
    return Intl.message(
      'لم يتم استلام القطعة',
      name: 'disputeReasonNotReceived',
      desc: '',
      args: [],
    );
  }

  /// `البائع غير متجاوب بعد التأكيد`
  String get disputeReasonUnresponsive {
    return Intl.message(
      'البائع غير متجاوب بعد التأكيد',
      name: 'disputeReasonUnresponsive',
      desc: '',
      args: [],
    );
  }

  /// `سبب آخر`
  String get disputeReasonOther {
    return Intl.message(
      'سبب آخر',
      name: 'disputeReasonOther',
      desc: '',
      args: [],
    );
  }

  /// `الإبلاغ عن الإعلان`
  String get reportListingAction {
    return Intl.message(
      'الإبلاغ عن الإعلان',
      name: 'reportListingAction',
      desc: '',
      args: [],
    );
  }

  /// `تم الإبلاغ مسبقاً`
  String get reportListingAlreadyReported {
    return Intl.message(
      'تم الإبلاغ مسبقاً',
      name: 'reportListingAlreadyReported',
      desc: '',
      args: [],
    );
  }

  /// `محتوى مزعج`
  String get reportListingReasonSpam {
    return Intl.message(
      'محتوى مزعج',
      name: 'reportListingReasonSpam',
      desc: '',
      args: [],
    );
  }

  /// `محتوى مضلل`
  String get reportListingReasonMisleading {
    return Intl.message(
      'محتوى مضلل',
      name: 'reportListingReasonMisleading',
      desc: '',
      args: [],
    );
  }

  /// `فئة خاطئة`
  String get reportListingReasonWrongCategory {
    return Intl.message(
      'فئة خاطئة',
      name: 'reportListingReasonWrongCategory',
      desc: '',
      args: [],
    );
  }

  /// `أخرى`
  String get reportListingReasonOther {
    return Intl.message(
      'أخرى',
      name: 'reportListingReasonOther',
      desc: '',
      args: [],
    );
  }

  /// `تم إرسال البلاغ`
  String get reportListingSuccess {
    return Intl.message(
      'تم إرسال البلاغ',
      name: 'reportListingSuccess',
      desc: '',
      args: [],
    );
  }

  /// `مسح السجل`
  String get searchHistoryClearAction {
    return Intl.message(
      'مسح السجل',
      name: 'searchHistoryClearAction',
      desc: '',
      args: [],
    );
  }

  /// `عمليات البحث الأخيرة`
  String get searchRecentLabel {
    return Intl.message(
      'عمليات البحث الأخيرة',
      name: 'searchRecentLabel',
      desc: '',
      args: [],
    );
  }

  /// `{title} — {link}`
  String shareListingText(Object title, Object link) {
    return Intl.message(
      '$title — $link',
      name: 'shareListingText',
      desc: '',
      args: [title, link],
    );
  }

  /// `طابور توثيق البائعين`
  String get adminVerificationsQueueTitle {
    return Intl.message(
      'طابور توثيق البائعين',
      name: 'adminVerificationsQueueTitle',
      desc: '',
      args: [],
    );
  }

  /// `راجع طلبات التوثيق المعلقة مع جودة الوثائق ومدة الانتظار.`
  String get adminVerificationsQueueSubtitle {
    return Intl.message(
      'راجع طلبات التوثيق المعلقة مع جودة الوثائق ومدة الانتظار.',
      name: 'adminVerificationsQueueSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `لا توجد عناصر نشطة`
  String get adminQueueEmptyValue {
    return Intl.message(
      'لا توجد عناصر نشطة',
      name: 'adminQueueEmptyValue',
      desc: '',
      args: [],
    );
  }

  /// `فارغ`
  String get adminQueueReadyStatus {
    return Intl.message(
      'فارغ',
      name: 'adminQueueReadyStatus',
      desc: '',
      args: [],
    );
  }

  /// `الطابور فارغ`
  String get adminQueueEmptyTitle {
    return Intl.message(
      'الطابور فارغ',
      name: 'adminQueueEmptyTitle',
      desc: '',
      args: [],
    );
  }

  /// `لا توجد حالات توثيق بائعين بانتظار المراجعة حالياً.`
  String get adminVerificationsQueueEmptyBody {
    return Intl.message(
      'لا توجد حالات توثيق بائعين بانتظار المراجعة حالياً.',
      name: 'adminVerificationsQueueEmptyBody',
      desc: '',
      args: [],
    );
  }

  /// `مراجعة التوثيق`
  String get adminVerificationDetailTitle {
    return Intl.message(
      'مراجعة التوثيق',
      name: 'adminVerificationDetailTitle',
      desc: '',
      args: [],
    );
  }

  /// `راجع وثائق البائع وسجل القرار مع السبب.`
  String get adminVerificationDetailSubtitle {
    return Intl.message(
      'راجع وثائق البائع وسجل القرار مع السبب.',
      name: 'adminVerificationDetailSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `بيانات التوثيق غير متاحة`
  String get adminVerificationDetailEmptyTitle {
    return Intl.message(
      'بيانات التوثيق غير متاحة',
      name: 'adminVerificationDetailEmptyTitle',
      desc: '',
      args: [],
    );
  }

  /// `افتح هذه الشاشة من طابور التوثيق عندما توجد حالة معلقة للفحص.`
  String get adminVerificationDetailEmptyBody {
    return Intl.message(
      'افتح هذه الشاشة من طابور التوثيق عندما توجد حالة معلقة للفحص.',
      name: 'adminVerificationDetailEmptyBody',
      desc: '',
      args: [],
    );
  }

  /// `صاحب الطلب`
  String get adminVerificationApplicantLabel {
    return Intl.message(
      'صاحب الطلب',
      name: 'adminVerificationApplicantLabel',
      desc: '',
      args: [],
    );
  }

  /// `موافقة`
  String get adminVerificationApproveAction {
    return Intl.message(
      'موافقة',
      name: 'adminVerificationApproveAction',
      desc: '',
      args: [],
    );
  }

  /// `طلب معلومات`
  String get adminVerificationNeedsInfoAction {
    return Intl.message(
      'طلب معلومات',
      name: 'adminVerificationNeedsInfoAction',
      desc: '',
      args: [],
    );
  }

  /// `رفض`
  String get adminVerificationRejectAction {
    return Intl.message(
      'رفض',
      name: 'adminVerificationRejectAction',
      desc: '',
      args: [],
    );
  }

  /// `تم تحديث حالة التوثيق.`
  String get adminVerificationStatusUpdated {
    return Intl.message(
      'تم تحديث حالة التوثيق.',
      name: 'adminVerificationStatusUpdated',
      desc: '',
      args: [],
    );
  }

  /// `الوثائق`
  String get adminVerificationDocumentsTitle {
    return Intl.message(
      'الوثائق',
      name: 'adminVerificationDocumentsTitle',
      desc: '',
      args: [],
    );
  }

  /// `لا توجد وثائق تحقق مرفقة بهذا الطلب.`
  String get adminVerificationDocumentsEmpty {
    return Intl.message(
      'لا توجد وثائق تحقق مرفقة بهذا الطلب.',
      name: 'adminVerificationDocumentsEmpty',
      desc: '',
      args: [],
    );
  }

  /// `سجل الطلب`
  String get adminVerificationHistoryTitle {
    return Intl.message(
      'سجل الطلب',
      name: 'adminVerificationHistoryTitle',
      desc: '',
      args: [],
    );
  }

  /// `تاريخ الإرسال`
  String get adminVerificationSubmittedAtLabel {
    return Intl.message(
      'تاريخ الإرسال',
      name: 'adminVerificationSubmittedAtLabel',
      desc: '',
      args: [],
    );
  }

  /// `تاريخ المراجعة`
  String get adminVerificationReviewedAtLabel {
    return Intl.message(
      'تاريخ المراجعة',
      name: 'adminVerificationReviewedAtLabel',
      desc: '',
      args: [],
    );
  }

  /// `رمز السبب`
  String get adminVerificationReasonCodeLabel {
    return Intl.message(
      'رمز السبب',
      name: 'adminVerificationReasonCodeLabel',
      desc: '',
      args: [],
    );
  }

  /// `ملاحظة المراجعة`
  String get adminVerificationReviewNoteLabel {
    return Intl.message(
      'ملاحظة المراجعة',
      name: 'adminVerificationReviewNoteLabel',
      desc: '',
      args: [],
    );
  }

  /// `اختر رمز سبب قبل طلب معلومات إضافية أو الرفض.`
  String get adminVerificationReasonRequired {
    return Intl.message(
      'اختر رمز سبب قبل طلب معلومات إضافية أو الرفض.',
      name: 'adminVerificationReasonRequired',
      desc: '',
      args: [],
    );
  }

  /// `الوثيقة غير واضحة`
  String get adminVerificationReasonUnreadable {
    return Intl.message(
      'الوثيقة غير واضحة',
      name: 'adminVerificationReasonUnreadable',
      desc: '',
      args: [],
    );
  }

  /// `عدم تطابق الهوية`
  String get adminVerificationReasonIdentityMismatch {
    return Intl.message(
      'عدم تطابق الهوية',
      name: 'adminVerificationReasonIdentityMismatch',
      desc: '',
      args: [],
    );
  }

  /// `السجل التجاري غير مرفق`
  String get adminVerificationReasonMissingBusinessDocument {
    return Intl.message(
      'السجل التجاري غير مرفق',
      name: 'adminVerificationReasonMissingBusinessDocument',
      desc: '',
      args: [],
    );
  }

  /// `طابور مراجعة الإعلانات`
  String get adminListingsQueueTitle {
    return Intl.message(
      'طابور مراجعة الإعلانات',
      name: 'adminListingsQueueTitle',
      desc: '',
      args: [],
    );
  }

  /// `راجع الإعلانات المرسلة مع مخاطر الفئة وسياق البائع.`
  String get adminListingsQueueSubtitle {
    return Intl.message(
      'راجع الإعلانات المرسلة مع مخاطر الفئة وسياق البائع.',
      name: 'adminListingsQueueSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `لا توجد حالات مراجعة إعلانات بانتظارك حالياً.`
  String get adminListingsQueueEmptyBody {
    return Intl.message(
      'لا توجد حالات مراجعة إعلانات بانتظارك حالياً.',
      name: 'adminListingsQueueEmptyBody',
      desc: '',
      args: [],
    );
  }

  /// `تفاصيل مراجعة الإعلان`
  String get adminListingReviewTitle {
    return Intl.message(
      'تفاصيل مراجعة الإعلان',
      name: 'adminListingReviewTitle',
      desc: '',
      args: [],
    );
  }

  /// `قارن الإعلان بالسياسة ولا تنشره إلا عندما تكون الأدلة سليمة.`
  String get adminListingReviewSubtitle {
    return Intl.message(
      'قارن الإعلان بالسياسة ولا تنشره إلا عندما تكون الأدلة سليمة.',
      name: 'adminListingReviewSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `مراجعة الإعلان غير متاحة`
  String get adminListingReviewEmptyTitle {
    return Intl.message(
      'مراجعة الإعلان غير متاحة',
      name: 'adminListingReviewEmptyTitle',
      desc: '',
      args: [],
    );
  }

  /// `افتح هذه الشاشة من طابور المراجعة عندما يحتاج إعلان إلى قرار.`
  String get adminListingReviewEmptyBody {
    return Intl.message(
      'افتح هذه الشاشة من طابور المراجعة عندما يحتاج إعلان إلى قرار.',
      name: 'adminListingReviewEmptyBody',
      desc: '',
      args: [],
    );
  }

  /// `طابور البلاغات`
  String get adminReportsQueueTitle {
    return Intl.message(
      'طابور البلاغات',
      name: 'adminReportsQueueTitle',
      desc: '',
      args: [],
    );
  }

  /// `تابع بلاغات الإعلانات والبائعين والرسائل من شاشة واحدة.`
  String get adminReportsQueueSubtitle {
    return Intl.message(
      'تابع بلاغات الإعلانات والبائعين والرسائل من شاشة واحدة.',
      name: 'adminReportsQueueSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `لا توجد بلاغات مفتوحة حالياً.`
  String get adminReportsQueueEmptyBody {
    return Intl.message(
      'لا توجد بلاغات مفتوحة حالياً.',
      name: 'adminReportsQueueEmptyBody',
      desc: '',
      args: [],
    );
  }

  /// `تفاصيل مراجعة البلاغ`
  String get adminReportDetailTitle {
    return Intl.message(
      'تفاصيل مراجعة البلاغ',
      name: 'adminReportDetailTitle',
      desc: '',
      args: [],
    );
  }

  /// `افحص البلاغ والجهة المرتبطة وسجل الإجراءات قبل اتخاذ القرار.`
  String get adminReportDetailSubtitle {
    return Intl.message(
      'افحص البلاغ والجهة المرتبطة وسجل الإجراءات قبل اتخاذ القرار.',
      name: 'adminReportDetailSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `تفاصيل البلاغ غير متاحة`
  String get adminReportDetailEmptyTitle {
    return Intl.message(
      'تفاصيل البلاغ غير متاحة',
      name: 'adminReportDetailEmptyTitle',
      desc: '',
      args: [],
    );
  }

  /// `افتح هذه الشاشة من طابور البلاغات عندما يكون البلاغ جاهزاً للمراجعة.`
  String get adminReportDetailEmptyBody {
    return Intl.message(
      'افتح هذه الشاشة من طابور البلاغات عندما يكون البلاغ جاهزاً للمراجعة.',
      name: 'adminReportDetailEmptyBody',
      desc: '',
      args: [],
    );
  }

  /// `تطبيق القرار`
  String get adminReportApplyDecisionAction {
    return Intl.message(
      'تطبيق القرار',
      name: 'adminReportApplyDecisionAction',
      desc: '',
      args: [],
    );
  }

  /// `تم حفظ قرار البلاغ.`
  String get adminReportDecisionSaved {
    return Intl.message(
      'تم حفظ قرار البلاغ.',
      name: 'adminReportDecisionSaved',
      desc: '',
      args: [],
    );
  }

  /// `إغلاق البلاغ بدون إجراء`
  String get adminReportDecisionDismiss {
    return Intl.message(
      'إغلاق البلاغ بدون إجراء',
      name: 'adminReportDecisionDismiss',
      desc: '',
      args: [],
    );
  }

  /// `إنذار البائع`
  String get adminReportDecisionWarnSeller {
    return Intl.message(
      'إنذار البائع',
      name: 'adminReportDecisionWarnSeller',
      desc: '',
      args: [],
    );
  }

  /// `إزالة الإعلان`
  String get adminReportDecisionRemoveListing {
    return Intl.message(
      'إزالة الإعلان',
      name: 'adminReportDecisionRemoveListing',
      desc: '',
      args: [],
    );
  }

  /// `تعليق البائع`
  String get adminReportDecisionSuspendSeller {
    return Intl.message(
      'تعليق البائع',
      name: 'adminReportDecisionSuspendSeller',
      desc: '',
      args: [],
    );
  }

  /// `مقدم البلاغ`
  String get adminReportReporterLabel {
    return Intl.message(
      'مقدم البلاغ',
      name: 'adminReportReporterLabel',
      desc: '',
      args: [],
    );
  }

  /// `الجهة المرتبطة`
  String get adminReportEntityLabel {
    return Intl.message(
      'الجهة المرتبطة',
      name: 'adminReportEntityLabel',
      desc: '',
      args: [],
    );
  }

  /// `سجل مقدم البلاغ`
  String get adminReportReporterHistoryLabel {
    return Intl.message(
      'سجل مقدم البلاغ',
      name: 'adminReportReporterHistoryLabel',
      desc: '',
      args: [],
    );
  }

  /// `سجل الجهة المرتبطة`
  String get adminReportEntityHistoryLabel {
    return Intl.message(
      'سجل الجهة المرتبطة',
      name: 'adminReportEntityHistoryLabel',
      desc: '',
      args: [],
    );
  }

  /// `بلاغ غير ذي صلة أو مزعج`
  String get adminReportReasonSpam {
    return Intl.message(
      'بلاغ غير ذي صلة أو مزعج',
      name: 'adminReportReasonSpam',
      desc: '',
      args: [],
    );
  }

  /// `مخالفة سياسة`
  String get adminReportReasonPolicyViolation {
    return Intl.message(
      'مخالفة سياسة',
      name: 'adminReportReasonPolicyViolation',
      desc: '',
      args: [],
    );
  }

  /// `أدلة غير كافية`
  String get adminReportReasonInsufficientEvidence {
    return Intl.message(
      'أدلة غير كافية',
      name: 'adminReportReasonInsufficientEvidence',
      desc: '',
      args: [],
    );
  }

  /// `طابور النزاعات`
  String get adminDisputesQueueTitle {
    return Intl.message(
      'طابور النزاعات',
      name: 'adminDisputesQueueTitle',
      desc: '',
      args: [],
    );
  }

  /// `راجع النزاعات المفتوحة مع سجل المعاملة وسياق الأدلة.`
  String get adminDisputesQueueSubtitle {
    return Intl.message(
      'راجع النزاعات المفتوحة مع سجل المعاملة وسياق الأدلة.',
      name: 'adminDisputesQueueSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `لا توجد نزاعات بانتظارك حالياً.`
  String get adminDisputesQueueEmptyBody {
    return Intl.message(
      'لا توجد نزاعات بانتظارك حالياً.',
      name: 'adminDisputesQueueEmptyBody',
      desc: '',
      args: [],
    );
  }

  /// `تفاصيل مراجعة النزاع`
  String get adminDisputeDetailTitle {
    return Intl.message(
      'تفاصيل مراجعة النزاع',
      name: 'adminDisputeDetailTitle',
      desc: '',
      args: [],
    );
  }

  /// `افحص الطرفين والخط الزمني والأدلة قبل الحسم.`
  String get adminDisputeDetailSubtitle {
    return Intl.message(
      'افحص الطرفين والخط الزمني والأدلة قبل الحسم.',
      name: 'adminDisputeDetailSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `تفاصيل النزاع غير متاحة`
  String get adminDisputeDetailEmptyTitle {
    return Intl.message(
      'تفاصيل النزاع غير متاحة',
      name: 'adminDisputeDetailEmptyTitle',
      desc: '',
      args: [],
    );
  }

  /// `افتح هذه الشاشة من طابور النزاعات عندما تحتاج الحالة إلى إجراء.`
  String get adminDisputeDetailEmptyBody {
    return Intl.message(
      'افتح هذه الشاشة من طابور النزاعات عندما تحتاج الحالة إلى إجراء.',
      name: 'adminDisputeDetailEmptyBody',
      desc: '',
      args: [],
    );
  }

  /// `حسم النزاع`
  String get adminDisputeResolveAction {
    return Intl.message(
      'حسم النزاع',
      name: 'adminDisputeResolveAction',
      desc: '',
      args: [],
    );
  }

  /// `تم حفظ قرار النزاع.`
  String get adminDisputeDecisionSaved {
    return Intl.message(
      'تم حفظ قرار النزاع.',
      name: 'adminDisputeDecisionSaved',
      desc: '',
      args: [],
    );
  }

  /// `الحسم لصالح المشتري`
  String get adminDisputeDecisionBuyer {
    return Intl.message(
      'الحسم لصالح المشتري',
      name: 'adminDisputeDecisionBuyer',
      desc: '',
      args: [],
    );
  }

  /// `الحسم لصالح البائع`
  String get adminDisputeDecisionSeller {
    return Intl.message(
      'الحسم لصالح البائع',
      name: 'adminDisputeDecisionSeller',
      desc: '',
      args: [],
    );
  }

  /// `إغلاق النزاع بدون إجراء`
  String get adminDisputeDecisionDismiss {
    return Intl.message(
      'إغلاق النزاع بدون إجراء',
      name: 'adminDisputeDecisionDismiss',
      desc: '',
      args: [],
    );
  }

  /// `بدون إجراء`
  String get adminDisputeOutcomeNoAction {
    return Intl.message(
      'بدون إجراء',
      name: 'adminDisputeOutcomeNoAction',
      desc: '',
      args: [],
    );
  }

  /// `إنذار`
  String get adminDisputeOutcomeWarn {
    return Intl.message(
      'إنذار',
      name: 'adminDisputeOutcomeWarn',
      desc: '',
      args: [],
    );
  }

  /// `تعليق`
  String get adminDisputeOutcomeSuspend {
    return Intl.message(
      'تعليق',
      name: 'adminDisputeOutcomeSuspend',
      desc: '',
      args: [],
    );
  }

  /// `إزالة الإعلان`
  String get adminDisputeOutcomeRemoveListing {
    return Intl.message(
      'إزالة الإعلان',
      name: 'adminDisputeOutcomeRemoveListing',
      desc: '',
      args: [],
    );
  }

  /// `الإعلان`
  String get adminDisputeListingLabel {
    return Intl.message(
      'الإعلان',
      name: 'adminDisputeListingLabel',
      desc: '',
      args: [],
    );
  }

  /// `المشتري`
  String get adminDisputeBuyerLabel {
    return Intl.message(
      'المشتري',
      name: 'adminDisputeBuyerLabel',
      desc: '',
      args: [],
    );
  }

  /// `البائع`
  String get adminDisputeSellerLabel {
    return Intl.message(
      'البائع',
      name: 'adminDisputeSellerLabel',
      desc: '',
      args: [],
    );
  }

  /// `القطعة متضررة`
  String get adminDisputeReasonDamagedPart {
    return Intl.message(
      'القطعة متضررة',
      name: 'adminDisputeReasonDamagedPart',
      desc: '',
      args: [],
    );
  }

  /// `تم إرسال قطعة خاطئة`
  String get adminDisputeReasonWrongPart {
    return Intl.message(
      'تم إرسال قطعة خاطئة',
      name: 'adminDisputeReasonWrongPart',
      desc: '',
      args: [],
    );
  }

  /// `أدلة غير كافية`
  String get adminDisputeReasonInsufficientEvidence {
    return Intl.message(
      'أدلة غير كافية',
      name: 'adminDisputeReasonInsufficientEvidence',
      desc: '',
      args: [],
    );
  }

  /// `مراجعة المحادثة`
  String get adminConversationOversightTitle {
    return Intl.message(
      'مراجعة المحادثة',
      name: 'adminConversationOversightTitle',
      desc: '',
      args: [],
    );
  }

  /// `عرض السجل المحمي يتطلب غرضاً واضحاً قبل تحميل الرسائل.`
  String get adminConversationOversightSubtitle {
    return Intl.message(
      'عرض السجل المحمي يتطلب غرضاً واضحاً قبل تحميل الرسائل.',
      name: 'adminConversationOversightSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `غرض إلزامي`
  String get adminPurposeGateRequired {
    return Intl.message(
      'غرض إلزامي',
      name: 'adminPurposeGateRequired',
      desc: '',
      args: [],
    );
  }

  /// `تأكيد الغرض مطلوب`
  String get adminPurposeGateTitle {
    return Intl.message(
      'تأكيد الغرض مطلوب',
      name: 'adminPurposeGateTitle',
      desc: '',
      args: [],
    );
  }

  /// `يجب فتح هذا المسار فقط من قضية نزاع أو إساءة أو دعم مع تسجيل الغرض.`
  String get adminPurposeGateBody {
    return Intl.message(
      'يجب فتح هذا المسار فقط من قضية نزاع أو إساءة أو دعم مع تسجيل الغرض.',
      name: 'adminPurposeGateBody',
      desc: '',
      args: [],
    );
  }

  /// `غرض المراجعة`
  String get adminPurposeFieldLabel {
    return Intl.message(
      'غرض المراجعة',
      name: 'adminPurposeFieldLabel',
      desc: '',
      args: [],
    );
  }

  /// `ملاحظة الغرض`
  String get adminPurposeNoteLabel {
    return Intl.message(
      'ملاحظة الغرض',
      name: 'adminPurposeNoteLabel',
      desc: '',
      args: [],
    );
  }

  /// `مراجعة نزاع`
  String get adminPurposeOptionDispute {
    return Intl.message(
      'مراجعة نزاع',
      name: 'adminPurposeOptionDispute',
      desc: '',
      args: [],
    );
  }

  /// `مراجعة إساءة`
  String get adminPurposeOptionAbuse {
    return Intl.message(
      'مراجعة إساءة',
      name: 'adminPurposeOptionAbuse',
      desc: '',
      args: [],
    );
  }

  /// `تدخل دعم`
  String get adminPurposeOptionSupport {
    return Intl.message(
      'تدخل دعم',
      name: 'adminPurposeOptionSupport',
      desc: '',
      args: [],
    );
  }

  /// `تحميل السجل`
  String get adminConversationLoadAction {
    return Intl.message(
      'تحميل السجل',
      name: 'adminConversationLoadAction',
      desc: '',
      args: [],
    );
  }

  /// `سجل الرسائل`
  String get adminConversationTranscriptTitle {
    return Intl.message(
      'سجل الرسائل',
      name: 'adminConversationTranscriptTitle',
      desc: '',
      args: [],
    );
  }

  /// `السياق المرتبط`
  String get adminConversationRelatedContextTitle {
    return Intl.message(
      'السياق المرتبط',
      name: 'adminConversationRelatedContextTitle',
      desc: '',
      args: [],
    );
  }

  /// `المشتري`
  String get adminConversationBuyerLabel {
    return Intl.message(
      'المشتري',
      name: 'adminConversationBuyerLabel',
      desc: '',
      args: [],
    );
  }

  /// `البائع`
  String get adminConversationSellerLabel {
    return Intl.message(
      'البائع',
      name: 'adminConversationSellerLabel',
      desc: '',
      args: [],
    );
  }

  /// `المعاملة المرتبطة`
  String get adminConversationLinkedDealLabel {
    return Intl.message(
      'المعاملة المرتبطة',
      name: 'adminConversationLinkedDealLabel',
      desc: '',
      args: [],
    );
  }

  /// `النزاع المرتبط`
  String get adminConversationLinkedDisputeLabel {
    return Intl.message(
      'النزاع المرتبط',
      name: 'adminConversationLinkedDisputeLabel',
      desc: '',
      args: [],
    );
  }

  /// `البلاغ المرتبط`
  String get adminConversationLinkedReportLabel {
    return Intl.message(
      'البلاغ المرتبط',
      name: 'adminConversationLinkedReportLabel',
      desc: '',
      args: [],
    );
  }

  /// `نسخ رابط الرسالة`
  String get adminConversationCopyLinkAction {
    return Intl.message(
      'نسخ رابط الرسالة',
      name: 'adminConversationCopyLinkAction',
      desc: '',
      args: [],
    );
  }

  /// `تم نسخ المرجع الداخلي.`
  String get adminConversationCopyLinkSuccess {
    return Intl.message(
      'تم نسخ المرجع الداخلي.',
      name: 'adminConversationCopyLinkSuccess',
      desc: '',
      args: [],
    );
  }

  /// `إرفاق ملاحظة للحالة`
  String get adminConversationAttachNoteAction {
    return Intl.message(
      'إرفاق ملاحظة للحالة',
      name: 'adminConversationAttachNoteAction',
      desc: '',
      args: [],
    );
  }

  /// `قائمة التحقق من السياسة`
  String get adminModerationChecklistTitle {
    return Intl.message(
      'قائمة التحقق من السياسة',
      name: 'adminModerationChecklistTitle',
      desc: '',
      args: [],
    );
  }

  /// `تم إرفاق صورتين على الأقل.`
  String get adminModerationPhotosCheck {
    return Intl.message(
      'تم إرفاق صورتين على الأقل.',
      name: 'adminModerationPhotosCheck',
      desc: '',
      args: [],
    );
  }

  /// `بيانات المطابقة تشمل العلامة والموديل والسنة.`
  String get adminModerationFitmentCheck {
    return Intl.message(
      'بيانات المطابقة تشمل العلامة والموديل والسنة.',
      name: 'adminModerationFitmentCheck',
      desc: '',
      args: [],
    );
  }

  /// `الكمية صالحة للبيع.`
  String get adminModerationQuantityCheck {
    return Intl.message(
      'الكمية صالحة للبيع.',
      name: 'adminModerationQuantityCheck',
      desc: '',
      args: [],
    );
  }

  /// `الوصف موجود للمراجعة.`
  String get adminModerationDescriptionCheck {
    return Intl.message(
      'الوصف موجود للمراجعة.',
      name: 'adminModerationDescriptionCheck',
      desc: '',
      args: [],
    );
  }

  /// `توثيق البائع`
  String get adminModerationSellerStatusLabel {
    return Intl.message(
      'توثيق البائع',
      name: 'adminModerationSellerStatusLabel',
      desc: '',
      args: [],
    );
  }

  /// `بلاغات البائع المفتوحة`
  String get adminModerationSellerReportsLabel {
    return Intl.message(
      'بلاغات البائع المفتوحة',
      name: 'adminModerationSellerReportsLabel',
      desc: '',
      args: [],
    );
  }

  /// `سبب الرفض الأخير`
  String get adminModerationLastRejectionLabel {
    return Intl.message(
      'سبب الرفض الأخير',
      name: 'adminModerationLastRejectionLabel',
      desc: '',
      args: [],
    );
  }

  /// `ملاحظة القرار`
  String get adminModerationDecisionNoteLabel {
    return Intl.message(
      'ملاحظة القرار',
      name: 'adminModerationDecisionNoteLabel',
      desc: '',
      args: [],
    );
  }

  /// `سجّل سبب قرار المراجعة أو ملاحظة الرفض.`
  String get adminModerationDecisionNoteHint {
    return Intl.message(
      'سجّل سبب قرار المراجعة أو ملاحظة الرفض.',
      name: 'adminModerationDecisionNoteHint',
      desc: '',
      args: [],
    );
  }

  /// `تمت الموافقة على الإعلان ونشره.`
  String get adminModerationApproveSuccess {
    return Intl.message(
      'تمت الموافقة على الإعلان ونشره.',
      name: 'adminModerationApproveSuccess',
      desc: '',
      args: [],
    );
  }

  /// `تم رفض الإعلان وإرجاعه إلى البائع.`
  String get adminModerationRejectSuccess {
    return Intl.message(
      'تم رفض الإعلان وإرجاعه إلى البائع.',
      name: 'adminModerationRejectSuccess',
      desc: '',
      args: [],
    );
  }

  /// `فريق الإدارة`
  String get adminTeamTitle {
    return Intl.message(
      'فريق الإدارة',
      name: 'adminTeamTitle',
      desc: '',
      args: [],
    );
  }

  /// `إدارة المشغلين النشطين وتغطية المشرف العام ودعوات الوصول من مكان واحد.`
  String get adminTeamSubtitle {
    return Intl.message(
      'إدارة المشغلين النشطين وتغطية المشرف العام ودعوات الوصول من مكان واحد.',
      name: 'adminTeamSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `دعوة مشرف`
  String get adminTeamInviteAction {
    return Intl.message(
      'دعوة مشرف',
      name: 'adminTeamInviteAction',
      desc: '',
      args: [],
    );
  }

  /// `تم إرسال دعوة المشرف.`
  String get adminTeamInviteSuccess {
    return Intl.message(
      'تم إرسال دعوة المشرف.',
      name: 'adminTeamInviteSuccess',
      desc: '',
      args: [],
    );
  }

  /// `تعليق`
  String get adminTeamSuspendAction {
    return Intl.message(
      'تعليق',
      name: 'adminTeamSuspendAction',
      desc: '',
      args: [],
    );
  }

  /// `إعادة تفعيل`
  String get adminTeamReactivateAction {
    return Intl.message(
      'إعادة تفعيل',
      name: 'adminTeamReactivateAction',
      desc: '',
      args: [],
    );
  }

  /// `ترقية`
  String get adminTeamPromoteAction {
    return Intl.message(
      'ترقية',
      name: 'adminTeamPromoteAction',
      desc: '',
      args: [],
    );
  }

  /// `خفض الصلاحية`
  String get adminTeamDemoteAction {
    return Intl.message(
      'خفض الصلاحية',
      name: 'adminTeamDemoteAction',
      desc: '',
      args: [],
    );
  }

  /// `تم تحديث عضو فريق الإدارة.`
  String get adminTeamMemberUpdated {
    return Intl.message(
      'تم تحديث عضو فريق الإدارة.',
      name: 'adminTeamMemberUpdated',
      desc: '',
      args: [],
    );
  }

  /// `آخر نشاط`
  String get adminTeamLastActiveLabel {
    return Intl.message(
      'آخر نشاط',
      name: 'adminTeamLastActiveLabel',
      desc: '',
      args: [],
    );
  }

  /// `نشط`
  String get adminTeamStatusActive {
    return Intl.message(
      'نشط',
      name: 'adminTeamStatusActive',
      desc: '',
      args: [],
    );
  }

  /// `معلّق`
  String get adminTeamStatusSuspended {
    return Intl.message(
      'معلّق',
      name: 'adminTeamStatusSuspended',
      desc: '',
      args: [],
    );
  }

  /// `نشطة`
  String get sellerListingsStatusActive {
    return Intl.message(
      'نشطة',
      name: 'sellerListingsStatusActive',
      desc: '',
      args: [],
    );
  }

  /// `مسودات`
  String get sellerListingsStatusDrafts {
    return Intl.message(
      'مسودات',
      name: 'sellerListingsStatusDrafts',
      desc: '',
      args: [],
    );
  }

  /// `قيد المراجعة`
  String get sellerListingsStatusUnderReview {
    return Intl.message(
      'قيد المراجعة',
      name: 'sellerListingsStatusUnderReview',
      desc: '',
      args: [],
    );
  }

  /// `موقوفة`
  String get sellerListingsStatusPaused {
    return Intl.message(
      'موقوفة',
      name: 'sellerListingsStatusPaused',
      desc: '',
      args: [],
    );
  }

  /// `مرفوضة`
  String get sellerListingsStatusRejected {
    return Intl.message(
      'مرفوضة',
      name: 'sellerListingsStatusRejected',
      desc: '',
      args: [],
    );
  }

  /// `مغلقة`
  String get sellerListingsStatusClosed {
    return Intl.message(
      'مغلقة',
      name: 'sellerListingsStatusClosed',
      desc: '',
      args: [],
    );
  }

  /// `إيقاف`
  String get sellerListingPauseAction {
    return Intl.message(
      'إيقاف',
      name: 'sellerListingPauseAction',
      desc: '',
      args: [],
    );
  }

  /// `تعديل`
  String get sellerListingEditAction {
    return Intl.message(
      'تعديل',
      name: 'sellerListingEditAction',
      desc: '',
      args: [],
    );
  }

  /// `إغلاق`
  String get sellerListingCloseAction {
    return Intl.message(
      'إغلاق',
      name: 'sellerListingCloseAction',
      desc: '',
      args: [],
    );
  }

  /// `حذف`
  String get sellerListingDeleteAction {
    return Intl.message(
      'حذف',
      name: 'sellerListingDeleteAction',
      desc: '',
      args: [],
    );
  }

  /// `حذف الإعلان`
  String get deleteListingTitle {
    return Intl.message(
      'حذف الإعلان',
      name: 'deleteListingTitle',
      desc: '',
      args: [],
    );
  }

  /// `هل أنت متأكد؟ لا يمكن التراجع عن هذا الإجراء.`
  String get deleteListingBody {
    return Intl.message(
      'هل أنت متأكد؟ لا يمكن التراجع عن هذا الإجراء.',
      name: 'deleteListingBody',
      desc: '',
      args: [],
    );
  }

  /// `حذف`
  String get deleteListingConfirm {
    return Intl.message(
      'حذف',
      name: 'deleteListingConfirm',
      desc: '',
      args: [],
    );
  }

  /// `إرسال`
  String get sellerListingSubmitAction {
    return Intl.message(
      'إرسال',
      name: 'sellerListingSubmitAction',
      desc: '',
      args: [],
    );
  }

  /// `استئناف`
  String get sellerListingResumeAction {
    return Intl.message(
      'استئناف',
      name: 'sellerListingResumeAction',
      desc: '',
      args: [],
    );
  }

  /// `إعادة الإرسال`
  String get sellerListingResubmitAction {
    return Intl.message(
      'إعادة الإرسال',
      name: 'sellerListingResubmitAction',
      desc: '',
      args: [],
    );
  }

  /// `تم تحديث مسار الإعلان.`
  String get sellerListingActionUpdated {
    return Intl.message(
      'تم تحديث مسار الإعلان.',
      name: 'sellerListingActionUpdated',
      desc: '',
      args: [],
    );
  }

  /// `تم الإرسال {date}`
  String sellerListingSubmittedLabel(Object date) {
    return Intl.message(
      'تم الإرسال $date',
      name: 'sellerListingSubmittedLabel',
      desc: '',
      args: [date],
    );
  }

  /// `آخر تحديث {date}`
  String sellerListingUpdatedLabel(Object date) {
    return Intl.message(
      'آخر تحديث $date',
      name: 'sellerListingUpdatedLabel',
      desc: '',
      args: [date],
    );
  }

  /// `جاهزية إصدار الإنتاج`
  String get releaseReadinessTitle {
    return Intl.message(
      'جاهزية إصدار الإنتاج',
      name: 'releaseReadinessTitle',
      desc: '',
      args: [],
    );
  }

  /// `هذه الشاشة لا تنفذ فحوصات Flutter أو Supabase أثناء التشغيل. تبقى الجاهزية غير مكتملة حتى يتم التحقق من الأدلة الخارجية.`
  String get releaseReadinessRuntimeWarning {
    return Intl.message(
      'هذه الشاشة لا تنفذ فحوصات Flutter أو Supabase أثناء التشغيل. تبقى الجاهزية غير مكتملة حتى يتم التحقق من الأدلة الخارجية.',
      name: 'releaseReadinessRuntimeWarning',
      desc: '',
      args: [],
    );
  }

  /// `القرار`
  String get releaseDecisionLabel {
    return Intl.message(
      'القرار',
      name: 'releaseDecisionLabel',
      desc: '',
      args: [],
    );
  }

  /// `جاهز للإصدار`
  String get releaseDecisionReady {
    return Intl.message(
      'جاهز للإصدار',
      name: 'releaseDecisionReady',
      desc: '',
      args: [],
    );
  }

  /// `غير جاهز للإصدار`
  String get releaseDecisionNotReady {
    return Intl.message(
      'غير جاهز للإصدار',
      name: 'releaseDecisionNotReady',
      desc: '',
      args: [],
    );
  }

  /// `تشغيل فحص الجاهزية`
  String get releaseRunReadiness {
    return Intl.message(
      'تشغيل فحص الجاهزية',
      name: 'releaseRunReadiness',
      desc: '',
      args: [],
    );
  }

  /// `العوائق المفتوحة`
  String get releaseOpenBlockers {
    return Intl.message(
      'العوائق المفتوحة',
      name: 'releaseOpenBlockers',
      desc: '',
      args: [],
    );
  }

  /// `نتائج البوابات`
  String get releaseGateResults {
    return Intl.message(
      'نتائج البوابات',
      name: 'releaseGateResults',
      desc: '',
      args: [],
    );
  }

  /// `حرج`
  String get releaseSeverityCritical {
    return Intl.message(
      'حرج',
      name: 'releaseSeverityCritical',
      desc: '',
      args: [],
    );
  }

  /// `مرتفع`
  String get releaseSeverityHigh {
    return Intl.message(
      'مرتفع',
      name: 'releaseSeverityHigh',
      desc: '',
      args: [],
    );
  }

  /// `متوسط`
  String get releaseSeverityMedium {
    return Intl.message(
      'متوسط',
      name: 'releaseSeverityMedium',
      desc: '',
      args: [],
    );
  }

  /// `المصادقة`
  String get releaseAreaAuth {
    return Intl.message(
      'المصادقة',
      name: 'releaseAreaAuth',
      desc: '',
      args: [],
    );
  }

  /// `المعاملات وسياسات الخلفية`
  String get releaseAreaTransactions {
    return Intl.message(
      'المعاملات وسياسات الخلفية',
      name: 'releaseAreaTransactions',
      desc: '',
      args: [],
    );
  }

  /// `التوطين`
  String get releaseAreaLocalization {
    return Intl.message(
      'التوطين',
      name: 'releaseAreaLocalization',
      desc: '',
      args: [],
    );
  }

  /// `الجودة`
  String get releaseAreaQuality {
    return Intl.message(
      'الجودة',
      name: 'releaseAreaQuality',
      desc: '',
      args: [],
    );
  }

  /// `التشغيل`
  String get releaseAreaOperations {
    return Intl.message(
      'التشغيل',
      name: 'releaseAreaOperations',
      desc: '',
      args: [],
    );
  }

  /// `عمليات الإطلاق`
  String get launchOperationsTitle {
    return Intl.message(
      'عمليات الإطلاق',
      name: 'launchOperationsTitle',
      desc: '',
      args: [],
    );
  }

  /// `شغّل ضوابط الإطلاق وتحقق من تغطية البوابات وصعّد المخاطر التشغيلية من شاشة واحدة.`
  String get launchOperationsSubtitle {
    return Intl.message(
      'شغّل ضوابط الإطلاق وتحقق من تغطية البوابات وصعّد المخاطر التشغيلية من شاشة واحدة.',
      name: 'launchOperationsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `تشغيل قائمة الإطلاق`
  String get launchRunChecklist {
    return Intl.message(
      'تشغيل قائمة الإطلاق',
      name: 'launchRunChecklist',
      desc: '',
      args: [],
    );
  }

  /// `القرار`
  String get launchDecisionLabel {
    return Intl.message(
      'القرار',
      name: 'launchDecisionLabel',
      desc: '',
      args: [],
    );
  }

  /// `بانتظار تشغيل القائمة`
  String get launchDecisionPending {
    return Intl.message(
      'بانتظار تشغيل القائمة',
      name: 'launchDecisionPending',
      desc: '',
      args: [],
    );
  }

  /// `إطلاق`
  String get launchDecisionGo {
    return Intl.message('إطلاق', name: 'launchDecisionGo', desc: '', args: []);
  }

  /// `إيقاف`
  String get launchDecisionHold {
    return Intl.message(
      'إيقاف',
      name: 'launchDecisionHold',
      desc: '',
      args: [],
    );
  }

  /// `تصعيد حادث حرج`
  String get launchRaiseCriticalIncident {
    return Intl.message(
      'تصعيد حادث حرج',
      name: 'launchRaiseCriticalIncident',
      desc: '',
      args: [],
    );
  }

  /// `القائمة قيد التشغيل`
  String get launchChecklistRunning {
    return Intl.message(
      'القائمة قيد التشغيل',
      name: 'launchChecklistRunning',
      desc: '',
      args: [],
    );
  }

  /// `تغطية بوابات الإطلاق`
  String get launchChecklistCoverageTitle {
    return Intl.message(
      'تغطية بوابات الإطلاق',
      name: 'launchChecklistCoverageTitle',
      desc: '',
      args: [],
    );
  }

  /// `أبقِ الواجهة الأولى للإطلاق مرتبطة ببوابات واضحة ومالكي الأدلة وجهوزية التصعيد التشغيلي.`
  String get launchChecklistCoverageBody {
    return Intl.message(
      'أبقِ الواجهة الأولى للإطلاق مرتبطة ببوابات واضحة ومالكي الأدلة وجهوزية التصعيد التشغيلي.',
      name: 'launchChecklistCoverageBody',
      desc: '',
      args: [],
    );
  }

  /// `بانتظار المراجعة`
  String get launchChecklistPendingStatus {
    return Intl.message(
      'بانتظار المراجعة',
      name: 'launchChecklistPendingStatus',
      desc: '',
      args: [],
    );
  }

  /// `ناجح`
  String get launchSignalPass {
    return Intl.message('ناجح', name: 'launchSignalPass', desc: '', args: []);
  }

  /// `فشل`
  String get launchSignalFail {
    return Intl.message('فشل', name: 'launchSignalFail', desc: '', args: []);
  }

  /// `غير معروف`
  String get launchSignalUnknown {
    return Intl.message(
      'غير معروف',
      name: 'launchSignalUnknown',
      desc: '',
      args: [],
    );
  }

  /// `التحليل والفحوصات الثابتة`
  String get launchChecklistAnalyzeTitle {
    return Intl.message(
      'التحليل والفحوصات الثابتة',
      name: 'launchChecklistAnalyzeTitle',
      desc: '',
      args: [],
    );
  }

  /// `المالك: جودة تطبيق الجوال`
  String get launchChecklistAnalyzeMeta {
    return Intl.message(
      'المالك: جودة تطبيق الجوال',
      name: 'launchChecklistAnalyzeMeta',
      desc: '',
      args: [],
    );
  }

  /// `فحص الواجهات والمسارات`
  String get launchChecklistWidgetTestsTitle {
    return Intl.message(
      'فحص الواجهات والمسارات',
      name: 'launchChecklistWidgetTestsTitle',
      desc: '',
      args: [],
    );
  }

  /// `المالك: بوابة الانحدار للجوال`
  String get launchChecklistWidgetTestsMeta {
    return Intl.message(
      'المالك: بوابة الانحدار للجوال',
      name: 'launchChecklistWidgetTestsMeta',
      desc: '',
      args: [],
    );
  }

  /// `تغطية التكامل`
  String get launchChecklistIntegrationTitle {
    return Intl.message(
      'تغطية التكامل',
      name: 'launchChecklistIntegrationTitle',
      desc: '',
      args: [],
    );
  }

  /// `المالك: تحقق تدفقات الجودة`
  String get launchChecklistIntegrationMeta {
    return Intl.message(
      'المالك: تحقق تدفقات الجودة',
      name: 'launchChecklistIntegrationMeta',
      desc: '',
      args: [],
    );
  }

  /// `فحوصات سياسات قاعدة البيانات`
  String get launchChecklistDatabaseTitle {
    return Intl.message(
      'فحوصات سياسات قاعدة البيانات',
      name: 'launchChecklistDatabaseTitle',
      desc: '',
      args: [],
    );
  }

  /// `المالك: أمان إصدار الخلفية`
  String get launchChecklistDatabaseMeta {
    return Intl.message(
      'المالك: أمان إصدار الخلفية',
      name: 'launchChecklistDatabaseMeta',
      desc: '',
      args: [],
    );
  }

  /// `التحويل والتراجع`
  String get cutoverTitle {
    return Intl.message(
      'التحويل والتراجع',
      name: 'cutoverTitle',
      desc: '',
      args: [],
    );
  }

  /// `تشغيل التحويل`
  String get cutoverRun {
    return Intl.message(
      'تشغيل التحويل',
      name: 'cutoverRun',
      desc: '',
      args: [],
    );
  }

  /// `التحويل`
  String get cutoverLabel {
    return Intl.message('التحويل', name: 'cutoverLabel', desc: '', args: []);
  }

  /// `تشغيل التراجع`
  String get rollbackRun {
    return Intl.message(
      'تشغيل التراجع',
      name: 'rollbackRun',
      desc: '',
      args: [],
    );
  }

  /// `التراجع`
  String get rollbackLabel {
    return Intl.message('التراجع', name: 'rollbackLabel', desc: '', args: []);
  }

  /// `التحقق`
  String get rollbackVerificationLabel {
    return Intl.message(
      'التحقق',
      name: 'rollbackVerificationLabel',
      desc: '',
      args: [],
    );
  }

  /// `مراقبة الإصدار`
  String get releaseObservabilityTitle {
    return Intl.message(
      'مراقبة الإصدار',
      name: 'releaseObservabilityTitle',
      desc: '',
      args: [],
    );
  }

  /// `تحديث الصحة`
  String get releaseObservabilityRefresh {
    return Intl.message(
      'تحديث الصحة',
      name: 'releaseObservabilityRefresh',
      desc: '',
      args: [],
    );
  }

  /// `الإشارات`
  String get releaseObservabilitySignals {
    return Intl.message(
      'الإشارات',
      name: 'releaseObservabilitySignals',
      desc: '',
      args: [],
    );
  }

  /// `التنبيهات`
  String get releaseObservabilityAlerts {
    return Intl.message(
      'التنبيهات',
      name: 'releaseObservabilityAlerts',
      desc: '',
      args: [],
    );
  }

  /// `تأكيد أول تنبيه`
  String get releaseObservabilityAcknowledge {
    return Intl.message(
      'تأكيد أول تنبيه',
      name: 'releaseObservabilityAcknowledge',
      desc: '',
      args: [],
    );
  }

  /// `تصدير تقرير الاستقرار`
  String get releaseObservabilityExportStable {
    return Intl.message(
      'تصدير تقرير الاستقرار',
      name: 'releaseObservabilityExportStable',
      desc: '',
      args: [],
    );
  }

  /// `لقطة ما بعد الإطلاق`
  String get releaseSnapshotTitle {
    return Intl.message(
      'لقطة ما بعد الإطلاق',
      name: 'releaseSnapshotTitle',
      desc: '',
      args: [],
    );
  }

  /// `إشارة`
  String get releaseSnapshotSignalLabel {
    return Intl.message(
      'إشارة',
      name: 'releaseSnapshotSignalLabel',
      desc: '',
      args: [],
    );
  }

  /// `آخر تصعيد للحوادث`
  String get releaseIncidentTitle {
    return Intl.message(
      'آخر تصعيد للحوادث',
      name: 'releaseIncidentTitle',
      desc: '',
      args: [],
    );
  }

  /// `الرسائل`
  String get releaseSignalMessaging {
    return Intl.message(
      'الرسائل',
      name: 'releaseSignalMessaging',
      desc: '',
      args: [],
    );
  }

  /// `تأكيد إجراء عالي الخطورة`
  String get riskConfirmTitle {
    return Intl.message(
      'تأكيد إجراء عالي الخطورة',
      name: 'riskConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `أنت على وشك تنفيذ:`
  String get riskConfirmBodyPrefix {
    return Intl.message(
      'أنت على وشك تنفيذ:',
      name: 'riskConfirmBodyPrefix',
      desc: '',
      args: [],
    );
  }

  /// `سبب التنفيذ (مطلوب)`
  String get riskRationaleLabel {
    return Intl.message(
      'سبب التنفيذ (مطلوب)',
      name: 'riskRationaleLabel',
      desc: '',
      args: [],
    );
  }

  /// `إلغاء`
  String get riskCancel {
    return Intl.message('إلغاء', name: 'riskCancel', desc: '', args: []);
  }

  /// `تأكيد`
  String get riskConfirmAction {
    return Intl.message('تأكيد', name: 'riskConfirmAction', desc: '', args: []);
  }

  /// `الصفحة غير موجودة`
  String get unknownRouteTitle {
    return Intl.message(
      'الصفحة غير موجودة',
      name: 'unknownRouteTitle',
      desc: '',
      args: [],
    );
  }

  /// `المسار غير صالح أو غير متاح:`
  String get unknownRouteBody {
    return Intl.message(
      'المسار غير صالح أو غير متاح:',
      name: 'unknownRouteBody',
      desc: '',
      args: [],
    );
  }

  /// `العودة للرئيسية`
  String get unknownRouteGoHome {
    return Intl.message(
      'العودة للرئيسية',
      name: 'unknownRouteGoHome',
      desc: '',
      args: [],
    );
  }

  /// `إظهار كلمة المرور`
  String get showPassword {
    return Intl.message(
      'إظهار كلمة المرور',
      name: 'showPassword',
      desc: '',
      args: [],
    );
  }

  /// `إخفاء كلمة المرور`
  String get hidePassword {
    return Intl.message(
      'إخفاء كلمة المرور',
      name: 'hidePassword',
      desc: '',
      args: [],
    );
  }

  /// `الرئيسية`
  String get navHome {
    return Intl.message('الرئيسية', name: 'navHome', desc: '', args: []);
  }

  /// `المحفوظات`
  String get navSaved {
    return Intl.message('المحفوظات', name: 'navSaved', desc: '', args: []);
  }

  /// `الرسائل`
  String get navMessages {
    return Intl.message('الرسائل', name: 'navMessages', desc: '', args: []);
  }

  /// `الحساب`
  String get navAccount {
    return Intl.message('الحساب', name: 'navAccount', desc: '', args: []);
  }

  /// `الإعلانات`
  String get navListings {
    return Intl.message('الإعلانات', name: 'navListings', desc: '', args: []);
  }

  /// `الطوابير`
  String get navQueues {
    return Intl.message('الطوابير', name: 'navQueues', desc: '', args: []);
  }

  /// `البلاغات`
  String get navReports {
    return Intl.message('البلاغات', name: 'navReports', desc: '', args: []);
  }

  /// `الفريق`
  String get navTeam {
    return Intl.message('الفريق', name: 'navTeam', desc: '', args: []);
  }

  /// `فتح الروابط في قطعك؟`
  String get appLinksPromptTitle {
    return Intl.message(
      'فتح الروابط في قطعك؟',
      name: 'appLinksPromptTitle',
      desc: '',
      args: [],
    );
  }

  /// `اسمح لقطعك بفتح روابط المنتجات مباشرةً دون الحاجة للاختيار في كل مرة.`
  String get appLinksPromptBody {
    return Intl.message(
      'اسمح لقطعك بفتح روابط المنتجات مباشرةً دون الحاجة للاختيار في كل مرة.',
      name: 'appLinksPromptBody',
      desc: '',
      args: [],
    );
  }

  /// `فتح الإعدادات`
  String get appLinksPromptAction {
    return Intl.message(
      'فتح الإعدادات',
      name: 'appLinksPromptAction',
      desc: '',
      args: [],
    );
  }

  /// `ليس الآن`
  String get appLinksPromptDismiss {
    return Intl.message(
      'ليس الآن',
      name: 'appLinksPromptDismiss',
      desc: '',
      args: [],
    );
  }

  /// `الإعداد مطلوب`
  String get appConfigurationRequiredTitle {
    return Intl.message(
      'الإعداد مطلوب',
      name: 'appConfigurationRequiredTitle',
      desc: '',
      args: [],
    );
  }

  /// `إعدادات Supabase غير متوفرة أثناء التشغيل. وفّر SUPABASE_URL وSUPABASE_ANON_KEY قبل تشغيل التطبيق.`
  String get appConfigurationRequiredBody {
    return Intl.message(
      'إعدادات Supabase غير متوفرة أثناء التشغيل. وفّر SUPABASE_URL وSUPABASE_ANON_KEY قبل تشغيل التطبيق.',
      name: 'appConfigurationRequiredBody',
      desc: '',
      args: [],
    );
  }

  /// `{amount} د.ج`
  String priceWithDzd(Object amount) {
    return Intl.message(
      '$amount د.ج',
      name: 'priceWithDzd',
      desc: '',
      args: [amount],
    );
  }

  /// `{count} ملف`
  String disputeEvidenceCount(Object count) {
    return Intl.message(
      '$count ملف',
      name: 'disputeEvidenceCount',
      desc: '',
      args: [count],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'ar'),
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'fr'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
