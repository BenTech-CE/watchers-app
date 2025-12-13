import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:watchers/core/models/lists/list_model.dart';
import 'package:watchers/core/theme/colors.dart';
import 'package:watchers/core/theme/sizes.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:watchers/widgets/image_card.dart';

class ListPopularCard extends StatefulWidget {
  final ListModel list;
  final bool? smallComponent;

  const ListPopularCard({super.key, required this.list, this.smallComponent});

  @override
  _ListPopularCardState createState() => _ListPopularCardState();
}

class _ListPopularCardState extends State<ListPopularCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? avatarUrl = widget.list.author.avatarUrl;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.pushNamed(
        context,
        '/list/detail',
        arguments: widget.list,
      ),
      child: widget.smallComponent != null
          ? Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 4,
              children: [seriesthubmnails(_animation), content(avatarUrl)],
            )
          : Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 12,
              children: [seriesthubmnails(_animation), content(avatarUrl)],
            ),
    );
  }

  SizedBox seriesthubmnails(Animation<double>? animation) {
    bool isSmallComponent =
        widget.smallComponent != null && widget.smallComponent != false;
    return SizedBox(
      width: isSmallComponent ? 90 : 137,
      height: isSmallComponent ? 80 : 161,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ...List.generate(
            widget.list.thumbnails.length > 4
                ? 4
                : widget.list.thumbnails.length,
            (i) {
              final alignments = [
                Alignment.topCenter,
                Alignment.centerLeft,
                Alignment.centerRight,
                Alignment.bottomCenter,
              ];
              return ThumbNailAlign(
                thumbnail: widget.list.thumbnails[i],
                alignment: alignments[i],
                animation: animation,
                list: widget.list,
                smallComponent: isSmallComponent,
              );
            },
          ),
          // se a lista tive menos de 4 thumbnails, preenche com containers vazios
          for (int i = widget.list.thumbnails.length; i < 4; i++)
            ThumbNailAlign(
              thumbnail: '',
              alignment: [
                Alignment.topCenter,
                Alignment.centerLeft,
                Alignment.centerRight,
                Alignment.bottomCenter,
              ][i],
              list: widget.list,
              animation: animation,
              smallComponent: isSmallComponent,
            ),
        ],
      ),
    );
  }

  Expanded content(String? avatarUrl) {
    bool isSmallComponent =
        widget.smallComponent != null && widget.smallComponent != false;
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: isSmallComponent ? 8 : 16,
        children: [
          SizedBox(
            width: isSmallComponent ? 100 : double.maxFinite,
            child: Text(
              widget.list.name,
              style: TextStyle(
                fontSize: isSmallComponent ? 12 : 16,
                fontWeight: isSmallComponent
                    ? FontWeight.w500
                    : FontWeight.bold,
                overflow: TextOverflow.clip,
                color: Colors.white,
              ),
            ),
          ),
          Column(
            spacing: 8,
            children: [
              // USER
              Row(
                children: [
                  SizedBox(
                    width: isSmallComponent ? 18 : 24,
                    height: isSmallComponent ? 18 : 24,
                    child: CircleAvatar(
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
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      overflow: TextOverflow.ellipsis,
                      isSmallComponent
                          ? "${widget.list.likeCount.toString()} curtidas"
                          : (widget.list.author.fullName != null &&
                                widget.list.author.fullName!.isNotEmpty)
                          ? widget.list.author.fullName!
                          : "@${widget.list.author.username}",

                      style: TextStyle(
                        color: isSmallComponent
                            ? Color(0xFF828282)
                            : Colors.white,
                        fontSize: isSmallComponent ? 10 : 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              // DESCRIPTION
              if (!isSmallComponent && widget.list.description != null)
                Text(
                  widget.list.description!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
            ],
          ),
          // LIKES AND COMMENTS
          if (!isSmallComponent)
            Row(
              spacing: 8,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.favorite,
                      size: 16,
                      color: Color(0xFF747474),
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
    );
  }
}

class ThumbNailAlign extends StatelessWidget {
  const ThumbNailAlign({
    super.key,
    required this.thumbnail,
    required this.alignment,
    required this.list,
    this.animation,
    this.smallComponent,
  });

  final AlignmentGeometry alignment;
  final String thumbnail;
  final ListModel list;
  final Animation<double>? animation;
  final bool? smallComponent;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: smallComponent != null && smallComponent != false ? 36 : 64,
          height: smallComponent != null && smallComponent != false ? 53 : 95,
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
          child: ImageCard(url: thumbnail, onTap: () => Navigator.pushNamed(
            context,
            '/list/detail',
            arguments: list,
          ), animation: animation),
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
