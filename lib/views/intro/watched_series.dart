import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:watchers/core/theme/colors.dart';
import 'package:watchers/core/theme/sizes.dart';
import 'package:watchers/core/theme/texts.dart';
import 'package:watchers/models/series.dart';
import 'package:watchers/widgets/input.dart';
import 'package:watchers/widgets/series_card.dart';

class WatchedSeries extends StatefulWidget {
  const WatchedSeries({super.key});

  @override
  State<WatchedSeries> createState() => _WatchedSeriesState();
}

class _WatchedSeriesState extends State<WatchedSeries> {
  
  // Para teste: Lista de séries
  final List<Series> _allSeries = [
    Series(id: "1", posterUrl: "https://media.themoviedb.org/t/p/w600_and_h900_bestv2/7h8ZHFmx73HnEagDI6KbWAw4ea3.jpg"),
    Series(id: "2", posterUrl: "https://media.themoviedb.org/t/p/w600_and_h900_bestv2/6gcHdboppvplmBWxvROc96NJnmm.jpg"),
    Series(id: "3", posterUrl: "https://media.themoviedb.org/t/p/w600_and_h900_bestv2/vz2oBcS23lZ35LmDC7mQqThrg8v.jpg"),
    Series(id: "4", posterUrl: "https://media.themoviedb.org/t/p/w600_and_h900_bestv2/m3Tzf6k537PnhOEwaSRNCSxedLS.jpg"),
    Series(id: "5", posterUrl: "https://media.themoviedb.org/t/p/w600_and_h900_bestv2/uOOtwVbSr4QDjAGIifLDwpb2Pdl.jpg"),
  ];

  // Set para armazenar o id das séries selecionadas
  final Set<String> _selectedSeriesIds = {};

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSeriesSelection (String seriesId){
    setState(() {
      if (_selectedSeriesIds.contains(seriesId)){
        _selectedSeriesIds.remove(seriesId);
      } else {
        _selectedSeriesIds.add(seriesId);
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.all(sizePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 138,
                height: 28,
                child: SvgPicture.asset("assets/logo/logowatchers.svg"),
              ),
              const SizedBox(height: sizeSpacing),
              Text("Quais séries você já assistiu?", style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w500, color: tColorPrimary),),
              Text("As selecionadas vão para o seu perfil!", style: AppTextStyles.labelLarge.copyWith(color: tColorSecondary),),
              const SizedBox(height: sizeSpacing),
              // TODO - Campo de Busca.
              GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: TextInputWidget(
                  label: "Procure séries que você já assistiu...",
                  controller: _searchController,
                  icon: Icons.search,
                  labelAsHint: true,
                  hintStyle: AppTextStyles.labelLarge.copyWith(color: tColorSecondary, fontSize: 14)
                ),
              ),
              const SizedBox(height: sizeSpacing),
              // Grade de séries
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 23,
                    mainAxisSpacing: 23,
                    childAspectRatio: 2 / 3,
                  ),
                  itemCount: _allSeries.length,
                  itemBuilder: (context, index){
                    final series = _allSeries[index];
                    final isSelected = _selectedSeriesIds.contains(series.id);

                    return SeriesCard(
                      imageUrl: series.posterUrl,
                      isSelected: isSelected,
                      onTap: () => _toggleSeriesSelection(series.id),
                    );
                  }
                ),
              )
            ],
          ),
        ),
      ),

      
    // Botões inferiores
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Row(
          children: [
             Expanded(
              child: OutlinedButton(
                onPressed: () { /* Lógica para pular */ },
                child: const Text('Pular'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.grey.shade800,
                  side: BorderSide(color: Colors.grey.shade800),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () { /* Lógica para continuar com as séries selecionadas */ },
                child: const Text('Continuar'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: tColorPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}