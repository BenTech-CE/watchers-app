import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:provider/provider.dart';
import 'package:watchers/core/models/lists/list_model.dart';
import 'package:watchers/core/providers/lists/lists_provider.dart';
import 'package:watchers/core/providers/user/user_provider.dart';
import 'package:watchers/core/theme/colors.dart';
import 'package:watchers/core/theme/texts.dart';
import 'package:watchers/widgets/button.dart';
import 'package:watchers/widgets/list_popular_card.dart';

class AddSingleToListPage extends StatefulWidget {
  const AddSingleToListPage({super.key});

  @override
  State<AddSingleToListPage> createState() => _AddSingleToListPageState();
}

class _AddSingleToListPageState extends State<AddSingleToListPage> {
  String? serieId;
  Set<String> selectedListsIds = {};

  void _modifyList() async {
    if (serieId == null) return;

    final listsProvider = context.read<ListsProvider>();
    final userProvider = context.read<UserProvider>();

    for (final listId in selectedListsIds) {
      await listsProvider.addSeriesToList(listId, [int.parse(serieId!)]);
    }

    // Atualiza as listas do usuário
    userProvider.getCurrentUser();

    if (listsProvider.errorMessage != null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(listsProvider.errorMessage!)));
      }
      return;
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void initState(){
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments as String?;
      setState(() {
        serieId = args;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final listsProvider = context.watch<ListsProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text("Adicionar à Lista", style: AppTextStyles.bodyLarge.copyWith(fontSize: 18, fontWeight: FontWeight.w600),),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 20,
          children: [
            Button(label: "Criar Nova Lista", onPressed: () {}),
            Expanded(
              child: ListView.separated(
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(height: 20,);
                },
                itemCount: userProvider.currentUser!.lists.length,
                itemBuilder: (BuildContext context, int index) {
                  final list = userProvider.currentUser!.lists[index];
                  return _ListChooseCard(
                    list: list,
                    isSelected: selectedListsIds.contains(list.id),
                    onTap: () {
                      setState(() {
                        if (selectedListsIds.contains(list.id)) {
                          selectedListsIds.remove(list.id);
                        } else {
                          selectedListsIds.add(list.id);
                        }
                      });
                    },
                    animation: AlwaysStoppedAnimation(0),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 0,
            top: 0,
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
                    Navigator.pop(context);
                  },
                ),
              ),
              Expanded(
                child: Button(
                  label: "Concluir",
                  onPressed: _modifyList,
                  loading: listsProvider.isLoading,
                  disabled: listsProvider.isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListChooseCard extends StatelessWidget {
  final ListModel list;
  final Animation<double> animation;
  final VoidCallback onTap;
  final bool isSelected;

  const _ListChooseCard({super.key, required this.list, required this.animation, required this.onTap, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        spacing: 10,
        children: [
          SizedBox(
            width: 90,
            height: 80,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ...List.generate(
                  list.thumbnails.length > 4
                      ? 4
                      : list.thumbnails.length,
                  (i) {
                    final alignments = [
                      Alignment.topCenter,
                      Alignment.centerLeft,
                      Alignment.centerRight,
                      Alignment.bottomCenter,
                    ];
                    return ThumbNailAlign(
                      thumbnail: list.thumbnails[i],
                      alignment: alignments[i],
                      animation: animation,
                      onTap: onTap,
                      smallComponent: true,
                    );
                  },
                ),
                // se a lista tive menos de 4 thumbnails, preenche com containers vazios
                for (int i = list.thumbnails.length; i < 4; i++)
                  ThumbNailAlign(
                    thumbnail: '',
                    alignment: [
                      Alignment.topCenter,
                      Alignment.centerLeft,
                      Alignment.centerRight,
                      Alignment.bottomCenter,
                    ][i],
                    onTap: onTap,
                    animation: animation,
                    smallComponent: true,
                  ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  list.name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  spacing: 4,
                  children: [
                    Iconify(list.isPrivate ? Mdi.eye_off : Mdi.eye, size: 16, color: Colors.grey,),
                    Text(
                      list.isPrivate ? "Privada" : "Pública",
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Center(
            child: Container(
              width: 32,
              height: 32,
              decoration: const ShapeDecoration(
                shape: CircleBorder(),
                shadows: [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Material(
                color: isSelected ? const Color.fromARGB(82, 36, 86, 187) : Color.fromARGB(89, 120, 120, 128),
                shape: const CircleBorder(),
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  onTap: onTap,
                  child: Center(
                    child: Icon(isSelected ? Icons.check : Icons.add, color: colorTertiary, size: 24),
                  ),
                ),
              ),
            )
          ),
        ],
      ),
    );
  }
}