import 'dart:io';

import 'package:chat_bot/features/chat_bot/presentation/bloc/bot_bloc.dart';
import 'package:chat_bot/features/chat_bot/presentation/bloc/bot_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class InputBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String text, List<String> images) onSend;

  const InputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSend,
  });

  @override
  State<InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<InputBar> {
  final ScrollController scrollController = ScrollController();

  List<String> selectedImages = [];

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFromGallery() async {
    final galfiles = await _picker.pickMultiImage();

    if (galfiles.isEmpty) return;

    final remaining = 5 - selectedImages.length;

    if (remaining <= 0) {
      _showLimitSnack();
      return;
    }

    if (galfiles.length > remaining) {
      _showLimitSnack();
    }

    setState(() {
      selectedImages.addAll(galfiles.take(remaining).map((e) => e.path));
    });

    _scrollToEnd();
  }

  Future<void> _pickFromCamera() async {
    if (selectedImages.length >= 5) {
      _showLimitSnack();
      return;
    }

    final camfiles = await _picker.pickImage(source: ImageSource.camera);

    if (camfiles != null) {
      setState(() {
        selectedImages.add(camfiles.path);
      });

      _scrollToEnd();
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
    final text = widget.controller.text.trim();

    if (text.isEmpty && selectedImages.isEmpty) return;

    widget.onSend(text, List.from(selectedImages));

    widget.controller.clear();

    setState(() {
      selectedImages.clear();
    });

    FocusScope.of(context).unfocus();
  }

  void _showLimitSnack() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text("Max 5 images allowed")));
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasInput =
        widget.controller.text.trim().isNotEmpty || selectedImages.isNotEmpty;

    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        children: [
          if (selectedImages.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "${selectedImages.length}/5 images",
                style: const TextStyle(color: Colors.grey),
              ),
            ),

          if (selectedImages.isNotEmpty)
            SizedBox(
              height: 100,
              child: ListView.builder(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: selectedImages.length,
                itemBuilder: (context, index) {
                  final path = selectedImages[index];

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(path),
                            width: 85,
                            height: 85,
                            fit: BoxFit.cover,
                          ),
                        ),

                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedImages.removeAt(index);
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
                  );
                },
              ),
            ),

          Row(
            children: [
              IconButton(
                onPressed: selectedImages.length >= 5
                    ? null
                    : _showImageSourcePicker,
                icon: const Icon(Icons.add, color: Colors.white, size: 30),
              ),

              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  onChanged: (_) => setState(() {}),
                  minLines: 1,
                  maxLines: 4,
                  onSubmitted: (_) => _send(),
                  textInputAction: TextInputAction.send,
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
                  final isBusy = state.isTyping;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: (!hasInput || isBusy)
                          ? Colors.grey[800]
                          : Colors.white,
                      shape: BoxShape.circle,
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
