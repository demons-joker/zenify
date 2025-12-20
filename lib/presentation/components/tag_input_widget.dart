import 'package:flutter/material.dart';

/// Tag input widget for flexible tag management
class TagInputWidget extends StatefulWidget {
  final List<String> initialTags;
  final Function(List<String>) onTagsChanged;
  final String label;
  final String hintText;
  final int maxTags;
  final TextInputType keyboardType;
  final InputDecoration? decoration;

  const TagInputWidget({
    super.key,
    this.initialTags = const [],
    required this.onTagsChanged,
    this.label = '标签',
    this.hintText = '输入内容并按回车或点击添加',
    this.maxTags = 10,
    this.keyboardType = TextInputType.text,
    this.decoration,
  });

  @override
  State<TagInputWidget> createState() => _TagInputWidgetState();
}

class _TagInputWidgetState extends State<TagInputWidget> {
  late List<String> _tags;
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.initialTags);
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isEmpty) return;

    if (_tags.contains(trimmedTag)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('标签 "$trimmedTag" 已存在')),
      );
      return;
    }

    if (_tags.length >= widget.maxTags) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('最多只能添加 ${widget.maxTags} 个标签')),
      );
      return;
    }

    setState(() {
      _tags.add(trimmedTag);
    });

    _controller.clear();
    widget.onTagsChanged(_tags);
    _focusNode.requestFocus();
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
    widget.onTagsChanged(_tags);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          Text(
            widget.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
        ],
        // Tags display
        if (_tags.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) {
              return Chip(
                label: Text(tag),
                onDeleted: () => _removeTag(tag),
                deleteIcon: const Icon(Icons.close, size: 18),
                deleteIconColor: Colors.red[700],
                backgroundColor: Colors.blue[100],
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
        // Input field
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: widget.keyboardType,
                decoration: widget.decoration ??
                    InputDecoration(
                      hintText: widget.hintText,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      suffixText: '${_tags.length}/${widget.maxTags}',
                      suffixStyle: Theme.of(context).textTheme.labelSmall,
                    ),
                onSubmitted: _addTag,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _addTag(_controller.text),
              icon: const Icon(Icons.add),
              label: const Text('添加'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
        if (_tags.isEmpty) ...[
          const SizedBox(height: 8),
          Text(
            '暂无标签',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ],
    );
  }
}
