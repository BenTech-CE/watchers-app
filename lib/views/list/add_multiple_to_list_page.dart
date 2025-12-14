import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/providers/lists/lists_provider.dart';
import 'package:watchers/core/providers/series/series_provider.dart';
import 'package:watchers/core/providers/user/user_provider.dart';
import 'package:watchers/core/theme/colors.dart';
import 'package:watchers/core/theme/sizes.dart';
import 'package:watchers/core/theme/texts.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:watchers/widgets/button.dart';
import 'package:watchers/widgets/input.dart';
import 'package:watchers/widgets/series_card.dart';

class AddMultipleToListPage extends StatefulWidget {
  const AddMultipleToListPage({super.key});

  @override
  State<AddMultipleToListPage> createState() => _AddMultipleToListPageState();
}

class _AddMultipleToListPageState extends State<AddMultipleToListPage> {
  final List<SerieModel> _allSeries = [];
  final List<SerieModel> _searchResults = [];
  bool _isSearching = false;

  List<SerieModel> _backupSeries = [];

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  String? listId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final listId = ModalRoute.of(context)!.settings.arguments as String?;
      final ListsProvider listsProvider = context.read<ListsProvider>();

      setState(() {
        _backupSeries = List.from(listsProvider.listSeriesAdd);
        this.listId = listId;
      });

      _fetchSeriesTrending();
    });

    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();

      if (query.isEmpty) {
        setState(() {
          _isSearching = false;
          _searchResults.clear();
        });
      } else {
        _performSearch(query);
      }
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    final SeriesProvider seriesProvider = context.read<SeriesProvider>();

    try {
      final results = await seriesProvider.getSeriesSearch(query);

      if (mounted) {
        setState(() {
          _searchResults.clear();
          _searchResults.addAll(results);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erro ao pesquisar séries: $e")));
      }
    }
  }

  Future<void> _fetchSeriesTrending() async {
    final SeriesProvider seriesProvider = context.read<SeriesProvider>();

    if (seriesProvider.trendingSeries.isNotEmpty && mounted) {
      setState(() {
        _allSeries.addAll(_backupSeries);
        _allSeries.addAll(seriesProvider.trendingSeries.where(
          (series) => !_backupSeries.any((s) => s.id == series.id),
        ));
      });
    } else if (seriesProvider.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            seriesProvider.errorMessage ?? "Erro ao carregar séries.",
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _toggleSeriesSelection(SerieModel series) {
    final listsProvider = context.read<ListsProvider>();

    bool exists = listsProvider.listSeriesAdd.any(
      (seriesItem) => seriesItem.id == series.id,
    );
    
    if (exists) {
      listsProvider.removeFromListSeriesAdd(series);
    } else {
      listsProvider.addToListSeriesAdd(series);
    }
  }

  void _navigateToNext() {
    final listsProvider = context.read<ListsProvider>();

    listsProvider.setListSeriesAdd(_backupSeries);
    Navigator.pop(context);
  }

  void _sendWatchedSeries() async {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final ListsProvider listsProvider = context.watch<ListsProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text("Adicionar à Lista", style: AppTextStyles.bodyLarge.copyWith(fontSize: 18, fontWeight: FontWeight.w600),),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.all(sizePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Consumer<SeriesProvider>(
                  builder: (context, provider, child) {
                    return TextInputWidget(
                      label: "Procure por séries...",
                      controller: _searchController,
                      icon: provider.isLoadingSearch && _isSearching
                          ? Icons.hourglass_empty
                          : Icons.search,
                      labelAsHint: true,
                      hintStyle: AppTextStyles.labelLarge.copyWith(
                        color: tColorSecondary,
                        fontSize: 14,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: sizeSpacing),
              // Grade de séries
              Expanded(
                child: Consumer<SeriesProvider>(
                  builder: (context, provider, child) {
                    final List<SerieModel> seriesToShow = _isSearching
                        ? _searchResults
                        : _allSeries;

                    if ((provider.isLoadingSearch ||
                            provider.isLoadingTrending) &&
                        seriesToShow.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (seriesToShow.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isSearching ? Icons.search_off : Icons.tv_off,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _isSearching
                                  ? "Nenhuma série encontrada para '${_searchController.text}'"
                                  : "Nenhuma série encontrada",
                              style: AppTextStyles.labelLarge.copyWith(
                                color: tColorSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 23,
                            mainAxisSpacing: 23,
                            childAspectRatio: 2 / 3,
                          ),
                      itemCount: seriesToShow.length,
                      itemBuilder: (context, index) {
                        final series = seriesToShow[index];
                        bool exists = listsProvider.listSeriesAdd.any(
                          (seriesItem) => seriesItem.id == series.id,
                        );

                        return SeriesCard(
                          series: series,
                          isSelected: exists,
                          onTap: () => _toggleSeriesSelection(series),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // Botões inferiores
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 20,
            top: 20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              Expanded(
                child: Button(
                  variant: ButtonVariant.secondary,
                  label: "Cancelar",
                  onPressed: () {
                    _navigateToNext();
                  },
                ),
              ),
              Expanded(
                child: Button(
                  label: "Concluir",
                  onPressed: () {
                    _sendWatchedSeries();
                  },
                  disabled: listsProvider.isLoading,
                  loading: listsProvider.isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
