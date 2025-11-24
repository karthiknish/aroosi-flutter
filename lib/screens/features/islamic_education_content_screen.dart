import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/colors.dart';
import '../../core/toast_service.dart';
import '../../features/islamic_education/models.dart';
import '../../features/islamic_education/services.dart';
import '../../features/auth/auth_controller.dart';
import 'islamic_education_quiz_screen.dart';
import '../../widgets/app_scaffold.dart';

class IslamicEducationContentScreen extends ConsumerStatefulWidget {
  final IslamicEducationalContent content;

  const IslamicEducationContentScreen({
    super.key,
    required this.content,
  });

  @override
  ConsumerState<IslamicEducationContentScreen> createState() => _IslamicEducationContentScreenState();
}

class _IslamicEducationContentScreenState extends ConsumerState<IslamicEducationContentScreen> {
  final double _readingProgress = 0.0;
  bool _isBookmarked = false;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _trackContentStart();
  }

  Future<void> _trackContentStart() async {
    // Track that user started reading this content
    // This would normally get current user ID from auth
    final userId = _currentUserId;
    if (userId == null) return;
    await IslamicEducationService.trackContentProgress(
      userId: userId,
      contentId: widget.content.id,
      progress: 0.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.content.title,
      usePadding: false,
      actions: [
        IconButton(
          icon: Icon(
            _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          ),
          onPressed: _toggleBookmark,
        ),
        IconButton(
          icon: Icon(
            _isLiked ? Icons.favorite : Icons.favorite_border,
          ),
          onPressed: _toggleLike,
        ),
      ],
      child: Column(
        children: [
          // Progress indicator
          _buildProgressBar(),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  ...widget.content.content.sections.map((section) {
                    return _buildContentSection(section);
                  }),
                  
                  if (widget.content.content.quranicVerses != null) ...[
                    const SizedBox(height: 24),
                    _buildQuranicVerses(),
                  ],
                  
                  if (widget.content.content.hadiths != null) ...[
                    const SizedBox(height: 24),
                    _buildHadiths(),
                  ],
                  
                  if (widget.content.content.keyTakeaways != null) ...[
                    const SizedBox(height: 24),
                    _buildKeyTakeaways(),
                  ],
                  
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: LinearProgressIndicator(
        value: _readingProgress,
        backgroundColor: AppColors.borderPrimary,
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getCategoryLabel(widget.content.category),
                style: GoogleFonts.nunitoSans(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getDifficultyLabel(widget.content.difficultyLevel),
                style: GoogleFonts.nunitoSans(
                  fontSize: 12,
                  color: AppColors.text,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          widget.content.title,
          style: GoogleFonts.nunitoSans(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.content.description,
          style: GoogleFonts.nunitoSans(
            fontSize: 16,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: 16,
              color: AppColors.muted,
            ),
            const SizedBox(width: 4),
            Text(
              '${widget.content.estimatedReadTime} min read',
              style: GoogleFonts.nunitoSans(
                fontSize: 14,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              Icons.visibility,
              size: 16,
              color: AppColors.muted,
            ),
            const SizedBox(width: 4),
            Text(
              '${widget.content.viewCount} views',
              style: GoogleFonts.nunitoSans(
                fontSize: 14,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContentSection(ContentSection section) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: GoogleFonts.nunitoSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            section.content,
            style: GoogleFonts.nunitoSans(
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuranicVerses() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.menu_book,
                color: AppColors.success,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Quranic Verses',
                style: GoogleFonts.nunitoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.content.content.quranicVerses!.map((verse) {
            return _QuranicVerseCard(verse: verse);
          }),
        ],
      ),
    );
  }

  Widget _buildHadiths() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.mosque,
                color: AppColors.info,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Prophetic Teachings',
                style: GoogleFonts.nunitoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.content.content.hadiths!.map((hadith) {
            return _HadithCard(hadith: hadith);
          }),
        ],
      ),
    );
  }

  Widget _buildKeyTakeaways() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.warning,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Key Takeaways',
                style: GoogleFonts.nunitoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.content.content.keyTakeaways!.map((takeaway) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: AppColors.warning,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      takeaway,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (widget.content.quiz != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _navigateToQuiz,
              icon: const Icon(Icons.quiz),
              label: Text(
                'Take Quiz',
                style: GoogleFonts.nunitoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        
        if (widget.content.quiz != null) const SizedBox(height: 12),
      ],
    );
  }

  Future<void> _toggleBookmark() async {
    final userId = _currentUserId;
    if (userId == null) {
      _showAuthRequiredMessage();
      return;
    }

    final shouldBookmark = !_isBookmarked;
    setState(() => _isBookmarked = shouldBookmark);

    try {
      if (shouldBookmark) {
        await IslamicEducationService.bookmarkContent(widget.content.id, userId);
      } else {
        await IslamicEducationService.removeBookmark(widget.content.id, userId);
      }
    } catch (e) {
      setState(() => _isBookmarked = !shouldBookmark);
      if (mounted) {
        ToastService.instance.error('Unable to update bookmark: $e');
      }
    }
  }

  Future<void> _toggleLike() async {
    final userId = _currentUserId;
    if (userId == null) {
      _showAuthRequiredMessage();
      return;
    }

    final shouldLike = !_isLiked;
    setState(() => _isLiked = shouldLike);

    try {
      if (shouldLike) {
        await IslamicEducationService.likeContent(widget.content.id, userId);
      } else {
        await IslamicEducationService.unlikeContent(widget.content.id, userId);
      }
    } catch (e) {
      setState(() => _isLiked = !shouldLike);
      if (mounted) {
        ToastService.instance.error('Unable to update like: $e');
      }
    }
  }

  void _navigateToQuiz() {
    final userId = _currentUserId;
    if (userId == null) {
      _showAuthRequiredMessage();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IslamicEducationQuizScreen(
          quiz: widget.content.quiz!,
          contentId: widget.content.id,
          contentTitle: widget.content.title,
          currentUserId: userId,
        ),
      ),
    );
  }

  String? get _currentUserId => ref.read(authControllerProvider).profile?.id;

  void _showAuthRequiredMessage() {
    if (!mounted) return;
    ToastService.instance.warning('Please sign in to use this feature.');
  }


  String _getCategoryLabel(EducationCategory category) {
    switch (category) {
      case EducationCategory.marriagePrinciples:
        return 'Marriage Principles';
      case EducationCategory.quranicGuidance:
        return 'Quranic Guidance';
      case EducationCategory.propheticTeachings:
        return 'Prophetic Teachings';
      case EducationCategory.afghanCulture:
        return 'Afghan Culture';
      case EducationCategory.familyLife:
        return 'Family Life';
      case EducationCategory.communication:
        return 'Communication';
      case EducationCategory.conflictResolution:
        return 'Conflict Resolution';
      case EducationCategory.financialManagement:
        return 'Financial Management';
      case EducationCategory.parenting:
        return 'Parenting';
      case EducationCategory.general:
        return 'General';
    }
  }

  String _getDifficultyLabel(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.beginner:
        return 'Beginner';
      case DifficultyLevel.intermediate:
        return 'Intermediate';
      case DifficultyLevel.advanced:
        return 'Advanced';
    }
  }
}

class _QuranicVerseCard extends StatelessWidget {
  final QuranicVerse verse;

  const _QuranicVerseCard({required this.verse});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Surah ${verse.surahNumber}:${verse.ayahNumber}',
            style: GoogleFonts.nunitoSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            verse.arabicText,
            style: GoogleFonts.notoSansArabic(
              fontSize: 18,
              height: 1.8,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 12),
          Text(
            verse.englishTranslation,
            style: GoogleFonts.nunitoSans(
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
          if (verse.transliteration.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              verse.transliteration,
              style: GoogleFonts.nunitoSans(
                fontSize: 12,
                color: AppColors.muted,
              ),
            ),
          ],
          if (verse.relevanceToMarriage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '💡 ${verse.relevanceToMarriage}',
                style: GoogleFonts.nunitoSans(
                  fontSize: 12,
                  color: AppColors.success,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HadithCard extends StatelessWidget {
  final Hadith hadith;

  const _HadithCard({required this.hadith});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _getHadithSourceLabel(hadith.source),
                style: GoogleFonts.nunitoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: _getAuthenticityColor(hadith.authenticityGrade).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getAuthenticityLabel(hadith.authenticityGrade),
                  style: GoogleFonts.nunitoSans(
                    fontSize: 10,
                    color: _getAuthenticityColor(hadith.authenticityGrade),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Narrated by ${hadith.narrator}',
            style: GoogleFonts.nunitoSans(
              fontSize: 12,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            hadith.arabicText,
            style: GoogleFonts.notoSansArabic(
              fontSize: 16,
              height: 1.8,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 12),
          Text(
            hadith.englishTranslation,
            style: GoogleFonts.nunitoSans(
              fontSize: 14,
            ),
          ),
          if (hadith.relevanceToMarriage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '💡 ${hadith.relevanceToMarriage}',
                style: GoogleFonts.nunitoSans(
                  fontSize: 12,
                  color: AppColors.info,
                ),
              ),
            ),
          ],
          if (hadith.explanation != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '📖 ${hadith.explanation}',
                style: GoogleFonts.nunitoSans(
                  fontSize: 12,
                  color: AppColors.text,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getHadithSourceLabel(HadithSource source) {
    switch (source) {
      case HadithSource.bukhari:
        return 'Sahih Bukhari';
      case HadithSource.muslim:
        return 'Sahih Muslim';
      case HadithSource.abuDawud:
        return 'Abu Dawud';
      case HadithSource.tirmidhi:
        return 'Tirmidhi';
      case HadithSource.nasai:
        return 'Nasai';
      case HadithSource.ibnMajah:
        return 'Ibn Majah';
      case HadithSource.malik:
        return 'Muwatta Malik';
      case HadithSource.ahmad:
        return 'Musnad Ahmad';
    }
  }

  String _getAuthenticityLabel(AuthenticityGrade grade) {
    switch (grade) {
      case AuthenticityGrade.sahih:
        return 'Sahih';
      case AuthenticityGrade.hasan:
        return 'Hasan';
      case AuthenticityGrade.daif:
        return 'Daif';
      case AuthenticityGrade.mawdu:
        return 'Mawdu';
    }
  }

  Color _getAuthenticityColor(AuthenticityGrade grade) {
    switch (grade) {
      case AuthenticityGrade.sahih:
        return AppColors.success;
      case AuthenticityGrade.hasan:
        return AppColors.info;
      case AuthenticityGrade.daif:
        return AppColors.warning;
      case AuthenticityGrade.mawdu:
        return AppColors.error;
    }
  }
}
