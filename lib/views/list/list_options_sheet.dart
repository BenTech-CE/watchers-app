import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/cil.dart';
import 'package:iconify_flutter/icons/ion.dart';
import 'package:iconify_flutter/icons/majesticons.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/models/global/user_interaction_model.dart';
import 'package:watchers/core/models/lists/full_list_model.dart';
import 'package:watchers/core/models/lists/list_model.dart';
import 'package:watchers/core/models/reviews/review_model.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:watchers/core/providers/lists/lists_provider.dart';
import 'package:watchers/core/providers/user/user_provider.dart';
import 'package:watchers/core/theme/colors.dart';
import 'package:watchers/core/theme/texts.dart';
import 'package:watchers/views/search/search_page.dart';
import 'package:iconify_flutter/icons/oi.dart';
import 'package:watchers/widgets/star_rating.dart';

class ListOptionsSheet extends StatefulWidget {
  const ListOptionsSheet({
    super.key,
  });

  @override
  State<ListOptionsSheet> createState() => _ListOptionsSheetState();
}

class _ListOptionsSheetState extends State<ListOptionsSheet> {
  ListModel? list;
  ListAdditionalData? additionalData;

  void _navigateToEditList() {
    Navigator.pushReplacementNamed(
      context,
      '/list/edit',
      arguments: {
        'name': list?.name,
        'description': list?.description,
        'id': list?.id,
        'isPrivate': list?.isPrivate,
        'series':
            additionalData?.series
                .map(
                  (e) => SerieModel(
                    id: e.id.toString(),
                    popularity: 0,
                    originalName: '',
                    name: '',
                    overview: '',
                    posterUrl: e.posterUrl,
                    backgroundUrl: e.backgroundUrl,
                  ),
                )
                .toList()
      },
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final listsProvider = context.read<ListsProvider>();

      setState(() {
        list = listsProvider.currentListDetails!.listData;
        additionalData = listsProvider.currentListDetails!.additionalData;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(list?.name ?? '',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleLarge.copyWith(fontSize: 20)
              ),
            ),

            const SizedBox(height: 8),

            const LineSeparator(),

            _optionTile(
              icon: Majesticons.pencil_alt_line,
              title: "Editar Lista",
              onTap: () {
                _navigateToEditList();
              },
            ),

            const LineSeparator(),
            
            _optionTile(
              color: Colors.red,
              icon: Ion.android_delete,
              title: "Apagar Lista",
              onTap: () {
              },
            ),
              
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ===== OPTION TILE =====
  Widget _optionTile({
    required String icon,
    required String title,
    Widget? trailing,
    Color? color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,

      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      leading: Iconify(icon, color: color ?? tColorPrimary, size: 30),
      title: Text(title, style: AppTextStyles.bodyLarge.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color ?? tColorPrimary,
      )),
      trailing: trailing,
    );
  }
}
