import 'package:flutter/material.dart';
import 'package:mobile_service_manager/presentation/widgets/text_fields/custom_text_field.dart';
import '../../core/constants/app_colors.dart';

class UpdateItem extends StatefulWidget {
  const UpdateItem({super.key, required this.name});

  final String name;

  @override
  State<UpdateItem> createState() => _UpdateItemState();
}

class _UpdateItemState extends State<UpdateItem> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    _controller.text = widget.name;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 300,
              child: CustomTextField(
                title: widget.name,
                showTitle: false,
                showHint: false,
                textInputType: TextInputType.text,
                controller: _controller,
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context, _controller.text);
                },
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Update'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryButton,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
