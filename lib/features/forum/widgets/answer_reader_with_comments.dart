// lib/features/forum/widgets/answer_reader_with_comments.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cap_project/features/forum/cubit/forum_cubit.dart';
import 'package:cap_project/features/forum/cubit/forum_state.dart';
import 'line_comments_filtered_view.dart';

class AnswerReaderWithComments extends StatefulWidget {
  final String answerId;
  
  // If we want to force parse it from text, we might need a helper,
  // but ideally Cubit loads the lines separately.
  // For now, let's assume Cubit loads lines based on answerId.
  
  const AnswerReaderWithComments({
    super.key,
    required this.answerId,
  });

  @override
  State<AnswerReaderWithComments> createState() => _AnswerReaderWithCommentsState();
}

class _AnswerReaderWithCommentsState extends State<AnswerReaderWithComments> {
  
  @override
  void initState() {
    super.initState();
    // Load lines for this answer
    context.read<ForumCubit>().loadAnswerLines(widget.answerId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForumCubit, ForumState>(
      builder: (context, state) {
        if (state.isLoading && state.answerLines.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state.answerLines.isEmpty) {
          return const SizedBox.shrink(); 
        }

        return ListView.builder(
          shrinkWrap: true, // If nested in a scroll view
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.answerLines.length,
          itemBuilder: (context, index) {
            final line = state.answerLines[index];
            final isSelected = state.selectedLineId == line.lineId;
            
            return GestureDetector(
              onTap: () {
                 if (isSelected) {
                   context.read<ForumCubit>().toggleLineSelection(line.lineId);
                 } else {
                   context.read<ForumCubit>().toggleLineSelection(line.lineId);
                 }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                color: isSelected ? Colors.blue.withOpacity(0.08) : Colors.transparent,
                padding: EdgeInsets.symmetric(
                  vertical: isSelected ? 12 : 4,
                  horizontal: isSelected ? 8 : 0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style.copyWith(
                          fontSize: 16,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                        children: [
                          if (isSelected)
                            TextSpan(
                              text: '[${line.lineNumber}] ',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          TextSpan(
                            text: line.text,
                            style: TextStyle(
                              color: isSelected ? Colors.black87 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Interaction Point
                    if (isSelected)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: GestureDetector(
                          onTap: () => _showLineCommentsModal(context, line.lineId, line.lineNumber),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.chat_bubble_outline, size: 16, color: Colors.blue),
                              const SizedBox(width: 4),
                              Text(
                                '${line.commentCount} ${line.commentCount == 1 ? 'comment' : 'comments'}',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right, size: 16, color: Colors.blue),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showLineCommentsModal(BuildContext context, String lineId, int lineNumber) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => BlocProvider.value(
        value: context.read<ForumCubit>(),
        child: LineCommentsFilteredView(
          lineId: lineId,
          lineNumber: lineNumber,
        ),
      ),
    );
  }
}
