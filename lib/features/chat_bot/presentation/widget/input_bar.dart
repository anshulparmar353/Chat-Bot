import 'dart:io';

import 'package:chat_bot/features/chat_bot/presentation/bloc/bot_bloc.dart';
import 'package:chat_bot/features/chat_bot/presentation/bloc/bot_event.dart';
import 'package:chat_bot/features/chat_bot/presentation/bloc/bot_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class InputBar extends StatefulWidget {
  const InputBar({super.key});

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  final TextEditingController controller = TextEditingController();

  String? selectedImagePath;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFromGallery() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() {
        selectedImagePath = file.path;
      });
    }
  }

  Future<void> _pickFromCamera() async {
    final file = await _picker.pickImage(source: ImageSource.camera);

    if (file != null) {
      setState(() {
        selectedImagePath = file.path;
      });
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color.fromARGB(255, 45, 41, 41),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: const Text(
                  "Camera",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo, color: Colors.white),
                title: const Text(
                  "Gallery",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _send() {
    final text = controller.text.trim();

    if (text.isEmpty && selectedImagePath == null) return;

    context.read<BotBloc>().add(
      SendMessageEvent(message: text, imagePath: selectedImagePath),
    );

    controller.clear();

    setState(() {
      selectedImagePath = null;
    });

    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool hasInput =
        controller.text.trim().isNotEmpty || selectedImagePath != null;

    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        children: [
          if (selectedImagePath != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(selectedImagePath!),
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                        cacheWidth: 300,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedImagePath = null;
                          });
                        },
                        child: const CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.black,
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Row(
            children: [
              IconButton(
                onPressed: _showImageSourcePicker,
                icon: const Icon(Icons.add, color: Colors.white, size: 30),
              ),

              Expanded(
                child: TextField(
                  onChanged: (_) => setState(() {}),
                  minLines: 1,
                  maxLines: 4,
                  onSubmitted: (_) => _send(),
                  textInputAction: TextInputAction.send,
                  controller: controller,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: "Message",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[900],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              BlocBuilder<BotBloc, BotState>(
                builder: (context, state) {
                  final isBusy =
                      state is BotTypingState || state is BotStreamingState;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: (!hasInput || isBusy)
                          ? Colors.grey[800]
                          : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: (!hasInput || isBusy)
                          ? []
                          : [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: (!hasInput || isBusy) ? null : _send,
                        child: Center(
                          child: Icon(
                            Icons.arrow_upward,
                            size: 20,
                            color: (!hasInput || isBusy)
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
