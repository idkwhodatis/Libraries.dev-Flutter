import 'dart:async';

import 'package:border_beam/border_beam.dart';
import 'package:bot_avatars/bot_avatars.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:thinking_orbs/thinking_orbs.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:voice_glow/voice_glow.dart';

import '../data/backend.dart';
import '../data/repositories.dart';
import '../site/site_shell.dart';

class ContentPage extends StatelessWidget {
  const ContentPage({
    super.key,
    required this.path,
    required this.title,
    required this.subtitle,
    required this.sections,
  });

  final String path;
  final String title;
  final String subtitle;
  final List<(String, String)> sections;

  @override
  Widget build(BuildContext context) {
    return SiteShell(
      currentPath: path,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Padding(
          padding: const EdgeInsets.only(top: 52, bottom: 56),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 12),
              Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 36),
              for (final section in sections) ...[
                Text(
                  section.$1,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                      ),
                ),
                const SizedBox(height: 8),
                Text(section.$2, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 28),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class IntroductionPage extends StatelessWidget {
  const IntroductionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ContentPage(
      path: '/introduction',
      title: 'Introduction',
      subtitle:
          'Seven React libraries for the effects that make an interface feel alive, now being ported to Flutter.',
      sections: [
        (
          'Seven libraries',
          'Border beam, Thinking orbs, Gooey, Voice, Bot avatars, Liquid metal and Image generation. Magnetic UI is the model-backed eighth surface.',
        ),
        (
          'Install and use',
          'Each library installs from npm as a single component that wraps the element you already have. In this Flutter fork the same component vocabulary is being rebuilt with Impeller.',
        ),
        (
          'Preview, install, usage',
          'Library pages keep the Preview / Install tabs and platform tabs. The Thinking Orbs slice is fully interactive; the other effects are first-pass Flutter ports.',
        ),
        (
          'The Studio',
          'The Studio exposes every knob, local presets and a mock agent in this slice. The real account gate and agent endpoint are still behind the private backend.',
        ),
      ],
    );
  }
}

class AccessibilityPage extends StatelessWidget {
  const AccessibilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ContentPage(
      path: '/accessibility',
      title: 'Accessibility',
      subtitle:
          'The effects should stay decorative, readable and calm when a user asks for less motion.',
      sections: [
        (
          'Reduced motion',
          'Thinking Orbs freezes to a representative frame, and the animated first-pass effects stop when the platform reports reduced motion.',
        ),
        (
          'Semantics',
          'Thinking Orbs and Bot avatars expose image semantics with a per-state label. Effect layers are decorative and do not take pointer or keyboard input.',
        ),
        (
          'Keyboard',
          'Tabs, buttons, copy actions and the command palette are focusable. The current slice keeps the web focus ring treatment.',
        ),
        (
          'Contrast',
          'The dark-first palette matches the web tokens. A few muted web colors remain below AA for normal text and are tracked in the parity report.',
        ),
      ],
    );
  }
}

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ContentPage(
      path: '/terms',
      title: 'Terms & license',
      subtitle:
          'The short version: the libraries are MIT, Pro content is licensed, and the model files have their own license.',
      sections: [
        (
          'Libraries',
          'The component code is MIT and can be used in commercial projects. Each package keeps its own README and license.',
        ),
        (
          'Pro and Business',
          'Pro unlocks Studio customization, presets and future libraries. Plans are personal or team-scoped; cancellation stops renewal.',
        ),
        (
          'Models',
          'Magnet model files are licensed separately under the Libraries.dev Model License. They are free for development and non-commercial apps; shipping one in a commercial app needs Pro or Business.',
        ),
        (
          'Accounts',
          'The current Flutter slice uses local mock accounts only. It does not create a server account, charge a card or download a model.',
        ),
      ],
    );
  }
}

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ContentPage(
      path: '/privacy',
      title: 'Privacy',
      subtitle:
          'The Flutter slice is offline-first: local settings, local presets and no analytics calls.',
      sections: [
        (
          'What the web site collects',
          'The production site uses GoatCounter for page views, Stripe for billing, Resend for sign-in email and Cloudflare for hosting.',
        ),
        (
          'This slice',
          'No network requests leave the Flutter app for auth, presets, agent, checkout or downloads. Those paths are local mocks.',
        ),
        (
          'Local storage',
          'Account plan, local presets and dev settings stay in shared_preferences on the device.',
        ),
        (
          'Your choices',
          'Clearing local app data removes the mock account and presets. The production privacy policy remains the reference for the hosted site.',
        ),
      ],
    );
  }
}

