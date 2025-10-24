import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:watchers/core/models/lists/list_model.dart';
import 'package:watchers/core/theme/colors.dart';
import 'package:watchers/core/theme/sizes.dart';
import 'package:iconify_flutter/icons/mdi.dart';

class ListPopularCard extends StatefulWidget {
  final ListModel list;

  const ListPopularCard({super.key, required this.list});

  @override
  _ListPopularCardState createState() => _ListPopularCardState();
}

class _ListPopularCardState extends State<ListPopularCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final String? avatarUrl = widget.list.author.avatarUrl;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: sizePadding,
        children: [
          SizedBox(
            width: 137,
            height: 161,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ThumbNailAlign(
                  thumbnail: widget.list.thumbnails[0],
                  alignment: Alignment.topCenter,
                ),
                ThumbNailAlign(
                  thumbnail: widget.list.thumbnails[1],
                  alignment: Alignment.centerLeft,
                ),
                ThumbNailAlign(
                  thumbnail: widget.list.thumbnails[2],
                  alignment: Alignment.centerRight,
                ),
                ThumbNailAlign(
                  thumbnail: widget.list.thumbnails[3],
                  alignment: Alignment.bottomCenter,
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.list.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Container(height: 8),
                // USER
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.grey[700],
                            backgroundImage: avatarUrl != null
                                ? NetworkImage(avatarUrl)
                                : null,
                            child: avatarUrl == null
                                ? const Icon(
                                    Icons.person,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            widget.list.author.username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // DESCRIPTION
                if (widget.list.description != null) Container(height: 3),
                if (widget.list.description != null)
                  Text(
                    widget.list.description!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                // LIKES AND COMMENTS
                Container(height: 10),
                Row(
                  spacing: 8,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.favorite,
                          size: 16,
                          color: Color(0xFFCC4A4A),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.list.likeCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Iconify(
                          Mdi.comment_multiple,
                          size: 16,
                          color: Color(0xFF747474),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.list.commentCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ThumbNailAlign extends StatelessWidget {
  const ThumbNailAlign({
    super.key,
    required this.thumbnail,
    required this.alignment,
  });

  final AlignmentGeometry alignment;
  final String thumbnail;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: 64,
          height: 95,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: _buildImage(thumbnail),
        ),
      ),
    );
  }

  Widget _buildImage(String url) {
    if (url.isEmpty) {
      return Container(
        color: bColorPrimary,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.image_not_supported,
                color: Colors.grey,
                size: 32,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: bColorPrimary,
          child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: bColorPrimary,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
    );
  }
}
