import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class PinCodeInput extends StatefulWidget {
  const PinCodeInput({
    super.key,
    required this.controller,
    this.validator,
    this.length = 5,
  });

  final TextEditingController controller;
  final String? Function(String?)? validator;
  final int length;

  @override
  State<PinCodeInput> createState() => _PinCodeInputState();
}

class _PinCodeInputState extends State<PinCodeInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());

    final existing = widget.controller.text;
    for (var i = 0; i < widget.length && i < existing.length; i++) {
      _controllers[i].text = existing[i];
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _syncToParent() {
    widget.controller.text = _controllers.map((c) => c.text).join();
  }

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      _controllers[index].text = value.characters.last;
      _controllers[index].selection = TextSelection.collapsed(
        offset: _controllers[index].text.length,
      );
    }

    _syncToParent();

    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: widget.controller.text,
      validator: widget.validator,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(widget.length, (index) {
                return SizedBox(
                  width: 52,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: AppTextStyles.onboardingTitle(),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primaryBlue,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      _onChanged(index, value);
                      field.didChange(widget.controller.text);
                    },
                  ),
                );
              }),
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8, right: 4),
                child: Text(
                  field.errorText!,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
