import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yap_zone/providers/user_provider.dart';

class UserSearchBar extends ConsumerWidget {
  const UserSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
      ),
      child: Row(
        children: [
          Icon(Icons.search),
          Expanded(
            child: TextField(
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
              onSubmitted: (value) {
                FocusScope.of(context).unfocus();
              },
              decoration: InputDecoration(
                hintText: 'Search some users...',
                fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
