import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/carbon.dart';
import 'package:iconify_flutter/icons/fa.dart';
import 'package:iconify_flutter/icons/lucide.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:watchers/core/theme/colors.dart';
import 'package:watchers/views/search/search_page.dart';

class SeriesOptionsSheet extends StatefulWidget {
  final dynamic series;
  const SeriesOptionsSheet({super.key, required this.series});

  @override
  State<SeriesOptionsSheet> createState() => _SeriesOptionsSheetState();
}

String iconWatched =
    '<svg xmlns="http://www.w3.org/2000/svg" width="576" height="512" viewBox="0 0 576 512"><path fill="currentColor" d="M572.52 241.4C518.29 135.59 410.93 64 288 64S57.68 135.64 3.48 241.41a32.35 32.35 0 0 0 0 29.19C57.71 376.41 165.07 448 288 448s230.32-71.64 284.52-177.41a32.35 32.35 0 0 0 0-29.19M288 400a144 144 0 1 1 144-144a143.93 143.93 0 0 1-144 144m0-240a95.3 95.3 0 0 0-25.31 3.79a47.85 47.85 0 0 1-66.9 66.9A95.78 95.78 0 1 0 288 160"/></svg>';

class _SeriesOptionsSheetState extends State<SeriesOptionsSheet> {
  int rating = 0;
  bool watched = false;
  bool liked = false;
  bool watchlist = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Avalie",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(width: 6),
                Text(
                  "${widget.series.name ?? "Série"}",
                  style: const TextStyle(
                    fontSize: 24,
                    height: 1.2,
                    color: colorPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            LineSeparator(),

            const SizedBox(height: 16),

            // ===== ICON ROW =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _iconAction(
                    icon: iconWatched,
                    label: "Completa",
                    active: watched,
                    index: 0,
                    onTap: () => setState(() => watched = !watched),
                  ),
                  _iconAction(
                    icon:
                        '<svg xmlns="http://www.w3.org/2000/svg" width="8" height="8" viewBox="0 0 8 8"><path fill="currentColor" d="m4 8l2-2c4-4-1-6-2-3c-1-3-6-1-2 3"/></svg>',
                    label: "Gostei",
                    active: liked,
                    index: 1,
                    onTap: () => setState(() => liked = !liked),
                  ),
                  _iconAction(
                    icon: Carbon.time,
                    label: "Watchlist",
                    active: watchlist,
                    index: 2,
                    onTap: () => setState(() => watchlist = !watchlist),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ===== STAR RATING =====
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  final i = index + 1;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.0),
                    child: GestureDetector(
                      onTap: () => setState(() => rating = i),
                      child: Iconify(
                        '<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512"><path fill="currentColor" d="M394 480a16 16 0 0 1-9.39-3L256 383.76L127.39 477a16 16 0 0 1-24.55-18.08L153 310.35L23 221.2a16 16 0 0 1 9-29.2h160.38l48.4-148.95a16 16 0 0 1 30.44 0l48.4 149H480a16 16 0 0 1 9.05 29.2L359 310.35l50.13 148.53A16 16 0 0 1 394 480"/></svg>',
                        color: rating >= i
                            ? Color(0xFFFFCC00)
                            : Color(0xFF8D8D8D),
                        size: 50,
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              "Sua nota",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),

            const Divider(height: 32, color: Color(0xFF8D8D8D)),

            // ===== OPTIONS LIST =====
            _optionTile(
              icon: iconWatched,
              title: "Assistido",
              trailing: _tag("Temporada"),
              onTap: () {},
            ),

            _optionTile(
              icon: Carbon.time,
              title: "Watchlist",
              trailing: _tag("Temporada"),
              onTap: () {},
            ),

            const SizedBox(height: 8),

            _optionTile(
              icon:
                  '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"><path fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 21h8m.174-14.188a1 1 0 0 0-3.986-3.987L3.842 16.174a2 2 0 0 0-.5.83l-1.321 4.352a.5.5 0 0 0 .623.622l4.353-1.32a2 2 0 0 0 .83-.497z"/></svg>',
              title: "Escreva sua resenha",
              onTap: () {},
            ),

            _optionTile(
              icon: MaterialSymbols.list,
              title: "Adicione a uma lista",
              onTap: () {},
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ===== ICON BUTTON =====
  Widget _iconAction({
    required String icon,
    required String label,
    required bool active,
    required int index,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Iconify(
            icon,
            color: active
                ? index == 1
                      ? Color(0xFF9E0000)
                      : Color(0xFF7087FF).withAlpha(index == 0 ? 200 : 255)
                : Color(0xFF8D8D8D),
            size: 46,
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // ===== OPTION TILE =====
  Widget _optionTile({
    required String icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      
      contentPadding: EdgeInsets.zero,
      leading: Iconify(icon, color: Color(0xFF8D8D8D), size: 30),
      title: Text(title),
      trailing: trailing,
    );
  }

  // ===== TAG =====
  Widget _tag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFF8D8D8D)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 11)),
          SizedBox(width: 8, height: 0),
          const Iconify(
            '<svg width="12" height="7" viewBox="0 0 12 7" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M0.800049 0.799988L5.80005 5.79999L10.8 0.799988" stroke="#8D8D8D" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>',
            size: 8,
          ),
        ],
      ),
    );
  }
}
