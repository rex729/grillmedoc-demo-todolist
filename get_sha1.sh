#!/usr/bin/env bash
"/c/Program Files/Android/Android Studio/jbr/bin/keytool.exe" -J-Duser.language=en -list -v -keystore "C:/Users/user/.android/debug.keystore" -alias androiddebugkey -storepass android -keypass android | grep -E "SHA1:|SHA256:"
