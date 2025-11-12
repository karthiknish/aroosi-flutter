# Aroosi Privacy Policy

_Last updated: 10 November 2025_

Aroosi (“we”, “our”, “us”) is committed to protecting your privacy. This policy explains what data we collect through the Aroosi mobile applications and related services, how we use it, the partners who help us process it, and how you can exercise your rights.

The policy covers all users of the Aroosi app who are 18 years of age or older. By creating an account or using the service you acknowledge that you have read and understood this policy.

## 1. Data We Collect

### 1.1 Data You Provide Directly
- **Account details:** email address, password (hashed by Firebase Authentication), display name, optional phone number.
- **Profile information:** age range, city or region, cultural preferences, biography, relationship goals, and other profile fields you choose to fill out.
- **Content you share:** profile photos, optional voice notes, messages, likes, match responses, and feedback you submit.
- **Support requests:** information you provide when contacting customer support or reporting a safety concern.

### 1.2 Data Collected Automatically via Firebase SDKs
| Firebase service | Data collected | Collection method | Purpose |
| --- | --- | --- | --- |
| Firebase Authentication | Firebase UID, authentication tokens, multi-factor enrollment state | Generated during sign-up/login | Secure sign-in, session management, fraud prevention |
| Cloud Firestore | Profile records, match metadata, chat metadata, consent preferences, moderation flags | Created or updated when you use core features | Deliver matching, messaging, safety, and cultural compatibility workflows |
| Firebase Storage | Photos and audio files you upload, associated metadata (file size, upload time) | Captured when you pick media | Store and deliver the content you choose to share |
| Firebase Cloud Messaging (FCM) & Apple Push Notification service (APNs) | Firebase Installation ID, APNs device token, notification delivery and interaction data | Generated automatically after you opt in to notifications | Deliver requested push notifications and improve reliability |
| Firebase Analytics / Google Analytics for Firebase | App instance ID, session timestamps, screen views, feature usage events, device model, OS version, truncated IP, language, carrier | Automatic once you opt in via the privacy dialog or settings | Understand feature adoption, improve onboarding, prioritize roadmap |
| Firebase Performance Monitoring | Network trace metadata (domain, latency, success/failure), app start time, screen render times, CPU and memory metrics | Automatic once you opt in to diagnostics | Detect outages, optimize performance, reduce latency |
| Firebase Crashlytics & Firebase Sessions | Crash stack traces, device state at crash (model, OS version, battery level, free RAM/storage), anonymized session IDs | Automatic on crash when diagnostics are enabled | Investigate crashes, improve stability |
| Firebase Installations | Unique Firebase Installation ID, token refresh history | Generated on first launch | Deduplicate analytics, manage push tokens, enforce security |

We **do not** collect precise geolocation, contacts, health data, or device sensor data. Any location shown in your profile is entered by you manually.

### 1.3 Data from Your Device
If you consent, we access the camera, photo library, and microphone strictly to allow you to create and manage profile content. We do not scan your library in the background and only interact with files you explicitly select.

## 2. How We Use the Data
- **Account management:** create and secure accounts, authenticate sessions, support password recovery, and prevent unauthorized access.
- **Core functionality:** enable matching, messaging, compatibility scoring, moderation, and cultural safety features.
- **Communications:** send opted-in notifications about matches, messages, profile updates, and important account alerts.
- **Analytics and product improvement:** measure feature adoption and funnel performance (only when you have provided consent).
- **Diagnostics:** troubleshoot crashes, monitor performance regressions, and protect the platform against abuse or spam.

We never use your information for advertising or to build profiles for third-party marketing.

## 3. Data Sharing and International Transfers
We share data with the following processors who help us deliver the service:
- **Google LLC (Firebase and Google Cloud Platform):** provides authentication, databases, storage, analytics, performance, crash reporting, and messaging infrastructure. Google processes data on our behalf in Google Cloud data centers that comply with ISO 27001, SOC 2 Type II, GDPR, and CCPA requirements.
- **Apple Inc. (APNs):** receives your APNs token to deliver iOS push notifications you opt in to receive.

We require all processors to provide equal or stronger protections than those described in this policy. We do not sell or rent personal data to third parties. If we add new partners, we will update this policy and notify you in-app or via email when required.

Because Firebase operates globally, your information may be stored or processed outside of your home country. We rely on standard contractual clauses and other safeguards recognized by applicable law to transfer personal data internationally.

## 4. Consent and Controls
- During onboarding we ask for explicit consent before enabling analytics, performance monitoring, or push notifications.
- You can manage analytics, diagnostics, and notification preferences at any time under **Settings → Privacy**.
- Declining analytics or diagnostics does not affect your ability to use core account features.
- If you revoke notification permission at the operating-system level, we stop using APNs/FCM tokens associated with your device.

## 5. Data Retention
- **Account and profile data:** kept for the duration of your account. Deleted within 30 days after you confirm an account deletion request.
- **Messages and moderation logs:** retained for up to 6 months after deletion to investigate abuse or legal inquiries, then removed.
- **Uploaded media:** deleted from Firebase Storage when you remove it or when your account is deleted.
- **Analytics & diagnostics:** retained by Google for up to 13 months according to Firebase defaults, then aggregated or deleted.
- **Backup copies:** stored securely and purged on a rolling schedule; deletion requests are cascaded to backups within a reasonable operational window unless we must retain data to comply with legal obligations or to resolve disputes.

## 6. Your Rights
Depending on your location, you may have the right to:
- Access the personal data we hold about you.
- Correct inaccurate or incomplete information.
- Request deletion of your data.
- Withdraw consent for analytics, diagnostics, or notifications.
- Receive a copy of your data in a portable format.
- Lodge a complaint with a supervisory authority.

You can exercise these rights through the in-app Privacy settings or by contacting us at privacy@aroosi.af. We respond within 30 days. If we cannot comply with your request for legal or safety reasons, we will explain why.

## 7. Security Measures
We secure your information using:
- TLS/SSL encryption in transit and Google-managed encryption at rest.
- Role-based access controls and the principle of least privilege for staff and contractors.
- Automated monitoring, logging, and anomaly detection.
- Regular security reviews, dependency management, and penetration testing.

## 8. Eligibility and Age Restrictions
Aroosi is intended for adults 18 years and older. We do not knowingly collect information from minors. If we learn that an underage user has created an account, we suspend the profile and delete associated data. You can report suspected underage accounts to privacy@aroosi.af.

## 9. Changes to This Policy
We may update this policy to reflect changes in law, our services, or data practices. Material updates will be announced in-app and via email (if available) before they take effect. Your continued use of Aroosi after an update means you accept the revised policy.

## 10. Contact Us
If you have questions about this policy or wish to exercise your rights, contact us:

- Email: privacy@aroosi.af
- Mailing address: Privacy Officer, Aroosi, Kabul, Afghanistan

We are committed to working with you to resolve privacy concerns quickly and transparently.