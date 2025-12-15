import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ion.dart';
import 'package:iconify_flutter/icons/lucide.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:watchers/core/mocks/icons.dart';
import 'package:watchers/core/models/auth/full_user_model.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:watchers/core/providers/auth/auth_provider.dart';
import 'package:watchers/core/providers/lists/lists_provider.dart';
import 'package:watchers/core/providers/user/user_provider.dart';
import 'package:watchers/core/theme/colors.dart';
import 'package:watchers/core/theme/texts.dart';
import 'package:watchers/core/validators/validators.dart';
import 'package:watchers/views/profile/profile_picture_dialog.dart';
import 'package:watchers/views/search/search_page.dart';
import 'package:watchers/widgets/card_skeleton.dart';
import 'package:watchers/widgets/image_card.dart';
import 'package:watchers/widgets/list_popular_card.dart';
import 'package:watchers/widgets/list_series.dart';
import 'package:watchers/widgets/review_card.dart';
import 'package:watchers/widgets/series_card.dart';
import 'package:watchers/widgets/stars_chart.dart';
import 'package:file_picker/file_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  FullUserModel? user;
  
  // Controllers
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  
  // FocusNodes
  final _usernameFocusNode = FocusNode();
  final _bioFocusNode = FocusNode();
  final _nameFocusNode = FocusNode();
  
  final ImagePicker picker = ImagePicker();
  XFile? _pickedImage;

  // Estados de edição
  bool _isEditingUsername = false;
  bool _isEditingBio = false;
  bool _isEditingName = false;

  void _pickImage() async {
    // Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _pickedImage = image;
    });

    if (image != null) {
      showDialog(context: context, builder: (context) {
        return ProfilePictureDialog(file: image,);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    
    _usernameController = TextEditingController();
    _bioController = TextEditingController();
    _nameController = TextEditingController();
    _emailController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserData();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _usernameFocusNode.dispose();
    _bioFocusNode.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _fetchUserData() async{
    final userProvider = context.read<UserProvider>();
    final authInfo = context.read<AuthProvider>();

    setState(() {
      user = userProvider.currentUser;
      _usernameController.text = user?.username ?? "";
      _bioController.text = user?.bio ?? "";
      _nameController.text = user?.fullName ?? "";
      _emailController.text = authInfo.user?.email ?? "";
    });

  }

  void _changeUsername() async {
    final userProvider = context.read<UserProvider>();

    final username = _usernameController.text.trim();

    final validationMessage = FormValidators.validateUsername(username);
    print(user?.username);
    if (validationMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationMessage),
        ),
      );

      setState(() => _isEditingUsername = true);
      _usernameFocusNode.requestFocus();

      return;
    } else if (username != user?.username) {
      await userProvider.updateUserFields({
        "username": username,
      });

      if (userProvider.errorMessage != null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(userProvider.errorMessage!)));

          setState(() => _isEditingUsername = true);
          _usernameFocusNode.requestFocus();
        }
        return;
      } else {
        setState(() {
          user?.username = username;
        });
      }
    }
  }

  void _changeName() async {
    final userProvider = context.read<UserProvider>();

    final name = _nameController.text.trim();

    if (name != user?.fullName) {
      await userProvider.updateUserFields({
        "full_name": name,
      });

      if (userProvider.errorMessage != null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(userProvider.errorMessage!)));

          setState(() => _isEditingName = true);
          _nameFocusNode.requestFocus();
        }
        return;
      } else {
        setState(() {
          user?.fullName = name;  
        });
      }
    }
  }

  void _changeBio() async {
    final userProvider = context.read<UserProvider>();

    final bio = _bioController.text.trim();

    if (bio != user?.bio) {
      await userProvider.updateUserFields({
        "bio": bio,
      });

      if (userProvider.errorMessage != null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(userProvider.errorMessage!)));

          setState(() => _isEditingBio = true);
          _bioFocusNode.requestFocus();
        }
        return;
      } else {
        setState(() {
          user?.bio = bio;  
        });        
      }
    }
  }

  void _changePrivateWatchlist(bool newValue) async {
    final userProvider = context.read<UserProvider>();

    if (newValue != user?.privateWatchlist) {
      setState(() {
        user?.privateWatchlist = newValue;
      });

      await userProvider.updateUserFields({
        "private_watchlist": newValue,
      });

      if (userProvider.errorMessage != null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(userProvider.errorMessage!)));

          setState(() {
            user?.privateWatchlist = !newValue;
          });
        }

        return;
      }
    }
  }

  // Largura fixa para o label, garantindo alinhamento dos campos
  static const double _labelWidth = 70;

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isEditing,
    required VoidCallback onEdit,
    required VoidCallback onSave,
    required VoidCallback onSubmitted,
    String? prefixText,
    String? hintText,
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: _labelWidth,
          child: Padding(
            padding: EdgeInsets.only(top: maxLines > 1 ? 8 : 0),
            child: Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            readOnly: !isEditing,
            style: AppTextStyles.bodyLarge,
            maxLines: maxLines,
            decoration: InputDecoration(
              border: isEditing 
                  ? const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    )
                  : InputBorder.none,
              enabledBorder: isEditing 
                  ? const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    )
                  : InputBorder.none,
              focusedBorder: isEditing 
                  ? const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1),
                    )
                  : InputBorder.none,
              isDense: true,
              prefixText: prefixText,
              contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              hintText: hintText,
              hintStyle: AppTextStyles.bodyLarge.copyWith(
                color: tColorSecondary,
              ),
            ),
            onSubmitted: (_) => onSubmitted(),
          ),
        ),
        const SizedBox(width: 12),
        Padding(
          padding: EdgeInsets.only(top: maxLines > 1 ? 4 : 0),
          child: _EditSaveButton(
            isEditing: isEditing,
            onEdit: onEdit,
            onSave: onSave,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authInfo = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text("Editar Perfil", style: AppTextStyles.bodyLarge.copyWith(fontSize: 18, fontWeight: FontWeight.w600),),
        actions: [
          TextButton(
            onPressed: () async {
              final authProvider = context.read<AuthProvider>();
              await authProvider.signOut();
              // A navegação é feita automaticamente pelo AuthWrapper
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.redAccent.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              // padding interno para alinhar bem o toque
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            // Usamos Row para controlar a ordem: Texto -> Espaço -> Ícone
            child: Row(
              mainAxisSize: MainAxisSize.min, // Importante para não esticar a Row
              children: const [
                Text(
                  "Sair",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                SizedBox(width: 8), // Espaço entre texto e ícone
                Iconify(Ion.log_out, size: 20, color: Colors.redAccent),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Center(
                child: Column(
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: Builder(builder: (context) {
                        /*if (_pickedImage != null) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.file(
                              File(_pickedImage!.path),
                              fit: BoxFit.cover,
                            ),
                          );
                        } else */if (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(
                              user!.avatarUrl!,
                              fit: BoxFit.cover,
                            ),
                          );
                        } else {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Container(
                              color: bColorPrimary,
                              child: Icon(Icons.person, size: 50, color: tColorSecondary),
                            ),
                          );
                        }
                      }),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        _pickImage();
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 6,
                        children: [
                          Text(
                            "Editar Foto",
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: tColorPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(Icons.photo_camera_outlined, size: 20, color: tColorPrimary),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildEditableField(
                      label: 'Usuário',
                      controller: _usernameController,
                      focusNode: _usernameFocusNode,
                      isEditing: _isEditingUsername,
                      prefixText: '@',
                      hintText: 'username',
                      onEdit: () {
                        setState(() => _isEditingUsername = true);
                        _usernameFocusNode.requestFocus();
                      },
                      onSave: () {
                        setState(() => _isEditingUsername = false);
                        _usernameFocusNode.unfocus();
                        
                        _changeUsername();
                      },
                      onSubmitted: () {
                        setState(() => _isEditingUsername = false);

                        _changeUsername();
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildEditableField(
                      label: 'Nome',
                      controller: _nameController,
                      focusNode: _nameFocusNode,
                      isEditing: _isEditingName,
                      hintText: 'Seu nome',
                      onEdit: () {
                        setState(() => _isEditingName = true);
                        _nameFocusNode.requestFocus();
                      },
                      onSave: () {
                        setState(() => _isEditingName = false);
                        _nameFocusNode.unfocus();
                        
                        _changeName();
                      },
                      onSubmitted: () {
                        setState(() => _isEditingName = false);

                        _changeName();
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildEditableField(
                      label: 'Bio',
                      controller: _bioController,
                      focusNode: _bioFocusNode,
                      isEditing: _isEditingBio,
                      hintText: 'Conte um pouco sobre você',
                      maxLines: 1,
                      onEdit: () {
                        setState(() => _isEditingBio = true);
                        _bioFocusNode.requestFocus();
                      },
                      onSave: () {
                        setState(() => _isEditingBio = false);
                        _bioFocusNode.unfocus();
                        
                        _changeBio();
                      },
                      onSubmitted: () {
                        setState(() => _isEditingBio = false);

                        _changeBio();
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: _labelWidth,
                          child: Padding(
                            padding: EdgeInsets.only(top: 0),
                            child: Text(
                              "E-mail",
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _emailController,
                            readOnly: true,
                            style: AppTextStyles.bodyLarge,
                            maxLines: 1,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                              hintText: "E-mail não informado",
                              hintStyle: AppTextStyles.bodyLarge.copyWith(
                                color: tColorSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            if (!userProvider.isLoadingUser)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Editar Favoritos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  _EditButton(onTap: () {
                    Navigator.pushNamed(context, "/onboarding/favorited", arguments: {
                      "favoritedSeries": user?.favorites.toSet() ?? <SerieModel>{},
                    });
                  })
                ],
              ),
            ),
            if (!userProvider.isLoadingUser)
            GridView.builder(
              shrinkWrap: true, 
              // 3. Importante: Desativa a rolagem do Grid (quem rola é o SingleChildScrollView)
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              gridDelegate: 
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 23,
                  mainAxisSpacing: 23,
                  childAspectRatio: 2 / 3,
                ),
              itemCount: 3,
              itemBuilder: (context, index) {
                SerieModel? series = (user?.favorites.length ?? 0) > index ? user?.favorites[index] : null;

                if (series != null) {
                  return SeriesCard(
                    series: series,
                    isSelected: false,
                    onTap: () {
                      Navigator.pushNamed(context, "/onboarding/favorited", arguments: {
                        "favoritedSeries": user?.favorites.toSet() ?? <SerieModel>{},
                      });
                    },
                  );
                } else {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, "/onboarding/favorited", arguments: {
                        "favoritedSeries": user?.favorites.toSet() ?? <SerieModel>{},
                      });
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        color: bColorPrimary,
                        child: Center(
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: ShapeDecoration(
                              color: Color(0x1e787880),
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
                            child: Icon(Icons.add, color: colorPrimary),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "Escolha suas séries favoritas para aparecer em destaque no seu perfil.",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: tColorSecondary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ocultar do Perfil',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Watchlist",
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      Switch(
                        value: user?.privateWatchlist ?? false,
                        onChanged: (value) {
                          _changePrivateWatchlist(value);
                        }
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onLongPress: () {
                        Clipboard.setData(ClipboardData(text: authInfo.accessToken ?? "https://www.themoviedb.org/"));
                      },
                      child: Image.asset("assets/logo/tmdb-4x.png", width: 70,)
                    ),
                    const SizedBox(height: 8),
                    Text("Este aplicativo utiliza a API do TMDB, mas não é endossado nem certificado pelo TMDB.", 
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: tColorGray,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: bottomPadding),
          ],
        ),
      )
    );
  }
}


class _EditButton extends StatelessWidget {
  final VoidCallback onTap;

  const _EditButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color.fromARGB(44, 255, 255, 255),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          child: Iconify(lucideEdit, size: 14, color: tColorPrimary),
        ),
      ),
    );
  }
}

class _EditSaveButton extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onEdit;
  final VoidCallback onSave;

  const _EditSaveButton({
    required this.isEditing,
    required this.onEdit,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLoading = context.select<UserProvider, bool>((p) => p.isLoadingChangeField);

    return Opacity(
      // 2. VISUAL: Reduz a opacidade para 0.5 se estiver carregando (parece desativado)
      opacity: isLoading ? 0.5 : 1.0,
      child: Material(
        color: isEditing 
            ? tColorPrimary.withOpacity(0.2)
            : const Color.fromARGB(44, 255, 255, 255),
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          // 3. LÓGICA: Se isLoading for true, passamos NULL.
          // Isso desativa o clique e o efeito visual de toque do InkWell.
          onTap: isLoading 
              ? null 
              : (isEditing ? onSave : onEdit),
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            child: Iconify(
              isLoading ? lucideEdit : isEditing ? Mdi.content_save : lucideEdit, 
              size: 14, 
              color: tColorPrimary
            ),
          ),
        ),
      ),
    );
  }
}