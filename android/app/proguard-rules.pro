# flutter_local_notifications stores scheduled notifications with Gson and
# reads them back through TypeToken; R8 strips the generic signatures and the
# boot/update receiver then crashes with "Missing type parameter".
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keep class com.dexterous.** { *; }
