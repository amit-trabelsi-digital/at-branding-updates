# Flutter Web Docker Build - Optimized for External Services
FROM ghcr.io/cirruslabs/flutter:stable AS build

# הגדרת משתני בילד
ARG FLUTTER_ENV=docker
ARG API_URL=http://localhost:3000/api
ARG FIREBASE_WEB_API_KEY=""
ARG FIREBASE_WEB_AUTH_DOMAIN=""
ARG FIREBASE_WEB_PROJECT_ID=""
ARG FIREBASE_WEB_STORAGE_BUCKET=""
ARG FIREBASE_WEB_MESSAGING_SENDER_ID=""
ARG FIREBASE_WEB_APP_ID=""
ARG RECAPTCHA_SITE_KEY=""

# העתקת קבצי הפרויקט
WORKDIR /app
COPY pubspec.* ./
RUN flutter pub get

# העתקת כל הפרויקט
COPY . .

# בנייה עם משתני סביבה
RUN flutter build web --release \
    --dart-define=FLUTTER_ENV=$FLUTTER_ENV \
    --dart-define=API_URL=$API_URL \
    --dart-define=FIREBASE_WEB_API_KEY=$FIREBASE_WEB_API_KEY \
    --dart-define=FIREBASE_WEB_AUTH_DOMAIN=$FIREBASE_WEB_AUTH_DOMAIN \
    --dart-define=FIREBASE_WEB_PROJECT_ID=$FIREBASE_WEB_PROJECT_ID \
    --dart-define=FIREBASE_WEB_STORAGE_BUCKET=$FIREBASE_WEB_STORAGE_BUCKET \
    --dart-define=FIREBASE_WEB_MESSAGING_SENDER_ID=$FIREBASE_WEB_MESSAGING_SENDER_ID \
    --dart-define=FIREBASE_WEB_APP_ID=$FIREBASE_WEB_APP_ID \
    --dart-define=RECAPTCHA_SITE_KEY=$RECAPTCHA_SITE_KEY

# Nginx stage להגשת האפליקציה
FROM nginx:alpine

# התקנת gettext עבור envsubst
RUN apk add --no-cache gettext

# העתקת הבילד
COPY --from=build /app/build/web /usr/share/nginx/html

# העתקת קבצי קונפיגורציה
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# העתקת assets ותמונות (אם קיימים)
COPY --from=build /app/assets /usr/share/nginx/html/assets 2>/dev/null || true
COPY --from=build /app/images /usr/share/nginx/html/images 2>/dev/null || true
COPY --from=build /app/icons /usr/share/nginx/html/icons 2>/dev/null || true

# יצירת טמפלייט לקונפיגורציה דינמית
RUN echo 'window.APP_CONFIG = { apiUrl: "${API_URL}", environment: "${FLUTTER_ENV}" };' > /usr/share/nginx/html/config.js.template

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]