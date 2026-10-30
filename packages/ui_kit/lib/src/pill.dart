import 'package:flutter/material.dart';

import 'palette.dart';

class PillOption<T> {
  const PillOption(this.value, this.label);

  final T value;
  final String label;
}

class PillTabs<T> extends StatelessWidget {
  const PillTabs({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.locked = const <String>[],
    this.compact = false,
  });

  final List<PillOption<T>> options;
  final T value;
  final ValueChanged<T> onChanged;
  final List<String> locked;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final option in options)
          PillButton(
            label: option.label,
            active: option.value == value,
            enabled: !locked.contains(option.label),
            compact: compact,
            onTap: () => onChanged(option.value),
          ),
        for (final label in locked)
          PillButton(
            label: label,
            active: false,
            enabled: false,
            compact: compact,
          ),
      ],
    );
  }
}

class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    this.icon,
    this.active = false,
    this.enabled = true,
    this.compact = false,
    this.onTap,
    this.primary = false,
  });

  final String label;
  final Widget? icon;
  final bool active;
  final bool enabled;
  final bool compact;
  final VoidCallback? onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final height = compact ? 28.0 : 32.0;
    final background = primary
        ? SiteColors.accentStrong
        : active
            ? const Color(0x14FFFFFF)
            : const Color(0x0AFFFFFF);
    final foreground = primary
        ? SiteColors.text
        : active
            ? SiteColors.text
            : SiteColors.muted;
    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: height,
      padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 13),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: active && !primary ? SiteColors.lineStrong : SiteColors.line,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 7),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: foreground,
                  fontSize: compact ? 12 : 13,
                ),
          ),
        ],
      ),
    );

    return Opacity(
      opacity: enabled ? 1 : 0.28,
      child: MouseRegion(
        cursor: enabled && onTap != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: enabled ? onTap : null,
          child: child,
        ),
      ),
    );
  }
}

class IconPill extends StatelessWidget {
  const IconPill({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.size = 32,
  });

  final Widget icon;
  final VoidCallback onTap;
  final String? tooltip;
  final double size;

  @override
  Widget build(BuildContext context) {
    final button = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0x0AFFFFFF),
            shape: BoxShape.circle,
            border: Border.all(color: SiteColors.line),
          ),
          child: icon,
        ),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}
