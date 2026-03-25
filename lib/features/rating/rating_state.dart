// lib/features/rating/rating_state.dart

part of 'rating_cubit.dart';

enum RatingStatus { idle, showing, submitting, submitted, dismissed, error }

class RatingState extends Equatable {
  const RatingState({
    this.status = RatingStatus.idle,
    this.selectedStars = 0,
    this.comment = '',
    this.errorMessage,
  });

  final RatingStatus status;
  final int selectedStars;
  final String comment;
  final String? errorMessage;

  RatingState copyWith({
    RatingStatus? status,
    int? selectedStars,
    String? comment,
    String? errorMessage,
  }) {
    return RatingState(
      status: status ?? this.status,
      selectedStars: selectedStars ?? this.selectedStars,
      comment: comment ?? this.comment,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, selectedStars, comment, errorMessage];
}
