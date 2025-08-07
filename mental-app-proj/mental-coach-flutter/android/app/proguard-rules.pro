# Flutter specific rules for ProGuard.
-dontwarn io.flutter.embedding.**
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugins.*.* { *; }

# Added for Kotlin metadata issue with R8
-keep class kotlin.Metadata { *; }
-keep class kotlin.coroutines.jvm.internal.BaseContinuationImpl {
    <init>(kotlin.coroutines.Continuation);
}
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory { *; }
-keepnames class kotlinx.coroutines.android.AndroidDispatcherFactory { *; }
-keepnames class kotlinx.coroutines.android.AndroidExceptionPreHandler { *; }
-keep class kotlinx.coroutines.main.MainCoroutineDispatcher { *; }
-keepnames class kotlinx.coroutines.DefaultExecutor { *; }
-keepnames class kotlinx.coroutines.test.internal.TestMainDispatcherFactory { *; }
-keepnames class kotlinx.coroutines.test.TestCoroutineScheduler { *; }
-keepnames class kotlinx.coroutines.test.TestDispatcher { *; }
-keepnames class kotlinx.coroutines.test.TestResult { *; }
