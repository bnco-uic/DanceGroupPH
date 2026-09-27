import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/dance_group.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/snackbars.dart';
import '../utils/validators.dart';

/// CREATE and UPDATE share this screen.
/// group == null -> Add (POST). group != null -> Edit (PUT), fields pre-filled.
/// On success the screen closes and returns the saved DanceGroup.
class GroupFormScreen extends StatefulWidget {
  const GroupFormScreen({super.key, this.group});

  final DanceGroup? group;

  bool get isEditing => group != null;

  @override
  State<GroupFormScreen> createState() => _GroupFormScreenState();
}

class _GroupFormScreenState extends State<GroupFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = ApiService();

  late final TextEditingController _nameController;
  late final TextEditingController _cityController;
  late final TextEditingController _yearController;
  late final TextEditingController _membersController;
  late final TextEditingController _leaderController;
  late final TextEditingController _signatureController;
  late final TextEditingController _descriptionController;

  String? _style;
  String? _region;
  bool _isActive = true;
  bool _saving = false;

  /// Field errors returned by the server (HTTP 422), shown under the fields.
  Map<String, String> _serverErrors = {};

  @override
  void initState() {
    super.initState();
    final group = widget.group; // null when adding
    _nameController = TextEditingController(text: group?.groupName ?? '');
    _cityController = TextEditingController(text: group?.city ?? '');
    _yearController =
        TextEditingController(text: group?.foundedYear?.toString() ?? '');
    _membersController =
        TextEditingController(text: group?.memberCount.toString() ?? '');
    _leaderController = TextEditingController(text: group?.leaderName ?? '');
    _signatureController =
        TextEditingController(text: group?.signatureDance ?? '');
    _descriptionController =
        TextEditingController(text: group?.description ?? '');

    if (group != null && kDanceStyles.contains(group.danceStyle)) {
      _style = group.danceStyle;
    }
    _region = group?.region;
    _isActive = group?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _yearController.dispose();
    _membersController.dispose();
    _leaderController.dispose();
    _signatureController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Regions for the dropdown. Keeps an old value that is not in the list.
  List<String> get _regionOptions => [
        ...kRegions,
        if (_region != null && !kRegions.contains(_region)) _region!,
      ];

  String? _textOrNull(TextEditingController controller) {
    final text = controller.text.trim();
    return text.isEmpty ? null : text;
  }

  Future<void> _save() async {
    _serverErrors = {};
    if (!_formKey.currentState!.validate()) {
      showErrorSnackBar(context, 'Please fix the highlighted fields.');
      return;
    }

    final group = DanceGroup(
      id: widget.group?.id,
      groupName: _nameController.text.trim(),
      danceStyle: _style!,
      region: _region!,
      city: _cityController.text.trim(),
      foundedYear: int.tryParse(_yearController.text.trim()),
      memberCount: int.parse(_membersController.text.trim()),
      leaderName: _textOrNull(_leaderController),
      signatureDance: _textOrNull(_signatureController),
      description: _textOrNull(_descriptionController),
      isActive: _isActive,
    );

    setState(() => _saving = true);
    try {
      final saved = widget.isEditing
          ? await _api.updateGroup(group)
          : await _api.createGroup(group);
      if (!mounted) return;
      Navigator.pop(context, saved); // the previous screen shows the SnackBar
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _serverErrors = e.fieldErrors;
      });
      _formKey.currentState!.validate(); // shows the server's field errors
      showErrorSnackBar(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit group' : 'Add dance group'),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        // Any edit clears old server errors.
        onChanged: () => _serverErrors = {},
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildStylePreview(),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  maxLength: 100,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Group name *',
                    prefixIcon: Icon(Icons.groups),
                  ),
                  validator: (value) =>
                      Validators.groupName(value) ?? _serverErrors['group_name'],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _style,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: const InputDecoration(
                    labelText: 'Dance style *',
                    prefixIcon: Icon(Icons.style),
                  ),
                  items: [
                    for (final style in kDanceStyles)
                      DropdownMenuItem(
                        value: style,
                        child: Row(
                          children: [
                            Icon(
                              AppTheme.styleInfo(style).icon,
                              color: AppTheme.styleInfo(style).main,
                            ),
                            const SizedBox(width: 8),
                            Text(style),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (value) => setState(() => _style = value),
                  validator: (value) =>
                      Validators.danceStyle(value) ?? _serverErrors['dance_style'],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _region,
                  isExpanded: true,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: const InputDecoration(
                    labelText: 'Region *',
                    prefixIcon: Icon(Icons.map_outlined),
                  ),
                  items: [
                    for (final region in _regionOptions)
                      DropdownMenuItem(value: region, child: Text(region)),
                  ],
                  onChanged: (value) => setState(() => _region = value),
                  validator: (value) =>
                      Validators.region(value) ?? _serverErrors['region'],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cityController,
                  maxLength: 80,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'City *',
                    helperText: 'Also used for the weather forecast',
                    prefixIcon: Icon(Icons.place_outlined),
                  ),
                  validator: (value) =>
                      Validators.city(value) ?? _serverErrors['city'],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _yearController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Founded year',
                          prefixIcon: Icon(Icons.event_outlined),
                        ),
                        validator: (value) =>
                            Validators.foundedYear(value) ??
                            _serverErrors['founded_year'],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _membersController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Members *',
                          prefixIcon: Icon(Icons.people_outline),
                        ),
                        validator: (value) =>
                            Validators.memberCount(value) ??
                            _serverErrors['member_count'],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _leaderController,
                  maxLength: 100,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Leader name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) =>
                      Validators.optionalMax100(value, 'Leader name') ??
                      _serverErrors['leader_name'],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _signatureController,
                  maxLength: 100,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Signature dance',
                    hintText: 'e.g. Tinikling, Singkil',
                    prefixIcon: Icon(Icons.music_note_outlined),
                  ),
                  validator: (value) =>
                      Validators.optionalMax100(value, 'Signature dance') ??
                      _serverErrors['signature_dance'],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 3,
                  maxLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.notes),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: SwitchListTile(
                    value: _isActive,
                    onChanged: (value) => setState(() => _isActive = value),
                    secondary: Icon(
                      _isActive ? Icons.check_circle : Icons.pause_circle,
                      color: _isActive ? AppColors.successGreen : AppColors.muted,
                    ),
                    title: const Text('Active group'),
                    subtitle: Text(
                      _isActive ? 'Currently performing' : 'On break / inactive',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    // null disables the button while saving.
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      _saving
                          ? 'Saving...'
                          : (widget.isEditing ? 'Save changes' : 'Add group'),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// A banner that changes color when you pick a dance style.
  Widget _buildStylePreview() {
    final info = AppTheme.styleInfo(_style ?? '');
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: info.gradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(info.icon, color: info.onColor, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _style == null ? 'Pick a dance style' : '$_style dance group',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: info.onColor),
                ),
                Text(
                  'Fields marked * are required.',
                  style: TextStyle(color: info.onColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
