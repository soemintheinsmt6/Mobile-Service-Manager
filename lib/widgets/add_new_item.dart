import 'package:flutter/material.dart';
import 'package:mobile_service_manager/constants/constants.dart';
import '../constants/app_colors.dart';
import 'custom_text_field.dart';

class AddNewItem extends StatefulWidget {
  const AddNewItem({super.key, required this.name});

  final String name;

  @override
  State<AddNewItem> createState() => _AddNewItemState();
}

class _AddNewItemState extends State<AddNewItem> {
  final TextEditingController _controller = TextEditingController();

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
            Text('Add ${widget.name}', style: kLargeBoldTextStyle),
            SizedBox(
              width: 300,
              child: CustomTextField(
                title: widget.name,
                showTitle: false,
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
                  child: Text('Add'),
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