class HowToUsePage extends StatelessWidget {
  const HowToUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    const steps = [
      (
        '1',
        'Copy the prompt',
        'Every library page has a Copy prompt button. One paste gives your agent the component, its parameter vocabulary and your current settings.',
      ),
      (
        '2',
        'Paste it into your agent',
        'Drop it into Claude Code, Cursor or Codex. The agent installs the package and wires it in against your theme.',
      ),
      (
        '3',
        'Make it yours',
        'Open the Studio with Pro, tune every knob, save a preset and copy the exact configuration.',
      ),
    ];
    return SiteShell(
      currentPath: '/how-to-use',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 52),
          Text(
            'From prompt to production in three steps.',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 14),
          Text(
            'Every library ships as a prompt. The component stays yours; the effect wraps it.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 34),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900 ? 3 : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: steps.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  childAspectRatio: columns == 3 ? 1.0 : 2.6,
                ),
                itemBuilder: (context, index) {
                  final step = steps[index];
                  return InsetSurface(
                    radius: 24,
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: SiteColors.accentStrong,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            step.$1,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          step.$2,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          step.$3,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 46),
          Text(
            'The libraries',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 14),
          for (final entry in const [
            ('border-beam', 'Border beam', '/beam'),
            ('thinking-orbs', 'Thinking orbs', '/orbs'),
            ('liquid-gooey', 'Gooey', '/gooey'),
            ('voice-glow', 'Voice', '/voice'),
            ('bot-avatars', 'Bot avatars', '/bots'),
            ('metal-fx', 'Liquid metal', '/metal'),
            ('img-fx', 'Image generation', '/image'),
          ])
            _LibraryRow(package: entry.$1, label: entry.$2, path: entry.$3),
        ],
      ),
    );
  }
}

class _LibraryRow extends StatelessWidget {
  const _LibraryRow({
    required this.package,
    required this.label,
    required this.path,
  });

  final String package;
  final String label;
  final String path;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 170,
            child: Text(
              package,
              style: const TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 12,
                color: SiteColors.subtle,
              ),
            ),
          ),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          PillButton(
            label: 'Open',
            compact: true,
            onTap: () => context.go(path),
          ),
        ],
      ),
    );
  }
}

