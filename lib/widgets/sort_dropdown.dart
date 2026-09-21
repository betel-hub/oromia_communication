import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class SortDropdown extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  const SortDropdown({
    super.key,
    this.initialValue = 'most_recent',
    required this.onChanged,
  });

  @override
  State<SortDropdown> createState() => _SortDropdownState();
}

class _SortDropdownState extends State<SortDropdown> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Very Much Read',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.darkGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderGray),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButton<String>(
                  value: _selected,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: const [
                    DropdownMenuItem(
                      value: 'most_recent',
                      child: Text('Most Recent'),
                    ),
                    DropdownMenuItem(
                      value: 'most_read',
                      child: Text('Most Read'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selected = value);
                      widget.onChanged(value);
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}