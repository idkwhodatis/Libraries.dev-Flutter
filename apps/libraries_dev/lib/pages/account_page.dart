import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ui_kit/ui_kit.dart';

import '../data/backend.dart';
import '../data/repositories.dart';
import '../site/site_shell.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  AccountSession? _session;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _signOut() async {
    await backend.auth.signOut();
    await _load();
  }

  Future<void> _portal() async {
    if (backend is MockBackend) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The billing portal belongs to the real backend.'),
        ),
      );
      return;
    }
    try {
      final url = await backend.commerce.portal();
      final uri = Uri.parse(url);
      if (!uri.hasScheme) {
        if (mounted) context.go(url);
        return;
      }
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Billing unavailable: $error')),
      );
    }
  }

  Future<void> _load() async {
    final session = await backend.auth.me();
    if (!mounted) return;
    setState(() {
      _session = session;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    return SiteShell(
      currentPath: '/account',
      child: Padding(
        padding: const EdgeInsets.only(top: 56, bottom: 56),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Account', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 10),
              Text(
                backend is MockBackend
                    ? 'Local mock account for the Flutter slice. No network requests leave the app.'
                    : 'Connected to the real api.libraries.dev backend.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (session == null)
                _SignedOutCard(onSignIn: () => context.go('/activate'))
              else
                _AccountCard(
                  session: session,
                  planEditable: backend is MockBackend,
                  onPlan: (plan) {
                    final current = backend;
                    if (current is MockBackend) {
                      setState(() => current.auth.plan = plan);
                    }
                  },
                  onOpenStudio: () => context.go('/studio/app'),
                  onPortal: _portal,
                  onSignOut: _signOut,
                  onHome: () => context.go('/'),
                  onOrbs: () => context.go('/orbs'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignedOutCard extends StatelessWidget {
  const _SignedOutCard({required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return InsetSurface(
      radius: 24,
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sign in', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'A passwordless email code unlocks Pro and the Studio.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          PillButton(label: 'Sign in', primary: true, onTap: onSignIn),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.session,
    required this.planEditable,
    required this.onPlan,
    required this.onOpenStudio,
    required this.onPortal,
    required this.onSignOut,
    required this.onHome,
    required this.onOrbs,
  });

  final AccountSession session;
  final bool planEditable;
  final ValueChanged<AccountPlan> onPlan;
  final VoidCallback onOpenStudio;
  final VoidCallback onPortal;
  final VoidCallback onSignOut;
  final VoidCallback onHome;
  final VoidCallback onOrbs;

  @override
  Widget build(BuildContext context) {
    return InsetSurface(
      radius: 24,
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: SiteColors.accentStrong,
                child: Text(
                  session.email.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.email,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _planLabel(session.plan),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              PillButton(
                label: 'Open Studio',
                primary: true,
                onTap: onOpenStudio,
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Divider(color: SiteColors.line),
          const SizedBox(height: 22),
          const SectionLabel('Development plan'),
          const SizedBox(height: 10),
          if (planEditable)
            PillTabs<AccountPlan>(
              options: const [
                PillOption(AccountPlan.free, 'Free'),
                PillOption(AccountPlan.pro, 'Pro'),
                PillOption(AccountPlan.business, 'Business'),
              ],
              value: session.plan,
              onChanged: onPlan,
            )
          else
            Text(
              _planLabel(session.plan),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          const SizedBox(height: 18),
          Text(
            session.plan == AccountPlan.free
                ? 'Studio is visible in the local mock, but the real backend would redirect a free account.'
                : 'Studio access is unlocked for this session.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              PillButton(label: 'View Thinking Orbs', onTap: onOrbs),
              if (!planEditable)
                PillButton(label: 'Manage plan', onTap: onPortal),
              PillButton(label: 'Sign out', onTap: onSignOut),
              PillButton(label: 'Back home', onTap: onHome),
            ],
          ),
        ],
      ),
    );
  }

  String _planLabel(AccountPlan plan) {
    return switch (plan) {
      AccountPlan.free => 'Free account',
      AccountPlan.pro => 'Pro - lifetime',
      AccountPlan.business => 'Business',
    };
  }
}


