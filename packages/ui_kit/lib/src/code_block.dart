import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'palette.dart';

class CodeBlock extends StatefulWidget {
  const CodeBlock({
    super.key,
    required this.code,
    this.label,
    this.dense = false,
    this.maxHeight = 460,
  });

  final String code;
  final String? label;
  final bool dense;
  final double maxHeight;

  @override
  State<CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<CodeBlock> {
  bool _copied = false;
  Timer? _timer;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (!mounted) return;
    setState(() => _copied = true);
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: widget.maxHeight),
      decoration: BoxDecoration(
        color: SiteColors.code,
        borderRadius: BorderRadius.circular(widget.dense ? 10 : 12),
        border: Border.all(color: SiteColors.line),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                widget.dense ? 12 : 16,
                widget.dense ? 12 : 16,
                widget.dense ? 40 : 48,
                widget.dense ? 12 : 16,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SelectableText(
                  widget.code,
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: widget.dense ? 12 : 12.5,
                    height: 1.7,
                    color: SiteColors.muted,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 6,
            top: 6,
            child: Tooltip(
              message: _copied ? 'Copied' : (widget.label ?? 'Copy code'),
              child: IconButton(
                onPressed: _copy,
                iconSize: 16,
                visualDensity: VisualDensity.compact,
                color: _copied ? SiteColors.success : SiteColors.subtle,
                icon: Icon(_copied ? Icons.check_rounded : Icons.copy_rounded),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
