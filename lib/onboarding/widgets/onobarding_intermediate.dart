import 'package:flutter/material.dart';
import 'package:mon_stage_en_images/onboarding/application/onboarding_keys_service.dart';

class OnobardingIntermediate extends StatefulWidget {
  const OnobardingIntermediate(
      {super.key, required this.id, required this.child});
  final String id;
  final Widget child;
  @override
  State<OnobardingIntermediate> createState() => _OnobardingIntermediateState();
}

class _OnobardingIntermediateState extends State<OnobardingIntermediate> {
  final GlobalKey _key = GlobalKey();
  @override
  void initState() {
    OnboardingKeysService.instance.addIntermediateKey(widget.id, _key);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Using KeyedSubtree to prevent Container or SizedBox to be automatically removed from the tree during rendering
    return KeyedSubtree(
      key: _key,
      child: widget.child,
    );
  }
}
