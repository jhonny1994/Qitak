enum OnboardingStep { one, two, three }

class OnboardingState {
  const OnboardingState({
    required this.hasSeenOnboarding,
    required this.currentStep,
    this.canSkip = true,
  });

  final bool hasSeenOnboarding;
  final OnboardingStep currentStep;
  final bool canSkip;
}
