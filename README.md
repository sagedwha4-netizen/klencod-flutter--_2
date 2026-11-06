# تطبيق جامعتي - Flutter

تطبيق عربي بسيط لإدارة المحاضرات والمهام والدرجات، مع حفظ البيانات محلياً على الجهاز.

## المتطلبات
- Flutter SDK
- Android Studio أو VS Code
- Android SDK عند بناء نسخة Android

## التشغيل
1. فك ضغط الملف.
2. افتح المجلد `my_university_flutter` في VS Code أو Android Studio.
3. افتح Terminal داخل المجلد.
4. نفّذ:
   ```bash
   flutter create .
   flutter pub get
   flutter run
   ```

أمر `flutter create .` ينشئ ملفات المنصات (Android وغيرها) اللازمة للتشغيل في بيئتك، مع الإبقاء على ملفات `lib` و`pubspec.yaml`.

## إنشاء APK
```bash
flutter build apk --release
```
مسار APK:
`build/app/outputs/flutter-apk/app-release.apk`

## محتويات التطبيق
- الرئيسية: ملخص المحاضرات والمهام ومتوسط الدرجات.
- المحاضرات: إضافة وحذف المادة واليوم والوقت.
- المهام: إضافة المهام وتحديد المكتمل منها وحذفها.
- الدرجات: إضافة درجات المواد وحساب المتوسط المئوي.
- التخزين: حفظ البيانات محلياً باستخدام shared_preferences.

## ملاحظة
هذه نسخة أولية تعليمية تعمل محلياً دون حساب مستخدم أو مزامنة سحابية أو إشعارات مجدولة.
