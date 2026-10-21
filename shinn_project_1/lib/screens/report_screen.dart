import 'package:flutter/material.dart';
import 'lib/widgets/app_button.dart';
import 'lib/widgets/app_text_field.dart';

/// UI states for the report screen.
enum ReportUiState { idle, loading, success, empty, error }

class _Report {
  final String title;
  final String category;
  final String location;
  final String description;
  final DateTime createdAt;

  _Report({
    required this.title,
    required this.category,
    required this.location,
    required this.description,
  }) : createdAt = DateTime.now();
}

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  static const _categories = ['Infrastructure', 'Safety', 'Sanitation', 'Other'];
  String _category = _categories.first;

  ReportUiState _uiState = ReportUiState.idle;
  bool _showList = false;

  /// Demo switch: forces a SIMULATED failure so the Error state can be shown.
  bool _simulateFailure = false;

  /// In-memory records (SIMULATED - nothing is saved to a real database).
  final List<_Report> _reports = [];
  _Report? _lastReport;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _uiState = ReportUiState.loading);
    try {
      // SIMULATED asynchronous request (replace with REST API call later).
      await Future<void>.delayed(const Duration(seconds: 3));
      if (_simulateFailure) throw Exception('Simulated failure');
      if (!mounted) return;
      final report = _Report(
        title: _titleController.text.trim(),
        category: _category,
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
      );
      setState(() {
        _reports.insert(0, report);
        _lastReport = report;
        _uiState = ReportUiState.success;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _uiState = ReportUiState.error);
    }
  }

  void _resetForm() {
    _titleController.clear();
    _locationController.clear();
    _descriptionController.clear();
    setState(() {
      _category = _categories.first;
      _showList = false;
      _uiState = ReportUiState.idle;
    });
  }

  void _openForm() {
    setState(() {
      _showList = false;
      _uiState = ReportUiState.idle;
    });
  }

  void _openList() {
    setState(() {
      _showList = true;
      _uiState = _reports.isEmpty ? ReportUiState.empty : ReportUiState.idle;
    });
  }

  String? _required(String? v, String name) =>
      (v == null || v.trim().isEmpty) ? '$name is required' : null;

  @override
  Widget build(BuildContext context) {
    final isLoading = _uiState == ReportUiState.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Report Form')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('New Report')),
                    ButtonSegment(value: true, label: Text('My Reports')),
                  ],
                  selected: {_showList},
                  onSelectionChanged: isLoading
                      ? null
                      : (s) => s.first ? _openList() : _openForm(),
                ),
                const SizedBox(height: 24),
                _buildBody(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_uiState) {
      case ReportUiState.idle:
        return _showList ? _buildList() : _buildForm();
      case ReportUiState.loading:
        return _buildForm();
      case ReportUiState.success:
        return _buildSuccess();
      case ReportUiState.empty:
        return _buildEmpty();
      case ReportUiState.error:
        return _buildError();
    }
  }

  // ---------------- FORM (idle + loading) ----------------
  Widget _buildForm() {
    final isLoading = _uiState == ReportUiState.loading;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _titleController,
            label: 'Report Title',
            hint: 'e.g. Broken street light',
            enabled: !isLoading,
            validator: (v) {
              final r = _required(v, 'Title');
              if (r != null) return r;
              if (v!.trim().length < 5) return 'Title must be at least 5 characters';
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: _categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: isLoading ? null : (v) => setState(() => _category = v!),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _locationController,
            label: 'Location',
            hint: 'e.g. Purok 3, Cabadbaran City',
            enabled: !isLoading,
            validator: (v) => _required(v, 'Location'),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _descriptionController,
            label: 'Description',
            hint: 'Describe the problem (min. 10 characters)',
            maxLines: 4,
            enabled: !isLoading,
            validator: (v) {
              final r = _required(v, 'Description');
              if (r != null) return r;
              if (v!.trim().length < 10) {
                return 'Description must be at least 10 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Simulate server failure (demo only)'),
            subtitle: const Text('Turn on to demonstrate the Error state'),
            value: _simulateFailure,
            onChanged:
                isLoading ? null : (v) => setState(() => _simulateFailure = v),
          ),
          const SizedBox(height: 16),
          if (isLoading) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 8),
            const Text(
              'Submitting report... please wait (simulated request)',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
          Center(
            child: AppButton(
              label: 'Submit Report',
              icon: Icons.send,
              isLoading: isLoading, // disabled while loading -> no duplicates
              onPressed: submitReport,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- SUCCESS ----------------
  Widget _buildSuccess() {
    final r = _lastReport!;
    return Column(
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 72),
        const SizedBox(height: 12),
        const Text(
          'Report submitted successfully!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          '(Simulated response - not saved to a real database)',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            title: Text(r.title),
            subtitle: Text('${r.category} • ${r.location}\n${r.description}'),
            isThreeLine: true,
          ),
        ),
        const SizedBox(height: 16),
        AppButton(
          label: 'Submit Another Report',
          icon: Icons.add,
          onPressed: _resetForm,
        ),
        const SizedBox(height: 12),
        AppButton(
          label: 'View My Reports',
          icon: Icons.list,
          outlined: true,
          onPressed: _openList,
        ),
      ],
    );
  }

  // ---------------- EMPTY ----------------
  Widget _buildEmpty() {
    return Column(
      children: [
        const SizedBox(height: 24),
        const Icon(Icons.inbox_outlined, size: 72, color: Colors.grey),
        const SizedBox(height: 12),
        const Text(
          'No reports yet',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'You have not created any reports. Create your first one now.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        AppButton(
          label: 'Create a Report',
          icon: Icons.add,
          onPressed: _openForm,
        ),
      ],
    );
  }

  // ---------------- ERROR ----------------
  Widget _buildError() {
    return Column(
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 72),
        const SizedBox(height: 12),
        const Text(
          'Submission failed',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'We could not submit your report (simulated failure). '
          'Please retry, or edit your report and try again.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        AppButton(
          label: 'Retry',
          icon: Icons.refresh,
          onPressed: submitReport,
        ),
        const SizedBox(height: 12),
        AppButton(
          label: 'Edit Report',
          icon: Icons.edit,
          outlined: true,
          onPressed: _openForm,
        ),
      ],
    );
  }

  // ---------------- REPORT LIST ----------------
  Widget _buildList() {
    return Column(
      children: _reports
          .map(
            (r) => Card(
              child: ListTile(
                leading: const Icon(Icons.description),
                title: Text(r.title),
                subtitle: Text('${r.category} • ${r.location}'),
              ),
            ),
          )
          .toList(),
    );
  }
}