// lib/features/rating/rating_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:landing_repository/landing_repository.dart';

part 'rating_state.dart';

class RatingCubit extends Cubit<RatingState> {
  RatingCubit({required LandingRepository landingRepository})
      : _repo = landingRepository,
        super(const RatingState());

  final LandingRepository _repo;

  /// Called once on app startup to count sessions and check if prompt should show.
  Future<void> onAppStarted() async {
    await _repo.incrementSessionCount();
    final should = await _repo.checkShouldShowRating();
    if (should) {
      await _repo.markRatingPromptShown();
      emit(state.copyWith(status: RatingStatus.showing));
    }
  }

  /// Update the selected star value in real time (as user taps).
  void selectStars(int stars) {
    emit(state.copyWith(selectedStars: stars));
  }

  /// Update the optional comment field.
  void updateComment(String comment) {
    emit(state.copyWith(comment: comment));
  }

  /// User tapped "Maybe Later" — dismiss without submitting.
  void dismiss() {
    emit(state.copyWith(status: RatingStatus.dismissed));
  }

  /// Submit the rating to the backend.
  Future<void> submit({String? platform, String? appVersion}) async {
    if (state.selectedStars == 0) return;
    emit(state.copyWith(status: RatingStatus.submitting));
    try {
      await _repo.submitRating(
        state.selectedStars,
        comment: state.comment,
        platform: platform,
        appVersion: appVersion,
      );
      emit(state.copyWith(status: RatingStatus.submitted));
    } catch (e) {
      emit(
        state.copyWith(
          status: RatingStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
