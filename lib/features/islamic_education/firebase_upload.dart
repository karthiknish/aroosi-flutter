import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';
import 'content_data.dart';
import 'services.dart';
import 'package:aroosi_flutter/utils/debug_logger.dart';
import 'package:flutter/services.dart' show rootBundle;

class IslamicEducationFirebaseUploader {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Upload all initial educational content to Firebase
  static Future<void> uploadInitialContent() async {
    try {
      logDebug('Starting upload of Islamic educational content');

      // Get initial content data
      final contentList = IslamicEducationalContentData.getInitialContent();
      final traditionsList = IslamicEducationalContentData.getAfghanTraditions();

      // Upload educational content
      for (final content in contentList) {
        await IslamicEducationService.uploadEducationalContent(content);
        logDebug('Uploaded content', data: {'title': content.title});
      }

      // Upload Afghan traditions
      for (final tradition in traditionsList) {
        await IslamicEducationService.uploadAfghanTradition(tradition);
        logDebug('Uploaded tradition', data: {'name': tradition.name});
      }

      logDebug('Successfully uploaded all content to Firebase');
    } catch (e) {
      logDebug('Error uploading content', error: e);
      rethrow;
    }
  }

  /// Upload a single content item
  static Future<String> uploadSingleContent(IslamicEducationalContent content) async {
    try {
      // Add search terms for better searchability
      final searchTerms = <String>[
        content.title.toLowerCase(),
        content.description.toLowerCase(),
        ...?content.tags?.map((tag) => tag.toLowerCase()),
      ];

      final contentWithSearch = content.toJson();
      contentWithSearch['searchTerms'] = searchTerms;

      final docRef = await _firestore.collection('islamic_educational_content').add(contentWithSearch);
      logDebug('Uploaded content', data: {'title': content.title, 'id': docRef.id});
      return docRef.id;
    } catch (e) {
      logDebug('Error uploading content', error: e, data: {'title': content.title});
      rethrow;
    }
  }

  /// Upload a single Afghan tradition
  static Future<String> uploadSingleTradition(AfghanCulturalTradition tradition) async {
    try {
      final docRef = await _firestore.collection('afghan_cultural_traditions').add(tradition.toJson());
      logDebug('Uploaded tradition', data: {'name': tradition.name, 'id': docRef.id});
      return docRef.id;
    } catch (e) {
      logDebug('Error uploading tradition', error: e, data: {'name': tradition.name});
      rethrow;
    }
  }

  /// Create indexes for better query performance
  static Future<void> createIndexes() async {
    try {
      // Create indexes for content collection
      await _firestore.collection('islamic_educational_content')
          .doc('_indexes')
          .set({
        'created_at': Timestamp.now(),
        'indexes': [
          'category',
          'contentType',
          'difficultyLevel',
          'isFeatured',
          'createdAt',
          'searchTerms',
        ],
      });

      // Create indexes for traditions collection
      await _firestore.collection('afghan_cultural_traditions')
          .doc('_indexes')
          .set({
        'created_at': Timestamp.now(),
        'indexes': [
          'category',
          'region',
        ],
      });

      logDebug('Indexes created successfully');
    } catch (e) {
      logDebug('Error creating indexes', error: e);
    }
  }

  /// Verify upload by checking if content exists
  static Future<bool> verifyUpload() async {
    try {
      final contentSnapshot = await _firestore
          .collection('islamic_educational_content')
          .limit(1)
          .get();

      final traditionsSnapshot = await _firestore
          .collection('afghan_cultural_traditions')
          .limit(1)
          .get();

      return contentSnapshot.docs.isNotEmpty && traditionsSnapshot.docs.isNotEmpty;
    } catch (e) {
      logDebug('Error verifying upload', error: e);
      return false;
    }
  }

