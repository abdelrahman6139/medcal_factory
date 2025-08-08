import 'package:flutter/material.dart';
import '../constants/colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // القيم المبدئية (بدّلها بقيمك/من API لاحقًا)
  String _name = "Azza Mohamed";
  String _email = "azza@example.com";
  String _age = "28";
  String _location = "Cairo, Egypt";

  // الكونترولرز
  late final TextEditingController _nameC;
  late final TextEditingController _emailC;
  late final TextEditingController _ageC;
  late final TextEditingController _locationC;

  // حالات التعديل لكل صف
  bool _editName = false;
  bool _editEmail = false;
  bool _editAge = false;
  bool _editLocation = false;

  @override
  void initState() {
    super.initState();
    _nameC = TextEditingController(text: _name);
    _emailC = TextEditingController(text: _email);
    _ageC = TextEditingController(text: _age);
    _locationC = TextEditingController(text: _location);
  }

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _ageC.dispose();
    _locationC.dispose();
    super.dispose();
  }

  void _toastSaved([String field = "Profile"]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$field updated"),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  // صف قابل للتعديل
  Widget _editableRow({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required VoidCallback onStartEdit,
    required VoidCallback onSave,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String value)? validate,
  }) {
    final border = OutlineInputBorder(borderRadius: BorderRadius.circular(12));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
      ),
      child: Row(
        children: [
          // Label
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.subtitle,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Value / TextField
          Expanded(
            child:
                isEditing
                    ? TextField(
                      controller: controller,
                      keyboardType: keyboardType,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: border,
                        focusedBorder: border.copyWith(
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    )
                    : Text(
                      controller.text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
          ),

          const SizedBox(width: 8),

          // Edit / Save icon
          IconButton(
            tooltip: isEditing ? "Save" : "Edit",
            onPressed: () {
              if (!isEditing) {
                onStartEdit();
              } else {
                // Validate (لو محتاجين)
                final v = controller.text.trim();
                if (validate != null) {
                  final err = validate(v);
                  if (err != null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(err)));
                    return;
                  }
                }
                onSave();
                _toastSaved(label);
              }
            },
            icon: Icon(isEditing ? Icons.check_circle : Icons.edit),
            color: isEditing ? AppColors.success : AppColors.primary,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: AppColors.oceanDark,
        foregroundColor: AppColors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar + name quick view
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary,
                  child: const Icon(
                    Icons.person,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                Text(_email, style: const TextStyle(color: AppColors.subtitle)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Name
          _editableRow(
            label: "Name",
            controller: _nameC,
            isEditing: _editName,
            onStartEdit: () => setState(() => _editName = true),
            onSave:
                () => setState(() {
                  _name = _nameC.text.trim();
                  _editName = false;
                }),
            validate: (v) => v.isEmpty ? "Name can't be empty" : null,
          ),
          const SizedBox(height: 12),

          // Email
          _editableRow(
            label: "Email",
            controller: _emailC,
            isEditing: _editEmail,
            onStartEdit: () => setState(() => _editEmail = true),
            onSave:
                () => setState(() {
                  _email = _emailC.text.trim();
                  _editEmail = false;
                }),
            keyboardType: TextInputType.emailAddress,
            validate: (v) {
              if (v.isEmpty) return "Email can't be empty";
              final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v);
              return ok ? null : "Enter a valid email";
            },
          ),
          const SizedBox(height: 12),

          // Age
          _editableRow(
            label: "Age",
            controller: _ageC,
            isEditing: _editAge,
            onStartEdit: () => setState(() => _editAge = true),
            onSave:
                () => setState(() {
                  _age = _ageC.text.trim();
                  _editAge = false;
                }),
            keyboardType: TextInputType.number,
            validate: (v) {
              final n = int.tryParse(v);
              if (n == null || n < 0) return "Enter a valid age";
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Location
          _editableRow(
            label: "Location",
            controller: _locationC,
            isEditing: _editLocation,
            onStartEdit: () => setState(() => _editLocation = true),
            onSave:
                () => setState(() {
                  _location = _locationC.text.trim();
                  _editLocation = false;
                }),
            validate: (v) => v.isEmpty ? "Location can't be empty" : null,
          ),
          const SizedBox(height: 24),

          // زر حفظ عام (اختياري)
          ElevatedButton.icon(
            onPressed: () {
              // هنا مكان استدعاء API للحفظ النهائي إن حبيت
              _toastSaved();
            },
            icon: const Icon(Icons.save),
            label: const Text("Save All"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