class SkillPage extends StatelessWidget {
  const SkillPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SiteShell(
      currentPath: '/skill',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 52),
          Text(
            'Give your agent taste.',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: 560,
            child: Text(
              'The Libraries.dev skill teaches a coding agent the component vocabulary, the exact settings and the install path for every library.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 28),
          const CodeBlock(
            code:
                'npx libraries reveal\nnpx libraries review\nnpx libraries apply\n\n# Pro\nnpx libraries tune',
          ),
          const SizedBox(height: 34),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900 ? 2 : 1;
              final cards = [
                const _SkillCard(
                  title: 'Without the skill',
                  body:
                      'A generic prompt produces a spinner with no relation to your product, your type or your theme.',
                ),
                const _SkillCard(
                  title: 'With the skill',
                  body:
                      'The agent gets the effect, the parameter vocabulary and the preview settings in one paste.',
                ),
              ];
              if (columns == 1) {
                return Column(
                  children: [
                    for (final card in cards) ...[
                      card,
                      const SizedBox(height: 12),
                    ],
                  ],
                );
              }
              return Row(
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(child: cards[i]),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SkillCard extends StatelessWidget {
  const _SkillCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return InsetSurface(
      radius: 20,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class ProPage extends StatefulWidget {
  const ProPage({super.key});

  @override
  State<ProPage> createState() => _ProPageState();
}

class _ProPageState extends State<ProPage> {
  String _period = 'yearly';

  @override
  Widget build(BuildContext context) {
    final price = switch (_period) {
      'monthly' => ('\$12', 'per month'),
      'lifetime' => ('\$249', 'one time'),
      _ => ('\$96', 'per year'),
    };
    return SiteShell(
      currentPath: '/pro',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 52),
          Text('One plan. Every library.',
              style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 12),
          Text(
            'Pro unlocks the Studio, presets and every future library. The Flutter slice shows the local pricing surface.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          PillTabs<String>(
            options: const [
              PillOption('monthly', 'Monthly'),
              PillOption('yearly', 'Annual'),
              PillOption('lifetime', 'Lifetime'),
            ],
            value: _period,
            onChanged: (value) => setState(() => _period = value),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900 ? 2 : 1;
              final cards = [
                _PlanCard(
                  title: 'Pro',
                  price: price.$1,
                  period: price.$2,
                  features: const [
                    'Every library and future release',
                    'Studio customization and presets',
                    'Prompt exports and recipes',
                  ],
                  onTap: () => _checkout(context, AccountPlan.pro),
                ),
                _PlanCard(
                  title: 'Business',
                  price: '\$299',
                  period: 'per year',
                  features: const [
                    'Everything in Pro',
                    'Team seats and shared presets',
                    'Priority support',
                  ],
                  onTap: () => _checkout(context, AccountPlan.business),
                ),
              ];
              if (columns == 1) {
                return Column(
                  children: [
                    for (final card in cards) ...[
                      card,
                      const SizedBox(height: 12),
                    ],
                  ],
                );
              }
              return Row(
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(child: cards[i]),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          Text(
            'Prices are display-only. The local mock opens a demo account; the real backend redirects to Stripe Checkout.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Future<void> _checkout(BuildContext context, AccountPlan plan) async {
    if (backend is MockBackend) {
      _demoCheckout(context);
      return;
    }
    try {
      final result = await backend.commerce.checkout(plan);
      if (!context.mounted) return;
      final uri = Uri.parse(result.url);
      if (!uri.hasScheme) {
        context.go(result.url);
        return;
      }
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open checkout.')),
        );
      }
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checkout unavailable: $error')),
      );
    }
  }

  void _demoCheckout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SiteColors.panel,
        title: const Text('Demo checkout'),
        content: const Text(
          'This Flutter slice does not contact Stripe. The production flow redirects to Checkout from api.libraries.dev.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/account');
            },
            child: const Text('Open demo account'),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.period,
    required this.features,
    required this.onTap,
  });

  final String title;
  final String price;
  final String period;
  final List<String> features;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InsetSurface(
      radius: 24,
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Text(period, style: Theme.of(context).textTheme.bodySmall),
              ),
            ],
          ),
          const SizedBox(height: 20),
          for (final feature in features)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                children: [
                  const Icon(Icons.check_rounded,
                      size: 16, color: SiteColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          PillButton(label: 'Choose $title', primary: true, onTap: onTap),
        ],
      ),
    );
  }
}

