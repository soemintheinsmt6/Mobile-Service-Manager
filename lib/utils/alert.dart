import 'package:flutter/material.dart';
import 'package:mobile_service_manager/constants/app_colors.dart';
import 'package:mobile_service_manager/constants/constants.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

void showErrorMessage(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) {
      return Positioned(
        top: 50,
        right: 0,
        child: _SlideInMessage(
          message: message,
          onDismissed: () => overlayEntry.remove(),
        ),
      );
    },
  );

  overlay.insert(overlayEntry);
}

class _SlideInMessage extends StatefulWidget {
  final String message;
  final VoidCallback onDismissed;

  const _SlideInMessage({
    required this.message,
    required this.onDismissed,
  });

  @override
  State<_SlideInMessage> createState() => _SlideInMessageState();
}

class _SlideInMessageState extends State<_SlideInMessage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () {
      _controller.reverse().then((_) => widget.onDismissed());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Material(
        elevation: 5,
        color: Colors.red.shade400,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Text(
                widget.message,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<dynamic> showDeleteAlert(BuildContext context) async {
  final alertStyle = AlertStyle(
    isCloseButton: false,
    titleStyle: kBodyTextStyle.copyWith(fontWeight: FontWeight.w600),
    descStyle: kDefaultTextStyle,
  );

  final result = await Alert(
    context: context,
    style: alertStyle,
    title: 'Delete!',
    desc: 'Are you sure want to delete?',
    buttons: [
      DialogButton(
        color: AppColors.primaryButton,
        onPressed: () => Navigator.pop(context),
        child: Text('Cancel',
            style: kDefaultTextStyle.copyWith(color: Colors.white)),
      ),
      DialogButton(
        color: AppColors.dangerButton,
        onPressed: () {
          Navigator.pop(context, true);
        },
        child: Text('Delete',
            style: kDefaultTextStyle.copyWith(color: Colors.white)),
      ),
    ],
  ).show();

  return result;
}
