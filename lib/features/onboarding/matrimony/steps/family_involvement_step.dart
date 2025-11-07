import 'package:flutter/material.dart';
import 'package:aroosi_flutter/l10n/app_localizations.dart';

class FamilyInvolvementStep extends StatefulWidget {
  final bool requiresFamilyApproval;
  final String? familyApprovalDetails;
  final Function(bool value, {String? details}) onInvolvementUpdated;
  final VoidCallback onNext;

  const FamilyInvolvementStep({
    super.key,
    required this.requiresFamilyApproval,
    this.familyApprovalDetails,
    required this.onInvolvementUpdated,
    required this.onNext,
  });

  @override
  State<FamilyInvolvementStep> createState() => _FamilyInvolvementStepState();
}

class _FamilyInvolvementStepState extends State<FamilyInvolvementStep> {
  late bool _requiresFamilyApproval;
  late TextEditingController _detailsController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _requiresFamilyApproval = widget.requiresFamilyApproval;
    _detailsController = TextEditingController(text: widget.familyApprovalDetails ?? '');
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  void _updateInvolvement() {
    final details = _requiresFamilyApproval ? _detailsController.text.trim() : null;
    widget.onInvolvementUpdated(_requiresFamilyApproval, familyApprovalDetails: details);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            Text(
              'Should your family be involved in the marriage process?',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Many cultures value family involvement in marriage decisions',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Family involvement options
            Expanded(
              child: Column(
                children: [
                  _buildFamilyInvolvementCard(
                    context,
                    'Yes, family approval is important',
                    'My family should be involved in the decision-making process',
                    true,
                    Icons.groups,
                    () {
                      setState(() {
                        _requiresFamilyApproval = true;
                      });
                      _updateInvolvement();
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildFamilyInvolvementCard(
                    context,
                    'No, I prefer to decide independently',
                    'I want to make my own marriage decisions',
                    false,
                    Icons.person,
                    () {
                      setState(() {
                        _requiresFamilyApproval = false;
                      });
                      _updateInvolvement();
                    },
                  ),
                  
                  const Spacer(),
                  
                  // Additional details section (only shown if family approval is required)
                  if (_requiresFamilyApproval) ...[
                    const SizedBox(height: 24),
                    
                    Text(
                      'Family Involvement Details',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Text(
                      'Tell us how your family should be involved in the process',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _detailsController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'e.g., "Parents should meet potential matches first", "Family elders should approve", "Regular family discussions about progress"',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceVariant.withAlpha(50),
                      ),
                      validator: (value) {
                        if (_requiresFamilyApproval && (value == null || value.trim().isEmpty)) {
                          return 'Please provide details about family involvement';
                        }
                        if (value != null && value.trim().length < 10) {
                          return 'Please provide more details (at least 10 characters)';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _updateInvolvement();
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Quick options for family involvement
                    _buildQuickOptions(),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Next button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isValid() ? onNext : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyInvolvementCard(
    BuildContext context,
    String title,
    String description,
    bool isApprovalRequired,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final isSelected = _requiresFamilyApproval == isApprovalRequired;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withAlpha(50),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
            color: isSelected
                ? theme.colorScheme.primary.withAlpha(20)
                : theme.colorScheme.surface,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withAlpha(30),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Radio button with icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                    width: 2,
                  ),
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                ),
                child: isSelected
                    ? Icon(
                        icon,
                        size: 20,
                        color: theme.colorScheme.onPrimary,
                      )
                    : Icon(
                        icon,
                        size: 20,
                        color: theme.colorScheme.outline,
                      ),
              ),
              
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickOptions() {
    final theme = Theme.of(context);
    
    final options = [
      'Parents should meet potential matches first',
      'Family elders should approve the match',
      'Regular family discussions about progress',
      'Family should be involved in wedding planning',
      'Cultural traditions must be followed',
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick options (tap to add):',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            return ActionChip(
              label: Text(
                option,
                style: theme.textTheme.bodySmall,
              ),
              onPressed: () {
                final currentText = _detailsController.text;
                final newText = currentText.isEmpty 
                    ? option 
                    : '$currentText; $option';
                _detailsController.text = newText;
                _updateInvolvement();
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  bool _isValid() {
    if (!_requiresFamilyApproval) return true;
    
    return _formKey.currentState?.validate() == true &&
           _detailsController.text.trim().isNotEmpty;
  }
}
