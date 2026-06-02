import 'package:flutter/material.dart';

class UserSearchBar extends StatefulWidget {
  const UserSearchBar({super.key});

  @override
  State<UserSearchBar> createState() => _UserSearchBarState();
}

class _UserSearchBarState extends State<UserSearchBar> {
  @override
  Widget build(BuildContext context) {
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
