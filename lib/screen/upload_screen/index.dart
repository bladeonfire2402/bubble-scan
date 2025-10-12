import 'package:enhance/controller/omr_controller.dart';
import 'package:enhance/interface/index.dart';
import 'package:enhance/screen/result_screen/index.dart';
import 'package:image_picker/image_picker.dart';
import 'package:enhance/core/enum/index.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  Uint8List? raw;
  ProccessType process = ProccessType.unloaded;
  OMRResult result = OMRResult(picked: []);

  void _changeProcess(ProccessType newProcess) {
    setState(() {
      process = newProcess;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);

    if (img != null) {
      raw = await img.readAsBytes();
      _changeProcess(ProccessType.loaded);
      _changeProcess(ProccessType.processing);
      Future.delayed(Duration(seconds: 1), () {
        result = OmrController.handleGrade(path: img.path);
        if (result.process == ProccessType.successfull) {
          _changeProcess(ProccessType.successfull);
        }
        _changeProcess(ProccessType.successfull);
      });
    }
  }

  Widget _buildResultBtn() {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: process == ProccessType.successfull ? Colors.blue : Colors.grey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextButton(
        onPressed: process == ProccessType.successfull
            ? () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
              )
            : null,
        child: const Text("View Result", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildImgPicker() {
    return process == ProccessType.unloaded
        ? GestureDetector(
            onTap: _pickImage,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFF7F7FA),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 4,
                    spreadRadius: 3,
                    offset: Offset(0, 3), // changes position of shadow
                    color: const Color.fromARGB(
                      255,
                      208,
                      210,
                      211,
                    ).withValues(alpha: 0.5),
                  ),
                ],
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: const Column(
                spacing: 4,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upload, color: Colors.blue, size: 40),
                  Text("Upload your image"),
                ],
              ),
            ),
          )
        : Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.white.withOpacity(
                        0.4,
                      ), // Điều chỉnh opacity để tăng hoặc giảm độ sáng
                      BlendMode.screen, // Blend mode giúp làm sáng ảnh
                    ),
                    child: Image.memory(raw!, fit: BoxFit.cover),
                  ),
                ),
              ),
              if (process == ProccessType.processing)
                Positioned(
                  // Đặt vòng tròn vào giữa màn hình Stack
                  top:
                      MediaQuery.of(context).size.height / 2 -
                      100, // Căn giữa theo chiều dọc
                  left:
                      MediaQuery.of(context).size.width / 2 -
                      40, // Căn giữa theo chiều ngang
                  child: CircularProgressIndicator(color: Colors.blue),
                ),
              if (process == ProccessType.successfull)
                const Icon(Icons.check_circle, size: 40, color: Colors.blue),
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        spacing: 20,
        children: [
          Expanded(flex: 10, child: _buildImgPicker()),
          Expanded(
            child: SizedBox(width: double.infinity, child: _buildResultBtn()),
          ),
        ],
      ),
    );
  }
}
