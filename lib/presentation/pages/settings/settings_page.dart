import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../themes/app_colors.dart';
import '../../widgets/common/custom_button.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile'),
        ),
      ),
      body: ListView(
        children: [
          // Photo de profil
          if (user != null) ...[
            const SizedBox(height: 16),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primaryLight,
                backgroundImage:
                    user.profileImage != null && user.profileImage!.isNotEmpty
                        ? FileImage(File(user.profileImage!))
                        : null,
                child: user.profileImage == null || user.profileImage!.isEmpty
                    ? const Icon(Icons.person,
                        size: 60, color: AppColors.textLight)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Section Compte
          _buildSectionHeader(context, 'Compte'),
          _buildListTile(
            context,
            icon: Icons.person,
            title: 'Informations personnelles',
            subtitle: user?.name ?? 'Non défini',
            onTap: () {
              context.go('/edit-profile');
            },
          ),
          _buildListTile(
            context,
            icon: Icons.email,
            title: 'Adresse email',
            subtitle: user?.email ?? 'Non défini',
            onTap: () {
              context.go('/edit-profile');
            },
          ),
          _buildListTile(
            context,
            icon: Icons.lock,
            title: 'Mot de passe',
            subtitle: '••••••••',
            onTap: () {
              context.go('/change-password');
            },
          ),

          // Section Préférences
          _buildSectionHeader(context, 'Préférences'),
          _buildThemeSelector(context),

          const Divider(height: 32),

          // Section À propos
          _buildSectionHeader(context, 'À propos'),
          _buildListTile(
            context,
            icon: Icons.cloud,
            title: 'Stockage Cloud',
            subtitle: 'Données synchronisées avec Firebase',
            trailing: const Icon(Icons.check_circle, color: Colors.green),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vos données sont synchronisées avec Firebase'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
          _buildListTile(
            context,
            icon: Icons.info_outline,
            title: 'Version',
            subtitle: '1.0.0 (Firebase)',
            onTap: () {},
          ),

          const SizedBox(height: 32),

          // Bouton de déconnexion
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CustomButton(
              text: 'Se déconnecter',
              onPressed: () async {
                await authProvider.logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              backgroundColor: AppColors.error,
              icon: const Icon(Icons.logout),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing,
      onTap: onTap,
      enabled: onTap != null,
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    String themeModeToString(AppThemeMode mode) {
      switch (mode) {
        case AppThemeMode.light:
          return 'light';
        case AppThemeMode.dark:
          return 'dark';
        case AppThemeMode.system:
          return 'system';
      }
    }

    AppThemeMode stringToThemeMode(String value) {
      switch (value) {
        case 'light':
          return AppThemeMode.light;
        case 'dark':
          return AppThemeMode.dark;
        case 'system':
          return AppThemeMode.system;
        default:
          return AppThemeMode.light;
      }
    }

    return ListTile(
      leading: const Icon(Icons.palette, color: AppColors.primary),
      title: const Text('Thème'),
      subtitle: Text(themeProvider.themeModeText),
      trailing: DropdownButton<String>(
        value: themeModeToString(themeProvider.themeMode),
        items: const [
          DropdownMenuItem(value: 'light', child: Text('Clair')),
          DropdownMenuItem(value: 'dark', child: Text('Sombre')),
          DropdownMenuItem(value: 'system', child: Text('Système')),
        ],
        onChanged: (value) {
          if (value != null) {
            themeProvider.setThemeMode(stringToThemeMode(value));
          }
        },
      ),
    );
  }
}
