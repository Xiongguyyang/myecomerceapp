import 'package:flutter/material.dart';
import 'package:myecomerceapp/core/constants/app_colors.dart';
import 'package:myecomerceapp/domain/product/entities/category_entity.dart';

class CategoryChip extends StatelessWidget {
  final CategoryEntity category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.divider,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              category.name,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
