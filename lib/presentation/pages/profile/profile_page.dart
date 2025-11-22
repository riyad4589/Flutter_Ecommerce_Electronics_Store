import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../themes/app_colors.dart';
import '../../widgets/common/custom_button.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
      ),
      body: user == null
          ? const Center(child: Text("Vous n'êtes pas connecté."))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.primaryLight,
                    backgroundImage: user.profileImage != null &&
                            user.profileImage!.isNotEmpty
                        ? FileImage(File(user.profileImage!))
                        : null,
                    child:
                        user.profileImage == null || user.profileImage!.isEmpty
                            ? const Icon(Icons.person,
                                size: 80, color: AppColors.textLight)
                            : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.email,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                  const Divider(height: 40),
                  ListTile(
                    leading: const Icon(Icons.shopping_bag_outlined),
                    title: const Text('Mes Commandes'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      context.goNamed(AppRoute.orders.name);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.favorite_outline),
                    title: const Text('Mes Favoris'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      context.go('/favorites');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('Paramètres'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      context.go('/settings');
                    },
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Se déconnecter',
                    onPressed: () async {
                      await authProvider.logout();
                      if (context.mounted) {
                        context.goNamed(AppRoute.login.name);
                      }
                    },
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.textLight,
                    icon: const Icon(Icons.logout),
                  ),
                ],
              ),
            ),
    );
  }
}
