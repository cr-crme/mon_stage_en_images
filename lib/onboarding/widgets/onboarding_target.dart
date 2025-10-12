import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/onboarding/application/onboarding_keys_service.dart';

class OnboardingTarget extends StatefulWidget {
  const OnboardingTarget(
      {super.key, required this.child, required this.onboardingId});

  final Widget child;
  final String onboardingId;

  @override
  State<OnboardingTarget> createState() => _OnboardingTargetState();
}

class _OnboardingTargetState extends State<OnboardingTarget> {
  final onboardingKeyService = OnboardingKeysService.instance;
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    debugPrint(
        "initState running for OnBoardingTarget, will try to register key $_key for targetId ${widget.onboardingId}");
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        onboardingKeyService.addTargetKey(widget.onboardingId, _key);
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    onboardingKeyService.removeTargetKey(widget.onboardingId, _key);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("OnboardingTarget.build pour ${widget.onboardingId}");
    return KeyedSubtree(
      key: _key,
      child: widget.child,
    );
  }
}
