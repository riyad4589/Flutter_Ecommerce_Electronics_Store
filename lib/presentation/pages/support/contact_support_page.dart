import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class ContactSupportPage extends StatefulWidget {
  const ContactSupportPage({super.key});

  @override
  State<ContactSupportPage> createState() => _ContactSupportPageState();
}

class _ContactSupportPageState extends State<ContactSupportPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedCategory = 'Commande';
  bool _isLoading = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitSupport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simuler l'envoi du message
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Votre message a été envoyé. Nous vous répondrons bientôt !'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacter le support'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.support_agent,
                        size: 80, color: Colors.blue),
                    const SizedBox(height: 24),
                    Text(
                      'Comment pouvons-nous vous aider ?',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Notre équipe est là pour vous assister. Décrivez votre problème ci-dessous.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Catégorie',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'Commande', child: Text('Commande')),
                        DropdownMenuItem(
                            value: 'Produit', child: Text('Produit')),
                        DropdownMenuItem(
                            value: 'Livraison', child: Text('Livraison')),
                        DropdownMenuItem(
                            value: 'Paiement', child: Text('Paiement')),
                        DropdownMenuItem(
                            value: 'Compte', child: Text('Compte')),
                        DropdownMenuItem(value: 'Autre', child: Text('Autre')),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedCategory = value!);
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _subjectController,
                      labelText: 'Sujet',
                      prefixIcon: Icons.subject,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un sujet';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _messageController,
                      labelText: 'Message',
                      prefixIcon: Icons.message,
                      maxLines: 6,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez décrire votre problème';
                        }
                        if (value.length < 10) {
                          return 'Le message doit contenir au moins 10 caractères';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Card(
                      color: Colors.blue.shade50,
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Nous répondons généralement sous 24-48 heures.',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Envoyer le message',
                      onPressed: _submitSupport,
                      icon: const Icon(Icons.send),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Autres moyens de contact',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.email, color: Colors.blue),
                      title: const Text('Email'),
                      subtitle: const Text('support@ecommerce.com'),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone, color: Colors.green),
                      title: const Text('Téléphone'),
                      subtitle: const Text('+33 1 23 45 67 89'),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.chat, color: Colors.orange),
                      title: const Text('Chat en direct'),
                      subtitle: const Text('Disponible de 9h à 18h'),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Chat bientôt disponible !'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