  /// Clear all uploaded content (use with caution!)
  static Future<void> clearAllContent() async {
    try {
      logDebug('WARNING: Clearing all educational content');
      
      // Clear educational content
      final contentSnapshot = await _firestore.collection('islamic_educational_content').get();
      for (final doc in contentSnapshot.docs) {
        await doc.reference.delete();
      }

      // Clear traditions
      final traditionsSnapshot = await _firestore.collection('afghan_cultural_traditions').get();
      for (final doc in traditionsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Clear progress data
      final progressSnapshot = await _firestore.collection('user_education_progress').get();
      for (final doc in progressSnapshot.docs) {
        await doc.reference.delete();
      }

      logDebug('All content cleared successfully');
    } catch (e) {
      logDebug('Error clearing content', error: e);
    }
  }

  /// Get upload statistics
  static Future<Map<String, dynamic>> getUploadStatistics() async {
    try {
      final contentCount = await _firestore
          .collection('islamic_educational_content')
          .count()
          .get();

      final traditionsCount = await _firestore
          .collection('afghan_cultural_traditions')
          .count()
          .get();

      final featuredCount = await _firestore
          .collection('islamic_educational_content')
          .where('isFeatured', isEqualTo: true)
          .count()
          .get();

      return {
        'totalContent': contentCount.count,
        'totalTraditions': traditionsCount.count,
        'featuredContent': featuredCount.count,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      logDebug('Error getting statistics', error: e);
      return {};
    }
  }

  /// Upload sample images to Firebase Storage
  /// Note: This is a utility function for admin/development use
  /// In production, images should be uploaded through the proper content management flow
  static Future<List<Map<String, String>>> uploadSampleImages() async {
    final uploads = <Map<String, String>>[];
    try {
      final sampleImages = [
        'assets/images/islamic_marriage_principles.jpg',
        'assets/images/afghan_wedding.jpg',
        'assets/images/quranic_verses.jpg',
        'assets/images/prophetic_teachings.jpg',
      ];

      for (final imagePath in sampleImages) {
        try {
          final byteData = await rootBundle.load(imagePath);
          final bytes = byteData.buffer.asUint8List();
          final filename = imagePath.split('/').last;

          final downloadUrl = await IslamicEducationService.uploadImageToStorage(
            data: bytes,
            fileName: filename,
            metadata: {
              'sourcePath': imagePath,
              'uploadedAt': DateTime.now().toIso8601String(),
              'uploader': 'admin-sample-script',
            },
          );

          uploads.add({'path': imagePath, 'url': downloadUrl});
          logDebug('Uploaded sample image', data: {
            'path': imagePath,
            'filename': filename,
            'url': downloadUrl,
          });
        } catch (e) {
          logDebug(
            'Error uploading sample image',
            error: e,
            data: {'path': imagePath},
          );
        }
      }

      logDebug('Sample image upload process completed', data: {
        'uploaded': uploads.length,
      });
      return uploads;
    } catch (e) {
      logDebug('Error in uploadSampleImages', error: e);
      rethrow;
    }
  }
}

// Admin utility class for content management
class IslamicEducationAdminUtil {
  /// Update existing content
  static Future<void> updateContent(String contentId, Map<String, dynamic> updates) async {
    try {
      await FirebaseFirestore.instance
          .collection('islamic_educational_content')
          .doc(contentId)
          .update(updates);
      logDebug('Updated content', data: {'contentId': contentId});
    } catch (e) {
      logDebug('Error updating content', error: e);
    }
  }

  /// Update tradition
  static Future<void> updateTradition(String traditionId, Map<String, dynamic> updates) async {
    try {
      await FirebaseFirestore.instance
          .collection('afghan_cultural_traditions')
          .doc(traditionId)
          .update(updates);
      logDebug('Updated tradition', data: {'traditionId': traditionId});
    } catch (e) {
      logDebug('Error updating tradition', error: e);
    }
  }

  /// Get content analytics
  static Future<Map<String, dynamic>> getContentAnalytics() async {
    try {
      final contentSnapshot = await FirebaseFirestore.instance
          .collection('islamic_educational_content')
          .get();

      int totalViews = 0;
      int totalLikes = 0;
      int totalBookmarks = 0;
      final Map<String, int> categoryCounts = {};

      for (final doc in contentSnapshot.docs) {
        final data = doc.data();
        totalViews += (data['viewCount'] as int? ?? 0);
        totalLikes += (data['likeCount'] as int? ?? 0);
        totalBookmarks += (data['bookmarkCount'] as int? ?? 0);
        
        final category = data['category'] as String? ?? 'general';
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
      }

      return {
        'totalContent': contentSnapshot.docs.length,
        'totalViews': totalViews,
        'totalLikes': totalLikes,
        'totalBookmarks': totalBookmarks,
        'categoryDistribution': categoryCounts,
      };
    } catch (e) {
      logDebug('Error getting analytics', error: e);
      return {};
    }
  }

  /// Feature/unfeature content
  static Future<void> toggleFeaturedContent(String contentId, bool isFeatured) async {
    try {
      await FirebaseFirestore.instance
          .collection('islamic_educational_content')
          .doc(contentId)
          .update({'isFeatured': isFeatured});
      
      logDebug('${isFeatured ? 'Featured' : 'Unfeatured'} content', data: {'contentId': contentId});
    } catch (e) {
      logDebug('Error updating featured status', error: e);
    }
  }

  /// Bulk update content
  static Future<void> bulkUpdateContent(
    List<String> contentIds,
    Map<String, dynamic> updates,
  ) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      
      for (final contentId in contentIds) {
        final docRef = FirebaseFirestore.instance
            .collection('islamic_educational_content')
            .doc(contentId);
        batch.update(docRef, updates);
      }
      
      await batch.commit();
      logDebug('Bulk updated content items', data: {'count': contentIds.length});
    } catch (e) {
      logDebug('Error in bulk update', error: e);
    }
  }
}
