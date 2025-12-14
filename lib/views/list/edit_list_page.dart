import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/models/lists/full_list_model.dart';
import 'package:watchers/core/models/lists/list_model.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:watchers/core/providers/lists/lists_provider.dart';
import 'package:watchers/core/providers/user/user_provider.dart';
import 'package:watchers/core/theme/colors.dart';
import 'package:watchers/core/theme/texts.dart';
import 'package:watchers/widgets/button.dart';
import 'package:watchers/widgets/image_card.dart';
import 'package:watchers/widgets/list_popular_card.dart';
import 'package:watchers/widgets/unsaved_changes_dialog.dart';

class EditListPage extends StatefulWidget {
  const EditListPage({super.key});

  @override
  State<EditListPage> createState() => _EditListPageState();
}

class _EditListPageState extends State<EditListPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  String initialTitle = "";
  String initialDescription = "";
  List<SerieModel> initialSeries = [];
  bool initialIsPrivate = false;

  bool isPrivate = false;

  bool didChanges = false;

  String listId = "";

  void _createList() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("O título da lista não pode estar vazio.")));
      return;
    }

    final listsProvider = context.read<ListsProvider>();
    final userProvider = context.read<UserProvider>();
    
    if (listsProvider.listSeriesAdd.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Adicione ao menos uma série à lista.")));
      return;
    }

    final initialSeriesIds = initialSeries.map((s) => s.id).toSet();
    final removedSeriesIds = initialSeriesIds.difference(
      listsProvider.listSeriesAdd.map((s) => s.id).toSet(),
    );
    final addedSeriesIds = listsProvider.listSeriesAdd
        .map((s) => s.id)
        .toSet()
        .difference(initialSeriesIds);

    await listsProvider.editList(
      listId,
      _titleController.text.trim(),
      isPrivate,
      _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      addedSeriesIds.toList(),
      removedSeriesIds.toList(),
    );

    if (listsProvider.errorMessage != null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(listsProvider.errorMessage!)));
      }
      return;
    }

    final Set<ListAdditionalDataSeries> oldSeriesLADS = listsProvider.currentListDetails?.additionalData.series.toSet() ?? {};

    final addedSeriesLADS = oldSeriesLADS.where((lads) => addedSeriesIds.contains(lads.id.toString())).toSet().union(
      listsProvider.listSeriesAdd
        .where((s) => addedSeriesIds.contains(s.id) && !oldSeriesLADS.any((lads) => lads.id.toString() == s.id))
        .map((s) => ListAdditionalDataSeries(id: int.parse(s.id), posterUrl: s.posterUrl))
        .toSet()
    ).toSet();

    final removedSeriesLADS = oldSeriesLADS.where((lads) => removedSeriesIds.contains(lads.id.toString())).toSet();

    if (listsProvider.currentListDetails != null) {
      listsProvider.setNewDataForListDetails(
        _titleController.text.trim(), 
        isPrivate, 
        _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(), 
        addedSeriesLADS.toList(), 
        removedSeriesLADS.toList()
      );
    }
    
    await userProvider.getCurrentUser();

    listsProvider.clearListSeriesAdd();

    if (mounted) {
      Navigator.pop(context, true); // Retorna true indicando que criou lista
    }
  }

  void _showDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const UnsavedChangesDialog(),
    );

    if (result == true && mounted) {
      setState(() {
        didChanges = false;
      });

      Future.delayed(Duration.zero, () {
        Navigator.of(context).pop(); // Agora sai da tela de verdade
      });
    }
  }

  @override
  void initState(){
    super.initState();

    _titleController = TextEditingController();
    _descriptionController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final listsProvider = context.read<ListsProvider>();

      listsProvider.clearListSeriesAdd();

      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

      setState(() {
        _titleController.text = args['name'] ?? '';
        initialTitle = args['name'] ?? '';
        _descriptionController.text = args['description'] ?? '';
        initialDescription = args['description'] ?? '';
        listsProvider.setListSeriesAdd(args['series'] ?? []);
        initialSeries = List.from(args['series'] ?? []);
        listId = args['id'] ?? '';
        isPrivate = args['isPrivate'] ?? false;
        initialIsPrivate = args['isPrivate'] ?? false;
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final listsProvider = context.watch<ListsProvider>();

    return PopScope(
      canPop: !didChanges,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) {
          listsProvider.clearListSeriesAdd();
          return;
        }

        _showDialog();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: Text("Editar Lista", style: AppTextStyles.bodyLarge.copyWith(fontSize: 18, fontWeight: FontWeight.w600),),
        ),
        body: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 20,
              children: [
                TextField(
                  controller: _titleController,
                  onChanged: (value) {
                    if (value.trim() != initialTitle && !didChanges) {
                      setState(() {
                        didChanges = true;
                      });
                    } 
                  },
                  decoration: InputDecoration(
                    hintText: "Título da Lista",
                    fillColor: Color.fromARGB(196, 43, 43, 43),
                    filled: true,
                    isDense: true,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(
                  height: 120,
                  child: TextField(
                    controller: _descriptionController,
                    onChanged: (value) {
                      if (value.trim() != initialDescription && !didChanges) {
                        setState(() {
                          didChanges = true;
                        });
                      } 
                    },
                    maxLines: null,
                    minLines: null,
                    expands: true,
                    keyboardType: TextInputType.multiline,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      hintText: "Descrição da Lista (opcional)",
                      fillColor: Color.fromARGB(196, 43, 43, 43),
                      filled: true,
                      isDense: true,
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(196, 43, 43, 43),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Visibilidade da Lista", style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w500
                      ),),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (!isPrivate != initialIsPrivate && !didChanges) {
                            setState(() {
                              didChanges = true;
                            });
                          }

                          setState(() {
                            isPrivate = !isPrivate;
                          });
                        },
                        child: Row(
                          spacing: 6,
                          children: [
                            Text(isPrivate ? "Privada" : "Pública", style: AppTextStyles.bodyLarge.copyWith(
                              color: isPrivate ? colorTertiary : Colors.greenAccent,
                              fontWeight: FontWeight.w500
                            ),),
                            Iconify(isPrivate ? Mdi.eye_off : Mdi.eye, color: isPrivate ? colorTertiary : Colors.greenAccent,),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Séries", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
                        Material(
                          color: Color.fromARGB(89, 120, 120, 128),
                          shape: const CircleBorder(),
                          clipBehavior: Clip.hardEdge,
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/list/addmultiple',
                              );
                            },
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(Icons.add, color: colorTertiary, size: 24),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(196, 43, 43, 43),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Selector<ListsProvider, List<SerieModel>>(
                    selector: (context, provider) => provider.listSeriesAdd,
                    builder: (context, listSeriesAdd, child) {
                      if (initialSeries.length != listSeriesAdd.length && !didChanges) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() {
                            didChanges = true;
                          });
                        });
                      }

                      return listSeriesAdd.isEmpty
                        ? Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                              "Nenhuma série adicionada. Clique no + para adicionar.\n\nVocê também poderá adicionar séries à sua lista após criá-la.",
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: tColorSecondary,
                              ),
                            ),
                        )
                        : GridView.builder(
                            padding: EdgeInsets.all(12),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 2 / 3,
                            ),
                            itemCount: listSeriesAdd.length,
                            itemBuilder: (context, index) {
                              final series = listSeriesAdd[index];
                              return Stack(
                                children: [
                                  ImageCard(
                                    url: series.posterUrl,
                                    animation: null,
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: () {},
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Material(
                                      color: Colors.red,
                                      shape: const CircleBorder(),
                                      clipBehavior: Clip.hardEdge,
                                      child: InkWell(
                                        onTap: () {
                                          listsProvider.removeFromListSeriesAdd(series);
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(4.0),
                                          child: Icon(Icons.close, color: Colors.white, size: 16),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                    }
                  ),
                ),
              ],
            ),
          ),
        ),
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
              spacing: 20,
              children: [
                Expanded(
                  child: Button(
                    variant: ButtonVariant.secondary,
                    label: "Cancelar",
                    onPressed: () {
                      listsProvider.clearListSeriesAdd();
                      Navigator.pop(context);
                    },
                    disabled: listsProvider.isLoading || userProvider.isLoadingUser,
                  ),
                ),
                Expanded(
                  child: Button(
                    label: "Editar",
                    onPressed: _createList,
                    loading: listsProvider.isLoading || userProvider.isLoadingUser,
                    disabled: listsProvider.isLoading || userProvider.isLoadingUser,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}