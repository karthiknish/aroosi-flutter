import 'package:flutter/material.dart';
import 'package:aroosi_flutter/features/onboarding/matrimony/constants.dart';
import 'package:aroosi_flutter/features/onboarding/matrimony/models.dart';
import 'package:aroosi_flutter/theme/theme_helpers.dart';

class FamilyValuesStep extends StatelessWidget {
  final List<String> selectedFamilyValueIds;
  final Function(List<String>) onFamilyValuesSelected;
  final VoidCallback onNext;

  const FamilyValuesStep({
    super.key,
    required this.selectedFamilyValueIds,
    required this.onFamilyValuesSelected,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ThemeHelpers.getMaterialTheme(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          
          Text(
            'What family values are important to you?',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Select all that apply - family values are fundamental in matrimony',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Selected count indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${selectedFamilyValueIds.length} selected',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Family values options
          Expanded(
            child: ListView.builder(
              itemCount: FamilyValueOptions.options.length,
              itemBuilder: (context, index) {
                final familyValue = FamilyValueOptions.options[index];
                final isSelected = selectedFamilyValueIds.contains(familyValue.id);
                
                return _buildFamilyValueCard(
                  context,
                  familyValue,
                  isSelected,
                  () {
                    final updatedSelection = List<String>.from(selectedFamilyValueIds);
                    if (isSelected) {
                      updatedSelection.remove(familyValue.id);
                    } else {
                      updatedSelection.add(familyValue.id);
                    }
                    onFamilyValuesSelected(updatedSelection);
                  },
                );
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Next button
          if (selectedFamilyValueIds.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onNext,
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
          
          const SizedBox(height: 16),
          
          // Hint text
          Text(
            'Select at least one family value to continue',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyValueCard(
    BuildContext context,
    FamilyValue familyValue,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withAlpha(50),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
              color: isSelected
                  ? theme.colorScheme.primary.withAlpha(20)
                  : theme.colorScheme.surface,
            ),
            child: Row(
              children: [
                // Checkbox
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
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
                          Icons.check,
                          size: 18,
                          color: theme.colorScheme.onPrimary,
                        )
                      : null,
                ),
                
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        familyValue.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        familyValue.description,
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
      ),
    );
  }
}
