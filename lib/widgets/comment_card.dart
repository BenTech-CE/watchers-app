import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ion.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/models/global/comment_model.dart';
import 'package:watchers/core/providers/user/user_provider.dart';
import 'package:watchers/core/theme/colors.dart';

class CommentCard extends StatefulWidget {
  final CommentModel comment;
  final VoidCallback onPressDelete;

  const CommentCard({super.key, required this.comment, required this.onPressDelete});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  String get formattedDate {
    final createdAt = DateTime.parse(widget.comment.createdAt).toLocal();
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(createdAt.year, createdAt.month, createdAt.day);
    final difference = today.difference(dateToCheck).inDays;

    DateFormat formatter;

    if (difference == 0) {
      formatter = DateFormat('HH:mm');
    } else if (difference == 1) {
      formatter = DateFormat("'Ontem às' HH:mm");
    } else {
      formatter = DateFormat('dd/MM/yyyy');
    }
    
    return formatter.format(createdAt);
  }

  @override
  Widget build(BuildContext context) {
    final String? userId = context.select<UserProvider, String?>((p) => p.currentUser?.id);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.pushNamed(context, '/profile', arguments: widget.comment.author.id);
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[700],
                  backgroundImage: widget.comment.author.avatarUrl != null
                      ? NetworkImage(widget.comment.author.avatarUrl!)
                      : null,
                  child: widget.comment.author.avatarUrl == null
                      ? const Icon(Icons.person, color: Colors.white, size: 16)
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.comment.author.fullName ?? "@${widget.comment.author.username}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: tColorGray,
                    fontSize: 12,
                  ),
                ),
                if (widget.comment.author.id == userId) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: widget.onPressDelete,
                    child: Iconify(
                      Mdi.trash_outline,
                      size: 20,
                      color: tColorGray,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.comment.content,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