class StudioMarketingPage extends StatelessWidget {
  const StudioMarketingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SiteShell(
      currentPath: '/studio',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 52),
          Text(
            'Every library, tuned to yours.',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 560,
            child: Text(
              'The Studio exposes every knob, saves presets and exports the exact configuration. This slice opens the orb bench with local data.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 26),
          PillButton(
            label: 'Open Studio',
            primary: true,
            onTap: () => context.go('/studio/app'),
          ),
          const SizedBox(height: 34),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900 ? 3 : 1;
              final cards = [
                const _StudioFeature(
                  title: 'Orb bench',
                  body: 'Nine states, three sizes, speed, ink and per-state knobs.',
                  child: ThinkingOrb(
                    state: OrbState.listening,
                    size: 64,
                    displaySize: 64,
                  ),
                ),
                _StudioFeature(
                  title: 'Beam presets',
                  body: 'Rotate, line and pulse families with exact settings.',
                  child: BorderBeam(
                    size: BorderBeamSize.md,
                    child: const SizedBox(width: 130, height: 64),
                  ),
                ),
                const _StudioFeature(
                  title: 'Local presets',
                  body: 'Saved in shared_preferences for this slice.',
                  child: Icon(Icons.tune_rounded, size: 36, color: SiteColors.muted),
                ),
              ];
              if (columns == 1) {
                return Column(
                  children: [
                    for (final card in cards) ...[
                      card,
                      const SizedBox(height: 12),
                    ],
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(child: cards[i]),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StudioFeature extends StatelessWidget {
  const _StudioFeature({
    required this.title,
    required this.body,
    required this.child,
  });

  final String title;
  final String body;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InsetSurface(
      radius: 20,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 96, child: Center(child: child)),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(body, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class ActivatePage extends StatefulWidget {
  const ActivatePage({
    super.key,
    this.deviceCode,
    this.inviteToken,
    this.signup,
  });

  final String? deviceCode;
  final String? inviteToken;
  final String? signup;

  @override
  State<ActivatePage> createState() => _ActivatePageState();
}

class _ActivatePageState extends State<ActivatePage> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  bool _sent = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Enter an email address.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (!_sent) {
        await backend.auth.requestCode(
          email,
          deviceCode: widget.deviceCode,
          inviteToken: widget.inviteToken,
          signup: widget.signup,
        );
        if (!mounted) return;
        setState(() => _sent = true);
      } else {
        final session = await backend.auth.verifyCode(
          email,
          _code.text.trim(),
        );
        if (!mounted) return;
        if (session == null) {
          setState(() => _error = 'That code did not create a session.');
        } else {
          context.go('/account');
        }
      }
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SiteShell(
      currentPath: '/activate',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: InsetSurface(
            radius: 24,
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Sign in',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  backend is MockBackend
                      ? 'Local mock sign-in. No email is sent and no server session is created.'
                      : 'Passwordless sign-in against api.libraries.dev.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 22),
                TextField(
                  controller: _email,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'you@example.com',
                  ),
                ),
                const SizedBox(height: 12),
                if (_sent)
                  TextField(
                    controller: _code,
                    decoration: const InputDecoration(labelText: 'One-time code'),
                  ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: SiteColors.danger,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                PillButton(
                  label: _busy
                      ? 'Please wait...'
                      : _sent
                          ? 'Verify and open account'
                          : 'Send code',
                  primary: true,
                  enabled: !_busy,
                  onTap: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SiteShell(
      currentPath: '/success',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            children: [
              const SizedBox(height: 100),
              const Icon(Icons.check_circle_rounded,
                  size: 64, color: SiteColors.success),
              const SizedBox(height: 20),
              Text(
                'You are all set.',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 12),
              Text(
                'This is the local demo confirmation. The production page resolves a Stripe session and emails a sign-in code.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 10,
                children: [
                  PillButton(
                    label: 'Open account',
                    primary: true,
                    onTap: () => context.go('/account'),
                  ),
                  PillButton(
                    label: 'Browse libraries',
                    onTap: () => context.go('/orbs'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VoicePhonePage extends StatefulWidget {
  const VoicePhonePage({super.key});

  @override
  State<VoicePhonePage> createState() => _VoicePhonePageState();
}

class _VoicePhonePageState extends State<VoicePhonePage> {
  double _level = 0.55;
  bool _paused = false;

  @override
  Widget build(BuildContext context) {
    return SiteShell(
      currentPath: '/voice-phone',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text('Voice phone', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 292,
              height: 600,
              child: VoiceBeam(
                type: VoiceBeamType.mobile,
                level: _level,
                paused: _paused,
                borderRadius: 52,
                child: const Center(
                  child: Text(
                    'Listening...',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: SiteColors.text,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 320,
              child: Column(
                children: [
                  Slider(
                    value: _level,
                    onChanged: (value) => setState(() => _level = value),
                  ),
                  PillButton(
                    label: _paused ? 'Play' : 'Pause',
                    onTap: () => setState(() => _paused = !_paused),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BotCarouselPage extends StatefulWidget {
  const BotCarouselPage({super.key});

  @override
  State<BotCarouselPage> createState() => _BotCarouselPageState();
}

class _BotCarouselPageState extends State<BotCarouselPage> {
  int _step = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 2600), (_) {
      if (mounted) setState(() => _step++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070707),
      body: Center(
        child: Wrap(
          spacing: 16,
          alignment: WrapAlignment.center,
          children: [
            for (var i = 0; i < 9; i++)
              BotAvatar(
                type: BotAvatarType.values[i % BotAvatarType.values.length],
                state: i == 4 ? BotAvatarState.working : BotAvatarState.idle,
                size: i == 4 ? 92 : 64,
              ),
          ],
        ),
      ),
    );
  }
}

class SkillDemoPage extends StatefulWidget {
  const SkillDemoPage({super.key});

  @override
  State<SkillDemoPage> createState() => _SkillDemoPageState();
}

class _SkillDemoPageState extends State<SkillDemoPage> {
  bool _generating = true;

  @override
  Widget build(BuildContext context) {
    return SiteShell(
      currentPath: '/skill-demo',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48),
          Text('Skill demo', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 10),
          Text(
            'A generic agent surface next to the Libraries.dev vocabulary.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 22),
          PillButton(
            label: _generating ? 'Reset' : 'Generate',
            icon: const Icon(Icons.auto_awesome, size: 15),
            onTap: () => setState(() => _generating = !_generating),
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900 ? 2 : 1;
              final cards = const [
                _DemoPanel(generic: true),
                _DemoPanel(generic: false),
              ];
              if (columns == 1) {
                return Column(
                  children: [
                    for (final card in cards) ...[
                      card,
                      const SizedBox(height: 12),
                    ],
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(child: cards[i]),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class SkillExamplePage extends StatelessWidget {
  const SkillExamplePage({super.key, this.generic = false});

  final bool generic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SiteColors.page,
      body: Center(
        child: SizedBox(
          width: 560,
          child: _DemoPanel(generic: generic),
        ),
      ),
    );
  }
}

class _DemoPanel extends StatelessWidget {
  const _DemoPanel({required this.generic});

  final bool generic;

  @override
  Widget build(BuildContext context) {
    if (generic) {
      return Container(
        height: 340,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: SiteColors.code,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: SiteColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Generic AI', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            const LinearProgressIndicator(minHeight: 2),
            const SizedBox(height: 20),
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFF1D1D1D),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: SiteColors.line),
              ),
              child: const Center(
                child: Text(
                  'Generating...',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: SiteColors.subtle,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return InsetSurface(
      radius: 18,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Libraries.dev', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 20),
          Row(
            children: [
              const ThinkingOrb(state: OrbState.working, size: 32),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Working with your vocabulary...',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: SiteColors.muted,
                  ),
                ),
              ),
              const BotAvatar(
                type: BotAvatarType.clover,
                state: BotAvatarState.working,
                size: 40,
              ),
            ],
          ),
          const SizedBox(height: 20),
          BorderBeam(
            size: BorderBeamSize.md,
            child: Container(
              width: double.infinity,
              height: 120,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF1D1D1D),
                borderRadius: BorderRadius.circular(14),
              ),
              child: VoiceBeam(
                type: VoiceBeamType.pill,
                level: 0.5,
                borderRadius: 14,
                child: const Text(
                  'Listening...',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: SiteColors.muted,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return SiteShell(
      currentPath: path,
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 100),
            Text('404', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 12),
            Text(
              'That page is not in this slice.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 18),
            PillButton(
              label: 'Back home',
              primary: true,
              onTap: () => context.go('/'),
            ),
          ],
        ),
      ),
    );
  }
}




