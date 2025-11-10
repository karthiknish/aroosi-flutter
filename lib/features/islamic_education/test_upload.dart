import 'dart:io';

import 'firebase_upload.dart';

/// Test script to upload Islamic educational content to Firebase
/// Run this script once to populate your Firebase database with initial content

Future<void> main() async {
  stdout.writeln('🕌 Islamic Educational Content Upload Test');
  stdout.writeln('==========================================');
  
  // Step 1: Upload all content
  stdout.writeln('\n📚 Step 1: Uploading educational content...');
  await IslamicEducationFirebaseUploader.uploadInitialContent();
  
  // Step 2: Create indexes for better performance
  stdout.writeln('\n🔍 Step 2: Creating database indexes...');
  await IslamicEducationFirebaseUploader.createIndexes();
  
  // Step 3: Verify upload
  stdout.writeln('\n✅ Step 3: Verifying upload...');
  final isUploaded = await IslamicEducationFirebaseUploader.verifyUpload();
  if (isUploaded) {
    stdout.writeln('✅ Content successfully uploaded to Firebase!');
  } else {
    stdout.writeln('❌ Upload verification failed!');
  }
  
  // Step 4: Get statistics
  stdout.writeln('\n📊 Step 4: Getting upload statistics...');
  final stats = await IslamicEducationFirebaseUploader.getUploadStatistics();
  stdout.writeln('Statistics: $stats');
  
  // Step 5: Upload sample image references
  stdout.writeln('\n🖼️  Step 5: Uploading sample image references...');
  await IslamicEducationFirebaseUploader.uploadSampleImages();
  
  stdout.writeln('\n🎉 Upload process completed successfully!');
  stdout.writeln('\nYou can now use the Islamic Education features in the app.');
}

/// To run this test:
/// 1. Make sure your Firebase configuration is set up correctly
/// 2. Run: dart run lib/features/islamic_education/test_upload.dart
/// 3. Check your Firebase Firestore to see the uploaded content
